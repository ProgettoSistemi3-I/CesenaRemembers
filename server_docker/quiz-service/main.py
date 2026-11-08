"""Cesena Remembers — servizio di generazione dei quiz.

Flusso di ogni richiesta POST /api/generate-quiz:
  1. verifica server-side dell'ID token Firebase;
  2. validazione dei parametri e del POI (whitelist);
  3. lettura dei fatti verificati dalla memoria;
  4. generazione e validazione di tre domande.

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

import firebase_admin
from dotenv import load_dotenv
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.concurrency import run_in_threadpool
from firebase_admin import auth as firebase_auth

load_dotenv()

from config import load_settings  # noqa: E402
from facts_loader import KNOWN_POI_IDS, Fact, load_all  # noqa: E402
from llm_client import LlmClient, LlmError  # noqa: E402
from models import PoiRequest, QuizMeta, QuizQuestionOut, QuizResponse  # noqa: E402
from prompts import SYSTEM_PROMPT, build_user_prompt, difficulty_level, llm_json_schema  # noqa: E402
from validation import StructuralError, check_question, near_duplicate, parse_llm_output  # noqa: E402

N_QUESTIONS = 3
FIREBASE_APP_NAME = "cesena-remembers-quiz"

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


def _get_firebase_app():
    """Inizializza Firebase Admin senza una chiave privata di servizio.

    La verifica degli ID token usa il project ID e i certificati pubblici
    Google. Non vengono eseguite operazioni amministrative sugli account.
    """
    try:
        firebase_app = firebase_admin.get_app(FIREBASE_APP_NAME)
    except ValueError:
        firebase_app = firebase_admin.initialize_app(
            options={"projectId": settings.firebase_project_id},
            name=FIREBASE_APP_NAME,
        )

    if firebase_app.project_id != settings.firebase_project_id:
        raise RuntimeError(
            "Il Firebase project ID dell'app Admin non corrisponde alla configurazione."
        )
    return firebase_app


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.firebase_app = _get_firebase_app()
    app.state.facts = load_all(settings.facts_dir)
    app.state.llm = LlmClient(settings)
    app.state.inflight = {}
    app.state.rate_limits = {}
    app.state.user_rate_limits = {}
    logger.info(
        "Avvio: provider=%s model=%s key=%s firebase_project=%s schede=%s",
        settings.provider,
        settings.model,
        "configurata" if settings.key_configured else "MANCANTE",
        settings.firebase_project_id,
        {k: len(v.facts) for k, v in app.state.facts.items()},
    )
    yield
    await app.state.llm.aclose()


app = FastAPI(title="Cesena Remembers - Quiz API", lifespan=lifespan)
# L'app Flutter nativa non usa CORS. Se in futuro viene chiamata da un browser,
# impostare QUIZ_CORS_ORIGINS con una lista esplicita di origini autorizzate.
_cors_origins = [
    origin.strip()
    for origin in __import__("os").getenv("QUIZ_CORS_ORIGINS", "").split(",")
    if origin.strip()
]
if _cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=_cors_origins,
        allow_credentials=False,
        allow_methods=["POST", "GET", "OPTIONS"],
        allow_headers=["Content-Type", "Authorization"],
    )


@app.exception_handler(QuizFailure)
async def _quiz_failure_handler(_: Request, exc: QuizFailure):
    return JSONResponse(
        status_code=exc.status,
        content={"detail": {"error": exc.code, "message": exc.message}},
    )


async def _authenticate_firebase_user(request: Request) -> str:
    """Richiede e verifica un Firebase ID token per l'endpoint quiz."""
    authorization = request.headers.get("Authorization", "")
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise QuizFailure(
            401,
            "missing_auth_token",
            "È richiesto un Firebase ID token nell'header Authorization: Bearer.",
        )

    try:
        decoded_token = await run_in_threadpool(
            firebase_auth.verify_id_token,
            parts[1],
            app=request.app.state.firebase_app,
            check_revoked=False,
        )
    except (ValueError, firebase_auth.InvalidIdTokenError) as exc:
        raise QuizFailure(
            401,
            "invalid_auth_token",
            "Il Firebase ID token non è valido o è scaduto.",
        ) from exc
    except firebase_auth.CertificateFetchError as exc:
        logger.warning(
            "Verifica Firebase temporaneamente non disponibile: certificati non raggiungibili (%s)",
            type(exc).__name__,
        )
        raise QuizFailure(
            503,
            "auth_verification_unavailable",
            "Verifica dell'identità temporaneamente non disponibile.",
        ) from exc
    except Exception as exc:
        logger.exception("Errore interno durante la verifica del token Firebase")
        raise QuizFailure(
            503,
            "auth_verification_unavailable",
            "Verifica dell'identità temporaneamente non disponibile.",
        ) from exc

    uid = decoded_token.get("uid")
    if not isinstance(uid, str) or not uid.strip():
        raise QuizFailure(
            401,
            "invalid_auth_token",
            "Il token Firebase non contiene un'identità valida.",
        )
    return uid


def _consume_rate_limit(
    buckets: dict[str, deque[float]],
    key: str,
    now: float,
    *,
    limit_per_minute: int,
    max_clients: int,
    error_code: str,
    limit_message: str,
) -> None:
    """Applica una finestra mobile di 60 secondi a una chiave IP o UID."""
    bucket = buckets.get(key)
    if bucket is None and len(buckets) >= max_clients:
        for existing_key, existing_bucket in list(buckets.items()):
            while existing_bucket and now - existing_bucket[0] > 60:
                existing_bucket.popleft()
            if not existing_bucket:
                buckets.pop(existing_key, None)
        if len(buckets) >= max_clients:
            raise QuizFailure(
                429,
                "rate_limit_capacity",
                "Servizio temporaneamente occupato. Riprova tra poco.",
            )
        bucket = deque()
        buckets[key] = bucket
    elif bucket is None:
        bucket = deque()
        buckets[key] = bucket

    while bucket and now - bucket[0] > 60:
        bucket.popleft()
    if len(bucket) >= limit_per_minute:
        raise QuizFailure(429, error_code, limit_message)
    bucket.append(now)


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
    if poi_facts is None:
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

    accepted: list[tuple] = []
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
            attempt["usage"] = {
                k: result.usage.get(k)
                for k in ("prompt_tokens", "completion_tokens)
                if k in result.usage
            }
            questions = parse_llm_output(
                result.content,
                expected_questions=missing,
                n_options=settings.options_per_question,
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
    # Prima di consumare risorse LLM, il client deve dimostrare di essere
    # autenticato nello stesso progetto Firebase dell'app.
    uid = await _authenticate_firebase_user(request)

    now = time.monotonic()
    address = request.client.host if request.client else "unknown"
    max_clients = max(100, int(__import__("os").getenv("QUIZ_RATE_LIMIT_MAX_CLIENTS", "10000")))

    # Mantiene il limite per IP già presente.
    _consume_rate_limit(
        app.state.rate_limits,
        address,
        now,
        limit_per_minute=max(1, int(__import__("os").getenv("QUIZ_RATE_LIMIT_PER_MINUTE", "30"))),
        max_clients=max_clients,
        error_code="rate_limited",
        limit_message="Troppe richieste da questo indirizzo. Riprova tra poco.",
    )
    # Aggiunge un limite per UID: cambiare rete/IP non azzera la quota utente.
    _consume_rate_limit(
        app.state.user_rate_limits,
        uid,
        now,
        limit_per_minute=max(1, int(__import__("os").getenv("QUIZ_RATE_LIMIT_PER_USER_PER_MINUTE", "30"))),
        max_clients=max_clients,
        error_code="user_rate_limited",
        limit_message="Hai effettuato troppe richieste quiz. Riprova tra poco.",
    )

    if poi.id not in KNOWN_POI_IDS:
        raise QuizFailure(404, "unknown_poi", "POI sconosciuto")

    # Le richieste simultanee vengono deduplicate solo per lo stesso utente.
    key = (uid, poi.id, poi.userXp, poi.languageCode)
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
