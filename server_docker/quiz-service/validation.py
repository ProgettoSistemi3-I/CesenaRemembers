"""Validazione del quiz generato.

Due livelli, separati:

1. STRUTTURALE (parse_llm_output): JSON valido, schema Pydantic con tipi
   stretti, numero esatto di opzioni, correctIndex nell'intervallo, opzioni
   distinte, campi non vuoti.

2. STORICA (check_question): controlli deterministici e veloci, senza un
   secondo modello (che aggiungerebbe 1–3 s e non garantirebbe comunque
   l'assenza di allucinazioni):
   - i factIds esistono tra i fatti inviati in questa richiesta;
   - l'evidence coincide esattamente (a meno di spazi/apostrofi) con il
     testo del fatto citato;
   - numeri/date nella domanda e nella risposta corretta compaiono nei
     fatti citati;
   - nomi propri nella domanda e nella risposta corretta compaiono nei
     fatti citati (o nel nome del luogo);
   - la risposta corretta ha un aggancio lessicale con i fatti citati;
   - nessuna opzione errata è "contenuta" nel fatto citato (possibile
     seconda risposta corretta);
   - niente domande negative/trabocchetto;
   - lingua coerente con quella richiesta.

Limite dichiarato: sono euristiche. Bloccano le invenzioni più comuni
(date, numeri, nomi, unità, premesse con entità estranee) ma non possono
dimostrare la correttezza semantica di ogni parafrasi. Le opzioni errate con
nomi non presenti nei fatti vengono registrate come "warning", non scartate,
perché per definizione descrivono alternative false.
"""

from __future__ import annotations

import json
import re
import unicodedata
from dataclasses import dataclass, field

from typing import TYPE_CHECKING

from facts_loader import Fact

if TYPE_CHECKING:  # pragma: no cover
    from models import LlmQuestion

# Nota: questo modulo usa solo la libreria standard (pydantic è importato
# soltanto dentro parse_llm_output), così lo script di test per Windows può
# riutilizzare gli stessi controlli senza installare le dipendenze del server.

# ---------------------------------------------------------------------------
# Normalizzazione
# ---------------------------------------------------------------------------
_QUOTES = str.maketrans({"’": "'", "‘": "'", "`": "'", "“": '"', "”": '"', "«": '"', "»": '"', "–": "-", "—": "-"})


def normalize(text: str) -> str:
    text = unicodedata.normalize("NFKC", text).translate(_QUOTES)
    return re.sub(r"\s+", " ", text).strip()


def _fold(text: str) -> str:
    """minuscolo senza accenti, per confronti lessicali."""
    text = unicodedata.normalize("NFKD", normalize(text).lower())
    return "".join(c for c in text if not unicodedata.combining(c))


_WORD = re.compile(r"[a-z0-9]+")

STOPWORDS = set(
    """
    il lo la i gli le un uno una di del dello della dei degli delle da dal dallo dalla dai dagli dalle
    a al allo alla ai agli alle in nel nello nella nei negli nelle su sul sullo sulla sui sugli sulle
    con per tra fra e ed o od che chi cui non come dove quando quale quali quanto quanti quante cosa
    perche fu furono era erano e sono sia anche piu meno molto suo sua suoi sue loro questo questa
    questi queste quello quella quelli quelle essere stato stata stati state dopo prima durante
    secondo circa oltre ogni tutto tutti tutta tutte gia solo
    the a an of and or to in on at by for with from as is was were be been being that which who whom
    whose what when where why how this these those it its their there into during after before about
    than more most also only not did does do had has have one two three would could
    """.split()
)

# Parole che possono comparire con l'iniziale maiuscola senza essere un
# fatto da verificare (nomi generici, titoli di periodo, nomi del contesto).
GENERIC_PROPER = set(
    """
    cesena italia italy italian italiano italiana romagna seconda prima guerra mondiale world war second
    first ii wwii alleati alleato alleate allies allied tedeschi tedesco tedesca germans german nazi
    nazisti fascisti fascista fascist fascists resistenza resistance partigiani partisans comune
    municipality chiesa church
    """.split()
)

NEGATIVE_PATTERNS = re.compile(
    r"\b(NON|NOT|EXCEPT|TRANNE|ECCETTO)\b|\bquale\s+(?:di\s+queste\s+)?non\b|\bwhich\s+(?:of\s+the\s+following\s+)?(?:is|was|were|did)\s+not\b"
    r"|\bnon\s+[eè]\s+vero\b|\bis\s+not\s+true\b",
)

IT_MARKERS = set("il lo gli della delle dei degli del nel nella nei che chi quale quali perche fu furono era sono una per con dalla dal alla anni come cosa quando dove".split())
EN_MARKERS = set("the of which what who was were did during from with for its their when where why how built year".split())

_NUMBER = re.compile(r"\d+(?:[.,]\d{3})*(?:[.,]\d+)?")
# Parola con iniziale maiuscola (anche accentata), incluse sigle tipo GAP.
_CAP_WORD = re.compile(r"(?<![\w'])([A-ZÀ-ÖØ-Þ][\w'’-]*)")


def numbers_in(text: str) -> set[str]:
    out = set()
    for raw in _NUMBER.findall(normalize(text)):
        digits = re.sub(r"[.,](?=\d{3}\b)", "", raw)  # 1.800 / 1,800 -> 1800
        out.add(digits.lstrip("0") or "0")
    return out


def content_tokens(text: str) -> list[str]:
    return [t for t in _WORD.findall(_fold(text)) if len(t) >= 4 and t not in STOPWORDS and not t.isdigit()]


def _prefix_match(token: str, vocabulary: set[str], n: int = 5) -> bool:
    if token in vocabulary:
        return True
    p = token[: min(n, len(token))]
    return any(v.startswith(p) for v in vocabulary)


def proper_nouns(text: str) -> list[str]:
    """Parole con maiuscola che NON sono a inizio frase."""
    text = normalize(text)
    found = []
    for m in _CAP_WORD.finditer(text):
        start = m.start()
        before = text[:start].rstrip()
        if not before or before[-1] in ".?!:;\"'(«[":
            continue  # inizio frase/citazione: la maiuscola non è informativa
        found.append(m.group(1).strip("'’-"))
    return found


def detect_language(text: str) -> str | None:
    words = _WORD.findall(_fold(text))
    it = sum(1 for w in words if w in IT_MARKERS)
    en = sum(1 for w in words if w in EN_MARKERS)
    if it == en:
        return None
    return "it" if it > en else "en"


# ---------------------------------------------------------------------------
# Strutturale
# ---------------------------------------------------------------------------
class StructuralError(Exception):
    def __init__(self, code: str, message: str):
        super().__init__(message)
        self.code = code


def parse_llm_output(content: str, *, expected_questions: int, n_options: int) -> list["LlmQuestion"]:
    from pydantic import ValidationError

    from models import LlmQuiz

    text = content.strip()
    # Alcuni modelli racchiudono il JSON tra ```; lo tolleriamo.
    fence = re.match(r"^```(?:json)?\s*(.*?)\s*```$", text, re.DOTALL)
    if fence:
        text = fence.group(1)
    try:
        raw = json.loads(text)
    except json.JSONDecodeError as exc:
        raise StructuralError("invalid_json", f"JSON non valido: {exc.msg}") from exc
    try:
        quiz = LlmQuiz.model_validate(raw)
    except ValidationError as exc:
        raise StructuralError("schema_mismatch", f"Schema non rispettato: {exc.error_count()} errori") from exc
    if len(quiz.questions) != expected_questions:
        raise StructuralError(
            "wrong_question_count", f"Attese {expected_questions} domande, ricevute {len(quiz.questions)}"
        )
    return quiz.questions


def structural_issues(q: "LlmQuestion", n_options: int) -> list[str]:
    issues = []
    if len(q.options) != n_options:
        issues.append(f"wrong_option_count:{len(q.options)}")
    if not 0 <= q.correctIndex < len(q.options):
        issues.append("correct_index_out_of_range")
    normalized = [_fold(o) for o in q.options]
    if len(set(normalized)) != len(normalized):
        issues.append("duplicate_options")
    if len(q.factIds) != len(q.evidence):
        issues.append("evidence_factids_mismatch")
    if len(set(q.factIds)) != len(q.factIds):
        issues.append("duplicate_fact_ids")
    return issues


# ---------------------------------------------------------------------------
# Politica di contenuto: niente domande "guarda la data" né riferimenti interni
# ---------------------------------------------------------------------------
# Vietate (regole deterministiche, applicate dopo la generazione):
#   - domande che chiedono una data, un anno, un mese, un secolo o "quando";
#   - domande di ordine cronologico (prima/dopo/più tardi/per primo...);
#   - domande in cui la risposta si sceglie confrontando le date delle opzioni;
#   - opzioni che sono solo date o anni;
#   - riferimenti ai "fatti"/alle "informazioni fornite" e opzioni come
#     "non è specificato" o "nessuna delle precedenti".
# Una data nel testo della domanda, come contesto, resta ammessa.
_MONTHS = (
    r"(?:gennaio|febbraio|marzo|aprile|maggio|giugno|luglio|agosto|settembre|ottobre|novembre|dicembre"
    r"|january|february|march|april|may|june|july|august|september|october|november|december)"
)
_MONTH_RE = re.compile(r"\b" + _MONTHS + r"\b")
_YEAR_RE = re.compile(r"\b(?:1[0-9]{3}|20[0-9]{2})\b")
_DAY_MONTH_RE = re.compile(
    r"\b\d{1,2}(?:st|nd|rd|th)?\s+(?:of\s+)?" + _MONTHS + r"\b|\b" + _MONTHS + r"\s+\d{1,2}\b"
)
_DATE_FILLER = set(
    "il lo la nel nello in dal dall al fino a del di dell anno anni year on the of from to until and e tra fra circa verso entro by around".split()
)

_DATE_ASK_STRONG = re.compile(
    r"\b(?:che|quale|quali)\s+(?:anno|anni|data|date|mese|mesi|secolo|secoli|giorno|giorni|decennio)\b"
    r"|\b(?:what|which)\s+(?:year|date|month|century|day|decade)\b"
    r"|\bin\s+what\s+year\b|\bon\s+what\s+date\b|\bhow\s+many\s+years\b"
    r"|\buntil\s+when\b|\bsince\s+when\b|\bfino\s+a\s+quando\b|\bda\s+quando\b"
)
_WHEN_WORD = re.compile(r"\b(?:quando|when)\b")

_ORDER_STRONG = re.compile(
    r"\bpiu\s+(?:tardi|recente|recenti|antico|antica|antichi|antiche)\b"
    r"|\bper\s+(?:primo|ultimo|ultima)\b"
    r"|\b(?:prima|dopo)\b.{0,15}?\baltr[oaie]\b"
    r"|\bcronolog\w*|\bprecedut\w*"
    r"|\b(?:earlier|later|earliest|latest|chronolog\w*|preceded|more\s+recent)\b"
    r"|\b(?:happened|occurred|came|took\s+place)\s+(?:first|last|before|after)\b"
    r"|\bwhich\s+(?:event\s+)?(?:came|happened|occurred)\b.{0,12}\b(?:first|before|after)\b"
)
_ORDER_VERB = re.compile(
    r"\b(?:avvenn\w+|avvenut\w+|accadd\w+|accadut\w+|si\s+verific\w+|success\w+)\s+(?:\w+\s+)?(?:prima|dopo)\b"
)
# "dopo aver perso...", "after it lost...": costruzioni che non chiedono un ordine.
_ORDER_BENIGN = re.compile(
    r"\b(?:dopo|prima)\s+(?:aver|avere|essere|essersi|che)\b|\bafter\s+(?:it\s+|the\s+\w+\s+)?(?:lost|losing|being|having|becoming)\b"
)
_ORDER_WEAK = re.compile(
    r"\b(?:prima|dopo|precedente|successiv\w*|seguit\w*|before|after|followed)\b"
)

_META_OPTION = re.compile(
    r"\bnon\s+(?:e\s+)?(?:possibile|specificat\w+|indicat\w+|determinabil\w+)\b"
    r"|\bnon\s+ci\s+sono\s+informazioni\b"
    r"|\binformazioni\s+(?:fornite|date|disponibili)\b|\bdati\s+forniti\b|\bnei\s+fatti\b"
    r"|\bnessuna\s+delle\s+(?:precedenti|risposte|opzioni|altre)\b|\btutte\s+le\s+(?:precedenti|risposte)\b"
    r"|\bnot\s+(?:specified|stated|mentioned|possible\s+to)\b|\bcannot\s+be\s+(?:determined|established|known)\b"
    r"|\bcan'?t\s+be\s+determined\b|\binformation\s+(?:given|provided)\b|\b(?:in|from)\s+the\s+facts\b"
    r"|\bnone\s+of\s+the\s+above\b|\ball\s+of\s+the\s+above\b|\bno\s+information\b"
)
_META_REFERENCE = re.compile(
    r"\b(?:secondo|stando\s+a|in\s+base\s+a|nei|dai|dalle?)\s+(?:i\s+|le\s+)?"
    r"(?:fatti|schede|informazioni\s+(?:fornite|date|disponibili)|dati\s+forniti)\b"
    r"|\binformazioni\s+fornite\b|\bfatt[oi]\s+citat[oi]\b"
    r"|\b(?:according\s+to|based\s+on)\s+the\s+(?:given\s+|provided\s+|cited\s+)?(?:facts?|information)\b"
    r"|\b(?:given|provided|cited)\s+facts?\b"
)


def _date_tokens(text: str) -> set[str]:
    folded = _fold(text)
    tokens = set(_YEAR_RE.findall(folded))
    tokens |= {re.sub(r"\s+", " ", m.group(0)) for m in _DAY_MONTH_RE.finditer(folded)}
    return tokens


def _is_bare_date(text: str) -> bool:
    """Opzione fatta solo di una data/anno/mese (es. "1969", "il 29 giugno 1944")."""
    folded = _fold(text)
    if not (_date_tokens(text) or _MONTH_RE.search(folded)):
        return False  # un numero qualsiasi (es. "800") non è una data
    folded = _DAY_MONTH_RE.sub(" ", folded)
    folded = _YEAR_RE.sub(" ", folded)
    folded = _MONTH_RE.sub(" ", folded)
    words = [w for w in _WORD.findall(folded) if w not in _DATE_FILLER and not w.isdigit()]
    return not words


def _date_driven(options: list[str], min_options: int) -> bool:
    """True se almeno `min_options` opzioni contengono una data e le date differiscono."""
    per_option = [_date_tokens(o) for o in options]
    with_dates = [t for t in per_option if t]
    if len(with_dates) < min_options:
        return False
    return len(set().union(*with_dates)) >= 2


def forbidden_pattern_issues(question: str, options: list[str], correct_index: int) -> list[str]:
    """Domande "guarda la data", ordine cronologico, opzioni meta. Lista di codici errore."""
    issues: list[str] = []
    fq = _fold(question)
    correct = options[correct_index]

    if _DATE_ASK_STRONG.search(fq) or (
        _WHEN_WORD.search(fq) and (_date_tokens(correct) or _is_bare_date(correct))
    ):
        issues.append("date_question")

    fq_order = _ORDER_BENIGN.sub(" ", fq)
    if (
        _ORDER_STRONG.search(fq_order)
        or _ORDER_VERB.search(fq_order)
        or (_ORDER_WEAK.search(fq_order) and _date_driven(options, 2))
    ):
        issues.append("chronological_order_question")

    if _is_bare_date(correct) or sum(_is_bare_date(o) for o in options) >= 2 or _date_driven(options, 3):
        issues.append("date_options")

    if any(_META_OPTION.search(_fold(o)) for o in options):
        issues.append("meta_option")
    if _META_REFERENCE.search(fq) or any(_META_REFERENCE.search(_fold(o)) for o in options):
        issues.append("meta_reference")
    return issues


# ---------------------------------------------------------------------------
# Storica
# ---------------------------------------------------------------------------
@dataclass
class QuestionCheck:
    ok: bool
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)


def check_question(
    q: "LlmQuestion",
    *,
    language: str,
    allowed_facts: dict[str, Fact],
    place_name: str,
    n_options: int,
) -> QuestionCheck:
    errors = structural_issues(q, n_options)
    warnings: list[str] = []
    if errors:
        return QuestionCheck(False, errors, warnings)

    # 0. Politica di contenuto: niente domande "guarda la data" (vedi sopra).
    errors.extend(forbidden_pattern_issues(q.question, q.options, q.correctIndex))

    # 1. I fatti citati esistono e l'evidence è una copia esatta.
    cited: list[Fact] = []
    for fid, ev in zip(q.factIds, q.evidence):
        fact = allowed_facts.get(fid.strip())
        if fact is None:
            errors.append(f"unknown_fact_id:{fid}")
            continue
        cited.append(fact)
        target = normalize(fact.text(language))
        got = normalize(ev).strip('"')
        # Si accetta la frase completa o, in alternativa, un passaggio lungo
        # (>= 60% del fatto) copiato alla lettera.
        if not (got == target or (len(got) >= 0.6 * len(target) and got in target)):
            errors.append(f"evidence_not_exact:{fid}")
    if errors:
        return QuestionCheck(False, errors, warnings)

    question = q.question
    correct = q.options[q.correctIndex]
    wrong = [o for i, o in enumerate(q.options) if i != q.correctIndex]

    if NEGATIVE_PATTERNS.search(question):
        errors.append("negative_or_trick_question")

    # Testo di riferimento: i fatti citati in entrambe le lingue (i numeri e i
    # nomi sono gli stessi; usare entrambe evita falsi positivi di traduzione).
    ref_text = " ".join(f.text_it + " " + f.text_en for f in cited)
    ref_numbers = numbers_in(ref_text)
    ref_vocab = set(_WORD.findall(_fold(ref_text + " " + place_name)))

    # 2. Numeri e date non supportati in domanda / risposta corretta.
    for part_name, part in (("question", question), ("correct_option", correct)):
        extra = numbers_in(part) - ref_numbers
        if extra:
            errors.append(f"unsupported_number_in_{part_name}:{','.join(sorted(extra))}")

    # 3. Nomi propri non supportati in domanda / risposta corretta.
    for part_name, part in (("question", question), ("correct_option", correct)):
        for noun in proper_nouns(part):
            folded = _fold(noun)
            tokens = _WORD.findall(folded)
            if not tokens or all(t in GENERIC_PROPER or t in STOPWORDS for t in tokens):
                continue
            if not all(_prefix_match(t, ref_vocab, 6) or t in GENERIC_PROPER for t in tokens):
                errors.append(f"unsupported_name_in_{part_name}:{noun}")
        # Una risposta corretta che è solo una parola con iniziale maiuscola
        # (es. "Valadier") non è coperta da proper_nouns (inizio frase).
    first = normalize(correct).split(" ")[0] if correct.strip() else ""
    if first[:1].isupper():
        t = _fold(first)
        t_tokens = _WORD.findall(t)
        if t_tokens and t_tokens[0] not in STOPWORDS and t_tokens[0] not in GENERIC_PROPER:
            if not _prefix_match(t_tokens[0], ref_vocab, 6) and not _prefix_match(t_tokens[0], set(content_tokens(question)), 6):
                # Parola iniziale capitalizzata assente dai fatti: segnala solo se
                # non è una parola comune (lunghezza >= 4).
                if len(t_tokens[0]) >= 4 and t_tokens[0] not in IT_MARKERS | EN_MARKERS:
                    warnings.append(f"correct_option_first_word_not_in_facts:{first}")

    # 4. La risposta corretta deve agganciarsi ai fatti citati.
    tokens = content_tokens(correct)
    if tokens:
        matched = sum(1 for t in tokens if _prefix_match(t, ref_vocab))
        if matched / len(tokens) < 0.34:
            errors.append("correct_option_not_supported_by_evidence")
    elif not numbers_in(correct):
        errors.append("correct_option_empty_content")

    # 5. Opzione errata forse corretta: tutto il suo contenuto è nel fatto citato
    #    e non coincide con la risposta corretta.
    cited_target = " ".join(_fold(f.text(language)) for f in cited)
    correct_tokens = set(content_tokens(correct))
    for w in wrong:
        w_tokens = content_tokens(w)
        w_numbers = numbers_in(w)
        if len(w_tokens) >= 2 and all(_prefix_match(t, ref_vocab) for t in w_tokens) \
                and w_numbers <= ref_numbers and set(w_tokens) - correct_tokens:
            # tutti i token dell'opzione errata compaiono nei fatti citati:
            # controllo più fine sul testo nella lingua richiesta
            if _fold(w) in cited_target:
                errors.append(f"wrong_option_stated_in_fact:{w}")
            else:
                warnings.append(f"wrong_option_close_to_fact:{w}")
        for noun in proper_nouns(" " + w):
            if not all(_prefix_match(t, ref_vocab, 6) or t in GENERIC_PROPER for t in _WORD.findall(_fold(noun))):
                warnings.append(f"name_in_wrong_option_not_in_facts:{noun}")

    # 6. Lingua.
    lang = detect_language(question + " " + " ".join(q.options))
    if lang is not None and lang != language:
        errors.append(f"wrong_language:{lang}")
    elif lang is None:
        warnings.append("language_undetermined")

    return QuestionCheck(not errors, errors, warnings)


def near_duplicate(a: str, b: str, threshold: float = 0.6) -> bool:
    ta, tb = set(content_tokens(a)), set(content_tokens(b))
    if not ta or not tb:
        return _fold(a) == _fold(b)
    return len(ta & tb) / len(ta | tb) >= threshold
