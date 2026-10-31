"""Cesena Remembers — servizio di generazione dei quiz.

Flusso di ogni richiesta POST /api/generate-quiz (contratto invariato):
  1. validazione dei parametri (Pydantic) e del POI (whitelist);
  2. lettura dei fatti verificati dalla memoria (caricati all'avvio da facts/);
  3. selezione casuale di un sottoinsieme di fatti (varietà + prompt breve);
  4. UNA chiamata al modello per 3 domande, con output strutturato;
  5. validazione strutturale e storica di ogni domanda;
  6. se mancano domande valide e resta tempo: UNA chiamata di riparazione
     che chiede solo le domande mancanti, su fatti non ancora usati;
  7. 200 solo con 3 domande valide; altrimenti errore HTTP non-200, che
     nell'app attiva il fallback locale (HistoricPlacesSeed).

Il quiz è generato a ogni richiesta: non esiste alcun archivio di domande.
"""

from __future__ import annotations

import asyncio
from collections import deque
import json
import logging
import random
import time
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from dotenv import load_dotenv
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

load_dotenv()

from config import load_settings  # noqa: E402  (dopo load_dotenv)
from facts_loader import KNOWN_POI_IDS, Fact, load_all  # noqa: E402
from llm_client import LlmClient, LlmError  # noqa: E402
from models import PoiRequest, QuizMeta, QuizQuestionOut, QuizResponse  # noqa: E402
from prompts import SYSTEM_PROMPT, build_user_prompt, difficulty_level, llm_json_schema  # noqa: E402
from validation import StructuralError, check_question, near_duplicate, parse_llm_output  # noqa: E402

N_QUESTIONS = 3  # requisito di progetto: esattamente tre domande

settings = load_settings()
logging.basicConfig(
    level=getattr(logging, settings.log_level, logging.INFO),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger("quiz")


class QuizFailure(Exception):
    """Fallimento che deve produrre una risposta non-200 (=> fallback nell'app)."""

    def __init__(self, status: int, code: str, message: str):
        super().__init__(message)
        self.status = status
        self.code = code
        self.message = message


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.facts = load_all(settings.facts_dir)
    app.state.llm = LlmClient(settings)
    app.state.inflight = {}
    app.state.rate_limits = {}
    logger.info(
        "Avvio: provider=%s model=%s key=%s schede=%s",
        settings.provider,
        settings.model,
        "configurata" if settings.key_configured else "MANCANTE",
        {k: len(v.facts) for k, v in app.state.facts.items()},
    )
    yield
    await app.state.llm.aclose()


app = FastAPI(title="Cesena Remembers - Quiz API", lifespan=lifespan)
# L'app Flutter nativa non usa CORS. Se in futuro viene chiamata da un browser,
# impostare QUIZ_CORS_ORIGINS con una lista esplicita di origini autorizzate.
_cors_origins = [origin.strip() for origin in __import__("os").getenv("QUIZ_CORS_ORIGINS", "").split(",") if origin.strip()]
if _cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=_cors_origins,
        allow_credentials=False,
        allow_methods=["POST", "GET", "OPTIONS"],
        allow_headers=["Content-Type"],
    )


@app.exception_handler(QuizFailure)
async def _quiz_failure_handler(_: Request, exc: QuizFailure):
    return JSONResponse(status_code=exc.status, content={"detail": {"error": exc.code, "message": exc.message}})


# ---------------------------------------------------------------------------
# Generazione
# ---------------------------------------------------------------------------
def _select_facts(facts: list[Fact], k: int, exclude: set[str]) -> list[Fact]:
    pool = [f for f in facts if f.id not in exclude]
    random.shuffle(pool)
    return pool[: min(k, len(pool))]


def _shuffle_options(options: list[str], correct_index: int) -> tuple[list[str], int]:
    """Mescola le opzioni lato server: la posizione della risposta corretta
    diventa uniforme indipendentemente dalle abitudini del modello."""
    order = list(range(len(options)))
    random.shuffle(order)
    return [options[i] for i in order], order.index(correct_index)


async def _generate(req: PoiRequest, request_id: str) -> QuizResponse:
    started = time.perf_counter()
    deadline = started + settings.request_deadline_s
    poi_facts = app.state.facts.get(req.id)
    if poi_facts is None:  # protetto anche dall'endpoint, difesa in profondità
        raise QuizFailure(404, "unknown_poi", "POI sconosciuto")
    if len(poi_facts.facts) < N_QUESTIONS:
        raise QuizFailure(503, "insufficient_facts", "Fatti verificati insufficienti per tre domande")
    if not settings.key_configured:
        raise QuizFailure(503, "missing_api_key", "Provider non configurato")

    level = difficulty_level(req.userXp)
    lang = req.languageCode
    # Non usare mai nomi/descrizioni provenienti dal client nel prompt.
    place_name = poi_facts.title
    schema = llm_json_schema(N_QUESTIONS, settings.options_per_question)

    accepted: list[tuple] = []  # (LlmQuestion, list[str] warnings)
    used_fact_ids: set[str] = set()
    attempts: list[dict] = []
    last_error: LlmError | StructuralError | None = None

    for call_no in range(1, settings.max_llm_calls + 1):
        missing = N_QUESTIONS - len(accepted)
        if missing <= 0:
            break
        remaining = deadline - time.perf_counter()
        if remaining < settings.min_call_budget_s:
            attempts.append({"call": call_no, "skipped": "no_time_left", "remaining_s": round(remaining, 2)})
            break

        selected = _select_facts(poi_facts.facts, settings.facts_per_prompt, used_fact_ids)
        if len(selected) < missing:
            attempts.append({"call": call_no, "skipped": "not_enough_unused_facts"})
            break
        allowed = {f.id: f for f in selected}
        user_prompt = build_user_prompt(
            place_name=place_name,
            language=lang,
            level=level,
            facts=selected,
            n_questions=missing,
            n_options=settings.options_per_question,
        )
        attempt = {"call": call_no, "asked": missing, "facts": len(selected)}
        try:
            result = await app.state.llm.complete(
                system=SYSTEM_PROMPT,
                user=user_prompt,
                schema=schema,
                timeout_s=min(settings.llm_timeout_s, remaining - 0.3),
            )
            attempt["llm_s"] = round(result.latency_s, 2)
            attempt["usage"] = {k: result.usage.get(k) for k in ("prompt_tokens", "completion_tokens") if k in result.usage}
            questions = parse_llm_output(
                result.content, expected_questions=missing, n_options=settings.options_per_question
            )
        except LlmError as exc:
            attempt["error"] = exc.code
            attempts.append(attempt)
            last_error = exc
            logger.warning("[%s] call %d: %s (%s)", request_id, call_no, exc.code, exc)
            if not exc.retryable:
                break
            continue
        except StructuralError as exc:
            attempt["error"] = exc.code
            attempts.append(attempt)
            last_error = exc
            logger.warning("[%s] call %d: output non valido: %s", request_id, call_no, exc)
            continue

        rejected = []
        for q in questions:
            check = check_question(
                q,
                language=lang,
                allowed_facts=allowed,
                place_name=place_name,
                n_options=settings.options_per_question,
            )
            main_fact = q.factIds[0].strip() if q.factIds else ""
            if check.ok and main_fact in used_fact_ids:
                check.ok = False
                check.errors.append("main_fact_already_used")
            if check.ok and any(near_duplicate(q.question, a.question) for a, _ in accepted):
                check.ok = False
                check.errors.append("near_duplicate_question")
            if check.ok and len(accepted) < N_QUESTIONS:
                accepted.append((q, check.warnings))
                used_fact_ids.update(fid.strip() for fid in q.factIds)
            else:
                rejected.append({"factIds": q.factIds, "errors": check.errors})
                # i fatti di una domanda scartata non vengono riproposti subito
                used_fact_ids.update(fid.strip() for fid in q.factIds if fid.strip() in allowed)
        attempt["accepted"] = len(questions) - len(rejected)
        if rejected:
            attempt["rejected"] = rejected
        attempts.append(attempt)

    elapsed = time.perf_counter() - started
    log_record = {
        "request_id": request_id,
        "poi": req.id,
        "lang": lang,
        "xp": req.userXp,
        "level": level,
        "model": settings.model,
        "elapsed_s": round(elapsed, 2),
        "accepted": len(accepted),
        "attempts": attempts,
    }

    if len(accepted) < N_QUESTIONS:
        log_record["outcome"] = "failed"
        logger.warning("quiz %s", json.dumps(log_record, ensure_ascii=False))
        if isinstance(last_error, LlmError):
            if last_error.code == "timeout" or (deadline - time.perf_counter()) < settings.min_call_budget_s:
                raise QuizFailure(504, last_error.code, "Il modello non ha risposto entro il tempo previsto")
            raise QuizFailure(503, last_error.code, "Generazione non disponibile")
        if isinstance(last_error, StructuralError) and not accepted:
            raise QuizFailure(503, last_error.code, "Il modello ha restituito un output non valido")
        if time.perf_counter() >= deadline - settings.min_call_budget_s and not accepted:
            raise QuizFailure(504, "deadline_exceeded", "Tempo massimo di generazione superato")
        raise QuizFailure(503, "validation_failed", "Il quiz generato non ha superato i controlli")

    out_questions = []
    for q, warnings in accepted:
        options, correct = _shuffle_options([o.strip() for o in q.options], q.correctIndex)
        out_questions.append(
            QuizQuestionOut(
                question=q.question.strip(),
                options=options,
                correctIndex=correct,
                evidence=" | ".join(app.state.facts[req.id].by_id()[fid.strip()].text(lang) for fid in q.factIds),
                factIds=[fid.strip() for fid in q.factIds],
            )
        )
        if warnings:
            log_record.setdefault("warnings", []).append({"factIds": q.factIds, "warnings": warnings})
    log_record["outcome"] = "ok"
    logger.info("quiz %s", json.dumps(log_record, ensure_ascii=False))
    return QuizResponse(
        questions=out_questions,
        meta=QuizMeta(
            poiId=req.id,
            language=lang,
            difficultyLevel=level,
            model=settings.model,
            generatedAt=datetime.now(timezone.utc).isoformat(timespec="seconds"),
        ),
    )


# ---------------------------------------------------------------------------
# Endpoint
# ---------------------------------------------------------------------------
@app.post("/api/generate-quiz", response_model=QuizResponse)
async def generate_quiz(poi: PoiRequest, request: Request):
    # Rate limit per IP: protegge da tap/loop eccessivi senza trasmettere
    # Firebase ID token in chiaro sull'endpoint HTTP del progetto.
    now = time.monotonic()
    address = request.client.host if request.client else "unknown"
    rate_limits: dict[str, deque[float]] = app.state.rate_limits
    bucket = rate_limits.get(address)

    # I bucket inattivi vengono rimossi quando serve spazio. Il dizionario ha
    # una dimensione massima: non può crescere senza limite con IP casuali.
    max_clients = max(100, int(__import__("os").getenv("QUIZ_RATE_LIMIT_MAX_CLIENTS", "10000")))
    if bucket is None and len(rate_limits) >= max_clients:
        for client_ip, client_bucket in list(rate_limits.items()):
            while client_bucket and now - client_bucket[0] > 60:
                client_bucket.popleft()
            if not client_bucket:
                rate_limits.pop(client_ip, None)
        if len(rate_limits) >= max_clients:
            raise QuizFailure(429, "rate_limit_capacity", "Servizio temporaneamente occupato. Riprova tra poco.")
        bucket = deque()
        rate_limits[address] = bucket
    elif bucket is None:
        bucket = deque()
        rate_limits[address] = bucket

    while bucket and now - bucket[0] > 60:
        bucket.popleft()
    limit_per_minute = max(1, int(__import__("os").getenv("QUIZ_RATE_LIMIT_PER_MINUTE", "30")))
    if len(bucket) >= limit_per_minute:
        raise QuizFailure(429, "rate_limited", "Troppe richieste. Riprova tra poco.")
    bucket.append(now)

    if poi.id not in KNOWN_POI_IDS:
        # Nessun accesso a file costruiti dall'input: l'ID deve essere in whitelist.
        raise QuizFailure(404, "unknown_poi", "POI sconosciuto")

    # Richieste identiche contemporanee (es. doppio tap o retry di rete mentre
    # la prima è ancora in corso) condividono la stessa generazione. Appena
    # conclusa, la chiave viene rimossa: nessun riuso dei quiz.
    key = (poi.id, poi.userXp, poi.languageCode)
    inflight: dict = app.state.inflight
    task = inflight.get(key)
    if task is None:
        request_id = f"{int(time.time() * 1000) % 10_000_000:07d}"
        task = asyncio.ensure_future(_generate(poi, request_id))
        inflight[key] = task
        task.add_done_callback(lambda _t, k=key: inflight.pop(k, None))
    try:
        return await asyncio.shield(task)
    except QuizFailure:
        raise
    except Exception:
        logger.exception("Errore interno nella generazione quiz")
        raise QuizFailure(500, "quiz_generation_failed", "Impossibile generare il quiz in questo momento")


@app.get("/")
async def root():
    return {"status": "Il server dei quiz di Cesena Remembers è online!"}


@app.get("/health")
async def health():
    facts = app.state.facts
    return {
        "status": "ok",
        "placesConfigured": len(facts),
        "questionsPerQuiz": N_QUESTIONS,
    }
