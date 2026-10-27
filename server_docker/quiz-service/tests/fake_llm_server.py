"""Provider finto compatibile OpenAI, SOLO per i test locali.

Non fa parte del servizio e non viene mai usato in produzione: serve a
verificare retry, timeout, validazione e codici HTTP senza chiavi reali.
Il comportamento si sceglie con il nome del modello (LLM_MODEL):

  fake-good          domande valide costruite dai fatti presenti nel prompt
  fake-hallucinate   domande con date/unità inventate (devono essere scartate)
  fake-mixed         1a chiamata: 1 domanda inventata + 2 valide; poi valide
  fake-badjson       JSON non valido
  fake-400json       errore 400 json_validate_failed (come in produzione)
  fake-429           limite di richieste
  fake-401           credenziali non valide
  fake-500once       errore 500 alla prima chiamata, poi valido
  fake-slow          risponde dopo 20 s (oltre il timeout)

Avvio: uvicorn fake_llm_server:app --port 9100
"""

from __future__ import annotations

import asyncio
import json
import re

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI()
CALLS: dict[str, int] = {}

FACT_LINE = re.compile(r"^\[([A-Z]{3}-\d{2})\] (.+)$", re.MULTILINE)


def _clip(text: str, n: int = 190) -> str:
    return text if len(text) <= n else text[:n].rsplit(" ", 1)[0]


def _good_questions(prompt: str, n: int, n_options: int) -> list[dict]:
    lang_en = "OUTPUT LANGUAGE: English" in prompt
    facts = FACT_LINE.findall(prompt)
    out = []
    stems_en = ["Which of the following statements is reported by the historical sources about this place?",
                "According to the documents, what is true of this site?",
                "What do the records tell us about this location?"]
    stems_it = ["Quale di queste affermazioni è riportata dalle fonti storiche su questo luogo?",
                "Secondo i documenti, che cosa è vero di questo sito?",
                "Che cosa raccontano le testimonianze archivistiche riguardo a questa tappa?"]
    for i, (fid, text) in enumerate(facts[:n]):
        if lang_en:
            question = stems_en[i % 3]
            wrong = ["None of the sources reports anything about it", "The place was built only after the war",
                     "The place never had any role in the history of the city"]
        else:
            question = stems_it[i % 3]
            wrong = ["Nessuna fonte riporta notizie in proposito", "Il luogo fu costruito soltanto dopo la guerra",
                     "Il luogo non ebbe alcun ruolo nella storia della città"]
        options = [_clip(text)] + wrong[: n_options - 1]
        out.append({"question": question, "options": options, "correctIndex": 0,
                    "factIds": [fid], "evidence": [text]})
    return out


def _hallucinated(n: int, n_options: int, fid: str, text: str) -> list[dict]:
    q = {"question": "Quale unità americana liberò la Rocca il 25 aprile 1945?",
         "options": ["La 1ª Divisione di fanteria", "La 5ª Armata", "La 8ª Armata", "Nessuna"][:n_options],
         "correctIndex": 0, "factIds": [fid], "evidence": [text]}
    return [dict(q) for _ in range(n)]


def _ok(content: str) -> JSONResponse:
    return JSONResponse({
        "id": "fake", "object": "chat.completion",
        "choices": [{"index": 0, "message": {"role": "assistant", "content": content}, "finish_reason": "stop"}],
        "usage": {"prompt_tokens": 900, "completion_tokens": 500, "total_tokens": 1400},
    })


@app.post("/v1/chat/completions")
async def completions(request: Request):
    body = await request.json()
    model = body.get("model", "fake-good")
    CALLS[model] = CALLS.get(model, 0) + 1
    call_no = CALLS[model]
    prompt = body["messages"][-1]["content"]
    n = int(re.search(r"write exactly (\d+) question", prompt).group(1))
    n_options = int(re.search(r"each with exactly (\d+) options", prompt).group(1))
    facts = FACT_LINE.findall(prompt)

    if model == "fake-slow":
        await asyncio.sleep(20)
    if model == "fake-401":
        return JSONResponse({"error": {"message": "Invalid API Key", "type": "invalid_request_error", "code": "invalid_api_key"}}, status_code=401)
    if model == "fake-429":
        return JSONResponse({"error": {"message": "Rate limit reached for model in tokens per minute (TPM)", "type": "tokens", "code": "rate_limit_exceeded"}}, status_code=429)
    if model == "fake-400json":
        return JSONResponse({"error": {"message": "Failed to validate JSON", "type": "invalid_request_error", "code": "json_validate_failed", "failed_generation": ""}}, status_code=400)
    if model == "fake-500once" and call_no % 2 == 1:
        return JSONResponse({"error": {"message": "internal"}}, status_code=500)
    if model == "fake-badjson":
        return _ok('{"questions": [ {"question": "Domanda senza chiusura"')
    if model == "fake-hallucinate":
        return _ok(json.dumps({"questions": _hallucinated(n, n_options, *facts[0])}, ensure_ascii=False))
    if model == "fake-mixed" and n == 3:
        good = _good_questions(prompt, 3, n_options)[1:]
        bad = _hallucinated(1, n_options, *facts[-1])
        return _ok(json.dumps({"questions": bad + good}, ensure_ascii=False))
    return _ok(json.dumps({"questions": _good_questions(prompt, n, n_options)}, ensure_ascii=False))
