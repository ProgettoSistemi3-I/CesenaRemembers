"""Costruzione del prompt vincolato.

Principi:
- il modello riceve SOLO i fatti verificati selezionati (in lingua richiesta);
- la difficoltà cambia il tipo di ragionamento, non la quantità di dettagli;
- ogni domanda cita gli ID dei fatti e copia il testo esatto come evidence.
"""

from __future__ import annotations

from facts_loader import Fact

# Mappatura XP -> livello: stessi limiti del vecchio main.py
# (<=200, <=400, <=600, oltre). XP negativi trattati come 0.
def difficulty_level(user_xp: int) -> int:
    xp = max(0, user_xp)
    if xp <= 200:
        return 1
    if xp <= 400:
        return 2
    if xp <= 600:
        return 3
    return 4


LEVEL_INSTRUCTIONS = {
    1: (
        "RECOGNITION. Each question asks the player to recognise something stated "
        "explicitly in ONE fact (who, what, where, which). Never ask when something "
        "happened. Cite exactly one fact."
    ),
    2: (
        "COMPREHENSION. Each question asks what a fact means: the purpose, function "
        "or role of the place or of something described, rephrased in your own words. "
        "The correct answer must still be stated in the cited fact. Cite one fact."
    ),
    3: (
        "CAUSE AND EFFECT. Each question connects two pieces of information that the "
        "facts give explicitly (for example an event and its stated consequence, or "
        "two related facts). Use a causal link ONLY if a fact states it in words; "
        "otherwise ask about the relation in place or purpose, never in time. "
        "Cite one or two facts."
    ),
    4: (
        "SYNTHESIS. Each question combines TWO facts to ask about a person, place, "
        "structure, institution, function, cause or consequence that is certain from "
        "the cited facts together (for example: which structure is described by one "
        "fact AND is affected as stated by another; what two facts together say about "
        "the role or purpose of the place). It must not be a guess and must not add any "
        "event, person, date or number. Never ask which event came first or later, "
        "never ask for a date or a year, and never ask the player to compare or order "
        "dates. Cite exactly two facts (one if a second does not fit)."
    ),
}

LANGUAGE_NAMES = {"it": "Italian", "en": "English"}

SYSTEM_PROMPT = """You write multiple-choice questions for a historical walking-tour app about the city of Cesena (Italy).
You are NOT a historian here: you only rephrase the FACTS you are given.
Hard rules:
1. Use ONLY the numbered FACTS. Do not use your own knowledge, not even to add context.
2. Never invent or change dates, numbers, names, people, places, military units or causal links. Every date, number and proper name in a question or in its correct answer must appear in the cited fact(s).
3. The question text must not contain any premise that is not stated in the cited fact(s).
4. Exactly one option is correct according to the cited fact(s). Wrong options must be plausible but clearly wrong according to the FACTS; never make a wrong option that some FACT says is true. The wrong options may be invented: they do not have to come from the FACTS. Make them plausible and of the same kind as the correct answer (same type of thing, similar length and grammatical form), for example a different year, a different kind of building or a different group of people. Never use a real person, event or place from your own knowledge as a wrong option unless it appears in the FACTS. Never use another name of the correct answer as a wrong option: if a FACT says that A is also called B (or "detta", "known as"), A and B are the same thing.
5. No negative questions (no "NOT", "EXCEPT", "NON", "TRANNE"), no trick questions, no questions whose answer is the place name or the city.
6. For each question copy into "evidence" the full text of every cited fact, character by character, exactly as written in the list, and put their IDs in "factIds" in the same order.
7. Each question must be based on a different main fact (the first ID in "factIds" must differ between questions).
8. If the FACTS are not enough for a question, do not invent anything.
9. NEVER write a question whose answer is read off a date. Forbidden: asking for a date, year, month, century or "when"; asking which event happened first, later, before or after another; choosing between statements or events by comparing their dates; options that are only dates or years; options that differ only in their dates. A date may appear inside the question as context, and a date may appear in an option only when it is not what separates the right answer from the wrong ones. Ask about who, what, where, why, purpose, function, cause or consequence instead.
10. Never mention "the facts", "the sources" or "the information provided" in a question or an option, and never use options such as "not specified", "cannot be determined" or "none of the above".
11. Reply with JSON only, matching the requested schema."""


def build_user_prompt(
    *,
    place_name: str,
    language: str,
    level: int,
    facts: list[Fact],
    n_questions: int,
    n_options: int,
) -> str:
    lang_name = LANGUAGE_NAMES[language]
    fact_lines = "\n".join(f"[{f.id}] {f.text(language)}" for f in facts)
    example = (
        '{"questions":[{"question":"...","options":['
        + ",".join(['"..."'] * n_options)
        + '],"correctIndex":0,"factIds":["XXX-00"],"evidence":["<exact text of fact XXX-00>"]}]}'
    )
    return f"""PLACE: {place_name}
OUTPUT LANGUAGE: {lang_name} ({language}). Write every question and every option in {lang_name}. Keep official names of places, people and institutions as they appear in the facts.
DIFFICULTY LEVEL {level}: {LEVEL_INSTRUCTIONS[level]}
Difficulty comes from the reasoning required, never from extra or more specific details. Never from dates: no question may be answered by looking at a date.

FACTS (the only allowed information):
{fact_lines}

TASK: write exactly {n_questions} question(s), each with exactly {n_options} options and a 0-based "correctIndex".
JSON shape: {example}"""


def llm_json_schema(n_questions: int, n_options: int) -> dict:
    """JSON Schema per la generazione strutturata (Groq strict / Gemini).

    In modalità strict tutti i campi devono essere required e
    additionalProperties=false. Volutamente NON usa minItems/maxItems, che
    non tutti i provider accettano in modalità strict: i conteggi esatti
    (domande, opzioni, fatti citati) sono imposti dal prompt e verificati
    dalla validazione lato server. I parametri restano per documentazione.
    """
    return {
        "type": "object",
        "additionalProperties": False,
        "required": ["questions"],
        "properties": {
            "questions": {
                "type": "array",
                "items": {
                    "type": "object",
                    "additionalProperties": False,
                    "required": ["question", "options", "correctIndex", "factIds", "evidence"],
                    "properties": {
                        "question": {"type": "string"},
                        "options": {
                            "type": "array",
                            "items": {"type": "string"},
                        },
                        "correctIndex": {"type": "integer"},
                        "factIds": {
                            "type": "array",
                            "items": {"type": "string"},
                        },
                        "evidence": {
                            "type": "array",
                            "items": {"type": "string"},
                        },
                    },
                },
            }
        },
    }
