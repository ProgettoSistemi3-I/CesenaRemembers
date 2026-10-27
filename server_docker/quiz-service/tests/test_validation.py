"""Test unitari: caricamento schede, validazione strutturale e storica.

Esecuzione (dalla cartella quiz-service):  python -m pytest -q tests
I casi "allucinati" riproducono le affermazioni elencate in
evidenza_allucinazioni_quiz.txt (usate solo come esempi di errore).
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from facts_loader import KNOWN_POI_IDS, load_all, parse_facts_file  # noqa: E402
from models import LlmQuestion  # noqa: E402
from prompts import difficulty_level  # noqa: E402
from validation import (  # noqa: E402
    StructuralError,
    check_question,
    near_duplicate,
    numbers_in,
    parse_llm_output,
)

FACTS = load_all(ROOT / "facts")
ROCCA = FACTS["rocca"].by_id()


def q(question, options, correct, fact_ids, lang="it", evidence=None):
    facts = FACTS["rocca"].by_id()
    ev = evidence if evidence is not None else [facts[f].text(lang) for f in fact_ids]
    return LlmQuestion(question=question, options=options, correctIndex=correct, factIds=fact_ids, evidence=ev)


def run(question, lang="it", facts=None):
    return check_question(
        question,
        language=lang,
        allowed_facts=facts or ROCCA,
        place_name="Rocca Malatestiana" if lang == "it" else "Malatestiana Fortress",
        n_options=4,
    )


# ---------------------------------------------------------------------------
# Schede
# ---------------------------------------------------------------------------
def test_all_ten_pois_have_at_least_three_verified_facts():
    assert set(FACTS) == set(KNOWN_POI_IDS)
    for poi_id, poi in FACTS.items():
        assert len(poi.facts) >= 3, poi_id
        for f in poi.facts:
            assert f.text_it and f.text_en


def test_only_verified_section_is_loaded():
    content = """# X
## Fatti verificati
### AAA-01
- Affermazione (IT): Fatto uno.
- Affermazione (EN): Fact one.
- Stato: verificato
### AAA-02
- Affermazione (IT): Fatto dubbio.
- Affermazione (EN): Doubtful fact.
- Stato: parzialmente verificato
## Informazioni parzialmente verificate o non verificate
### AAA-03
- Affermazione (IT): Non deve essere caricato.
- Affermazione (EN): Must not be loaded.
- Stato: verificato
"""
    poi = parse_facts_file("x", content)
    assert [f.id for f in poi.facts] == ["AAA-01"]


def test_xp_mapping_matches_previous_thresholds():
    assert [difficulty_level(x) for x in (0, 200, 201, 300, 400, 401, 500, 600, 601, 800, -5)] == [
        1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 1
    ]


# ---------------------------------------------------------------------------
# Strutturale
# ---------------------------------------------------------------------------
def test_structural_rejects_bad_json_and_counts():
    with pytest.raises(StructuralError) as e:
        parse_llm_output("{not json", expected_questions=3, n_options=4)
    assert e.value.code == "invalid_json"
    with pytest.raises(StructuralError) as e:
        parse_llm_output(json.dumps({"questions": []}), expected_questions=3, n_options=4)
    assert e.value.code == "wrong_question_count"
    bad_type = {"questions": [{"question": "Domanda abbastanza lunga?", "options": ["a", "b", "c", "d"],
                               "correctIndex": "1", "factIds": ["ROC-01"], "evidence": ["x"]}] * 3}
    with pytest.raises(StructuralError) as e:
        parse_llm_output(json.dumps(bad_type), expected_questions=3, n_options=4)
    assert e.value.code == "schema_mismatch"


def test_structural_issues_detected():
    res = run(q("Chi avviò la costruzione della Rocca Nuova?", ["Galeotto Malatesta", "Galeotto Malatesta", "Cesare Borgia", "Leonardo da Vinci"], 0, ["ROC-01"]))
    assert "duplicate_options" in res.errors
    res = run(q("Chi avviò la costruzione della Rocca Nuova?", ["Galeotto Malatesta", "Cesare Borgia", "Leonardo da Vinci"], 0, ["ROC-01"]))
    assert any(e.startswith("wrong_option_count") for e in res.errors)
    res = run(q("Chi avviò la costruzione della Rocca Nuova?", ["Galeotto Malatesta", "Cesare Borgia", "Leonardo da Vinci", "Federico Barbarossa"], 4, ["ROC-01"]))
    assert "correct_index_out_of_range" in res.errors


# ---------------------------------------------------------------------------
# Domande corrette (devono passare)
# ---------------------------------------------------------------------------
def test_good_recognition_question_it():
    res = run(q(
        "Per iniziativa di chi fu avviata nel 1380 la costruzione della Rocca Nuova?",
        ["Galeotto Malatesta", "Cesare Borgia", "Federico Barbarossa", "Leonardo da Vinci"],
        0, ["ROC-01"],
    ))
    assert res.ok, res.errors


def test_good_question_en():
    res = run(q(
        "What did the Fortress become after it lost its military role?",
        ["A prison", "A school", "A hospital", "A covered market"],
        0, ["ROC-09"], lang="en",
    ), lang="en")
    assert res.ok, res.errors


def test_good_question_with_context_date_it():
    # La data nel testo della domanda è solo contesto: ammessa.
    res = run(q(
        "Dopo aver perso la funzione militare, quale ruolo assunse la Rocca fino al 1969?",
        ["Fu trasformata in carcere", "Divenne una scuola", "Divenne un ospedale", "Divenne un mercato coperto"],
        0, ["ROC-09"],
    ))
    assert res.ok, res.errors


def test_good_question_older_fortress_it():
    res = run(q(
        "Quale fortezza esisteva sul colle prima della Rocca Malatestiana?",
        ["La Rocca vecchia", "Il castello di Montiano", "Il forte di Ravaldino", "La torre del Ridotto"],
        0, ["ROC-05"],
    ))
    assert res.ok, res.errors


# ---------------------------------------------------------------------------
# Domande "guarda la data": vietate
# ---------------------------------------------------------------------------
def test_rejects_question_asking_for_a_year_it():
    res = run(q(
        "Fino a quale anno la Rocca rimase adibita a carcere?",
        ["1969", "1944", "1527", "1380"], 0, ["ROC-09"],
    ))
    assert not res.ok and "date_question" in res.errors


def test_rejects_question_asking_for_a_year_en():
    res = run(q(
        "Until which year was the Fortress used as a prison?",
        ["1969", "1527", "1944", "1380"], 0, ["ROC-09"], lang="en",
    ), lang="en")
    assert not res.ok and "date_question" in res.errors


def test_rejects_when_question_with_date_answer():
    res = run(q(
        "Quando fu inaugurato il Parco della Rimembranza?",
        ["Nel 1924", "Nel 1944", "Nel 1969", "Nel 1380"], 0, ["ROC-13"],
    ))
    assert not res.ok and "date_question" in res.errors


def test_rejects_chronological_order_question():
    res = run(q(
        "Quale evento avvenne prima: il soggiorno di Federico Barbarossa nella Rocca vecchia o l'avvio della Rocca Nuova?",
        ["Il soggiorno di Federico Barbarossa nella Rocca vecchia", "L'avvio della costruzione della Rocca Nuova",
         "La distruzione della rocca da parte dei Lanzichenecchi", "Il Parco della Rimembranza"],
        0, ["ROC-05", "ROC-01"],
    ))
    assert not res.ok and "chronological_order_question" in res.errors


def test_rejects_which_came_first_without_dates_in_options():
    res = run(q(
        "Quale dei seguenti eventi avvenne prima?",
        ["Il Parco della Rimembranza", "L'apertura del museo", "La riapertura dei camminamenti", "La creazione del Ducato"],
        0, ["ROC-13", "ROC-14"],
    ))
    assert not res.ok and "chronological_order_question" in res.errors


def test_rejects_options_chosen_by_comparing_dates():
    res = run(q(
        "Quale evento avvenne mentre la Rocca era ancora un carcere?",
        ["Le incursioni partigiane del 1944", "L'apertura del museo nel 1974", "L'avvio della costruzione nel 1380",
         "La riapertura dei camminamenti nel 2003"],
        0, ["ROC-09", "ROC-10"],
    ))
    assert not res.ok and "date_options" in res.errors


def test_rejects_bare_date_options():
    res = run(q(
        "Cosa avvenne alla Rocca nel 1944?",
        ["1944", "1924", "1969", "1527"], 0, ["ROC-10"],
    ))
    assert not res.ok and "date_options" in res.errors


def test_rejects_meta_options_and_references():
    res = run(q(
        "Secondo i fatti, quale ruolo ebbe la Rocca dopo aver perso la funzione militare?",
        ["Fu trasformata in carcere", "Non è possibile stabilirlo con le informazioni fornite",
         "Divenne una scuola", "Divenne un ospedale"],
        0, ["ROC-09"],
    ))
    assert not res.ok
    assert "meta_option" in res.errors and "meta_reference" in res.errors


# ---------------------------------------------------------------------------
# Allucinazioni del vecchio sistema (devono essere respinte)
# ---------------------------------------------------------------------------
def test_rejects_invented_liberation_date_and_unit():
    res = run(q(
        "Quale unità americana liberò la Rocca il 25 aprile 1945?",
        ["La 1ª Divisione di fanteria", "La 5ª Armata", "La 8ª Armata", "Nessuna"],
        0, ["ROC-10"],
    ))
    assert not res.ok
    assert any(e.startswith("unsupported_number_in_question") for e in res.errors)


def test_rejects_invented_bombing_with_b24():
    res = run(q(
        "What aircraft attacked the Fortress on 12 March 1944?",
        ["B-24 Liberator bombers", "Spitfires", "Stukas", "No aircraft"],
        0, ["ROC-12"], lang="en",
    ), lang="en")
    assert not res.ok
    assert any("unsupported_number" in e for e in res.errors)


def test_rejects_invented_headquarters_premise():
    res = run(q(
        "Which German division used the Fortress as its command post?",
        ["The 1st Parachute Division", "The 90th Panzergrenadier", "The 278th Infantry", "None of them"],
        0, ["ROC-09"], lang="en",
    ), lang="en")
    assert not res.ok


def test_rejects_unsupported_civilian_number():
    res = run(q(
        "Quanti civili ospitava il rifugio della Rocca?",
        ["800", "150", "200", "1000"], 0, ["ROC-12"],
    ))
    assert not res.ok
    assert any(e.startswith("unsupported_number_in_correct_option") for e in res.errors)


def test_rejects_wrong_year_for_shelter():
    res = run(q(
        "In quale anno la Rocca fu trasformata in rifugio?",
        ["1942", "1944", "1940", "1943"], 0, ["ROC-12"],
    ))
    assert not res.ok


def test_rejects_unsupported_name_in_question():
    res = run(q(
        "Quale ruolo ebbe il generale Kesselring nella costruzione della Rocca Nuova nel 1380?",
        ["Nessuno: la avviò Galeotto Malatesta", "La progettò", "La finanziò", "La distrusse"],
        0, ["ROC-01"],
    ))
    assert not res.ok
    assert any(e.startswith("unsupported_name_in_question") for e in res.errors)


def test_rejects_evidence_not_copied_exactly():
    res = run(q(
        "Per iniziativa di chi fu avviata nel 1380 la costruzione della Rocca Nuova?",
        ["Galeotto Malatesta", "Cesare Borgia", "Federico Barbarossa", "Leonardo da Vinci"],
        0, ["ROC-01"], evidence=["La Rocca fu costruita dai Malatesta nel 1380 ed è patrimonio UNESCO."],
    ))
    assert not res.ok
    assert any(e.startswith("evidence_not_exact") for e in res.errors)


def test_rejects_unknown_fact_id():
    res = run(q("Per iniziativa di chi fu avviata la costruzione?", ["Galeotto Malatesta", "Cesare Borgia", "Federico Barbarossa", "Leonardo da Vinci"],
                0, ["ROC-01"], evidence=[ROCCA["ROC-01"].text_it]).model_copy(update={"factIds": ["ROC-99"]}))
    assert not res.ok
    assert "unknown_fact_id:ROC-99" in res.errors


def test_rejects_wrong_language():
    res = run(q(
        "Who started the construction of the New Fortress in 1380?",
        ["Galeotto Malatesta", "Cesare Borgia", "Federico Barbarossa", "Leonardo da Vinci"],
        0, ["ROC-01"],
    ), lang="it")
    assert not res.ok
    assert any(e.startswith("wrong_language") for e in res.errors)


def test_rejects_negative_question():
    res = run(q(
        "Quale di queste NON è una data presente nella storia della Rocca?",
        ["1999", "1380", "1527", "1969"], 0, ["ROC-01"],
    ))
    assert not res.ok


def test_rejects_wrong_option_stated_in_fact():
    # Due opzioni corrette: la seconda compare nel fatto citato.
    facts = FACTS["palazzo_ridotto"].by_id()
    question = LlmQuestion(
        question="Quale segnale di sirena fu imposto dal comando tedesco nel settembre 1944?",
        options=["allarme", "cessato allarme", "suono delle campane", "nessun segnale"],
        correctIndex=0, factIds=["RID-07"], evidence=[facts["RID-07"].text_it],
    )
    res = check_question(question, language="it", allowed_facts=facts, place_name="Palazzo del Ridotto", n_options=4)
    assert not res.ok
    assert any(e.startswith("wrong_option_stated_in_fact") for e in res.errors)


def test_numbers_normalisation_and_near_duplicate():
    assert numbers_in("1.800 feriti e 1,800 injured, 8ª brigata") == {"1800", "8"}
    assert near_duplicate("Chi avviò la costruzione della Rocca Nuova?", "Chi ha avviato la costruzione della Rocca Nuova?")
    assert not near_duplicate("Chi avviò la costruzione della Rocca Nuova?", "Fino a quando la Rocca fu un carcere?")
