"""Configurazione del servizio tramite variabili d'ambiente.

Nessuna chiave è scritta nel codice: le chiavi arrivano da .env (letto da
docker-compose con env_file) o dall'ambiente del container.
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

# Preset dei provider compatibili con l'API OpenAI "chat/completions".
# Per cambiare provider basta LLM_PROVIDER (+ chiave); per casi particolari
# si possono sovrascrivere LLM_BASE_URL e LLM_MODEL.
PROVIDER_PRESETS: dict[str, dict[str, str]] = {
    "groq": {
        "base_url": "https://api.groq.com/openai/v1",
        "model": "openai/gpt-oss-120b",
        "key_env": "GROQ_API_KEY",
        "reasoning_effort": "low",
        "response_format": "json_schema_strict",
    },
    "gemini": {
        # Endpoint OpenAI-compatibile ufficiale dell'API Gemini.
        "base_url": "https://generativelanguage.googleapis.com/v1beta/openai",
        "model": "gemini-2.5-flash-lite",
        "key_env": "GEMINI_API_KEY",
        "reasoning_effort": "none",
        "response_format": "json_schema",
    },
    "cerebras": {
        "base_url": "https://api.cerebras.ai/v1",
        "model": "gpt-oss-120b",
        "key_env": "CEREBRAS_API_KEY",
        "reasoning_effort": "low",
        "response_format": "json_schema_strict",
    },
    "openai_compatible": {
        "base_url": "",
        "model": "",
        "key_env": "LLM_API_KEY",
        "reasoning_effort": "",
        "response_format": "json_object",
    },
}


def _env(name: str, default: str = "") -> str:
    value = os.getenv(name)
    return value.strip() if value is not None and value.strip() != "" else default


def _env_float(name: str, default: float) -> float:
    try:
        return float(_env(name, str(default)))
    except ValueError:
        return default


def _env_int(name: str, default: int) -> int:
    try:
        return int(_env(name, str(default)))
    except ValueError:
        return default


@dataclass(frozen=True)
class Settings:
    provider: str
    base_url: str
    model: str
    api_key: str
    reasoning_effort: str
    response_format: str  # json_schema_strict | json_schema | json_object
    temperature: float
    max_tokens: int
    llm_timeout_s: float
    request_deadline_s: float
    min_call_budget_s: float
    max_llm_calls: int
    options_per_question: int
    facts_per_prompt: int
    facts_dir: Path
    log_level: str

    @property
    def key_configured(self) -> bool:
        return bool(self.api_key)


def load_settings() -> Settings:
    provider = _env("LLM_PROVIDER", "groq").lower()
    preset = PROVIDER_PRESETS.get(provider, PROVIDER_PRESETS["openai_compatible"])
    api_key = _env("LLM_API_KEY") or _env(preset["key_env"])
    options = _env_int("QUIZ_OPTIONS", 4)
    if options not in (3, 4):
        options = 4
    # "off" = non inviare il parametro (per modelli che non lo supportano).
    reasoning = _env("LLM_REASONING_EFFORT", preset["reasoning_effort"]).lower()
    if reasoning == "off":
        reasoning = ""
    return Settings(
        provider=provider,
        base_url=_env("LLM_BASE_URL", preset["base_url"]).rstrip("/"),
        model=_env("LLM_MODEL", preset["model"]),
        api_key=api_key,
        reasoning_effort=reasoning,
        response_format=_env("LLM_RESPONSE_FORMAT", preset["response_format"]),
        temperature=_env_float("LLM_TEMPERATURE", 0.5),
        max_tokens=_env_int("LLM_MAX_TOKENS", 2000),
        # Il client Flutter abbandona la richiesta dopo 12 s
        # (quiz_repository_impl.dart, _requestTimeout). Il server deve
        # chiudere prima, per restituire un errore pulito invece di un timeout.
        llm_timeout_s=_env_float("LLM_TIMEOUT_S", 7.0),
        request_deadline_s=_env_float("REQUEST_DEADLINE_S", 9.5),
        min_call_budget_s=_env_float("MIN_CALL_BUDGET_S", 2.5),
        max_llm_calls=max(1, min(3, _env_int("MAX_LLM_CALLS", 2))),
        options_per_question=options,
        facts_per_prompt=max(3, _env_int("FACTS_PER_PROMPT", 10)),
        facts_dir=Path(_env("FACTS_DIR", str(Path(__file__).parent / "facts"))),
        log_level=_env("LOG_LEVEL", "INFO").upper(),
    )
