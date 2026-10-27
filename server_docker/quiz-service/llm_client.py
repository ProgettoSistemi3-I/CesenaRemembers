"""Client asincrono per API compatibili OpenAI (Groq, Gemini, Cerebras...).

Perché httpx e non l'SDK groq:
- la chiamata è davvero asincrona (il vecchio codice chiamava l'SDK
  sincrono dentro un endpoint async, bloccando l'event loop);
- timeout esplicito per chiamata;
- NESSUN retry automatico nascosto (gli SDK generati ritentano i 429/5xx
  con backoff, il che può spiegare parte dei 30–60 s osservati): i retry
  sono decisi dal servizio entro il budget di tempo della richiesta;
- un solo codice per più provider: si cambia provider via variabili d'ambiente.
"""

from __future__ import annotations

import json
import time
from dataclasses import dataclass

import httpx

from config import Settings


class LlmError(Exception):
    """Errore di generazione. `retryable` indica se ha senso riprovare."""

    def __init__(self, code: str, message: str, *, retryable: bool, http_status: int | None = None):
        super().__init__(message)
        self.code = code
        self.retryable = retryable
        self.http_status = http_status


@dataclass
class LlmResult:
    content: str
    latency_s: float
    usage: dict


class LlmClient:
    def __init__(self, settings: Settings):
        self.settings = settings
        self._client = httpx.AsyncClient(
            base_url=settings.base_url,
            headers={"Content-Type": "application/json"},
            limits=httpx.Limits(max_connections=20, max_keepalive_connections=10),
        )

    async def aclose(self) -> None:
        await self._client.aclose()

    def _response_format(self, schema: dict) -> dict:
        mode = self.settings.response_format
        if mode in ("json_schema_strict", "json_schema"):
            return {
                "type": "json_schema",
                "json_schema": {
                    "name": "quiz",
                    "schema": schema,
                    "strict": mode == "json_schema_strict",
                },
            }
        return {"type": "json_object"}

    async def complete(self, *, system: str, user: str, schema: dict, timeout_s: float) -> LlmResult:
        s = self.settings
        if not s.api_key:
            raise LlmError("missing_api_key", "Chiave API non configurata", retryable=False)
        payload: dict = {
            "model": s.model,
            "messages": [
                {"role": "system", "content": system},
                {"role": "user", "content": user},
            ],
            "temperature": s.temperature,
            "max_tokens": s.max_tokens,
            "response_format": self._response_format(schema),
        }
        if s.reasoning_effort:
            payload["reasoning_effort"] = s.reasoning_effort

        started = time.perf_counter()
        try:
            resp = await self._client.post(
                "/chat/completions",
                json=payload,
                headers={"Authorization": f"Bearer {s.api_key}"},
                timeout=httpx.Timeout(timeout_s, connect=min(3.0, timeout_s)),
            )
        except httpx.TimeoutException as exc:
            raise LlmError("timeout", f"Timeout del provider dopo {timeout_s:.1f}s", retryable=True) from exc
        except httpx.HTTPError as exc:
            raise LlmError("provider_unreachable", f"Errore di rete: {type(exc).__name__}", retryable=True) from exc
        latency = time.perf_counter() - started

        if resp.status_code != 200:
            raise self._classify_http_error(resp)

        try:
            data = resp.json()
            message = data["choices"][0]["message"]
            content = message.get("content") or ""
        except (ValueError, KeyError, IndexError, TypeError) as exc:
            raise LlmError("bad_provider_response", "Risposta del provider non interpretabile", retryable=True) from exc
        if not content.strip():
            # Succede se il budget di token viene consumato dal ragionamento.
            raise LlmError("empty_content", "Il modello ha restituito un contenuto vuoto", retryable=True)
        return LlmResult(content=content, latency_s=latency, usage=data.get("usage") or {})

    @staticmethod
    def _classify_http_error(resp: httpx.Response) -> LlmError:
        status = resp.status_code
        try:
            body = resp.json()
            err = body.get("error", body) if isinstance(body, dict) else {}
            err_code = str(err.get("code") or err.get("type") or "")
            err_msg = str(err.get("message") or "")[:300]
        except ValueError:
            err_code, err_msg = "", resp.text[:300]

        if status in (401, 403):
            return LlmError("provider_auth", f"Credenziali rifiutate ({status})", retryable=False, http_status=status)
        if status == 429:
            return LlmError("provider_rate_limited", f"Limite di richieste/token del provider: {err_msg}", retryable=False, http_status=status)
        if status == 400 and ("json_validate_failed" in err_code or "json_validate_failed" in err_msg
                              or "structured" in err_code or "failed_generation" in json.dumps(err_msg)):
            # Errore già visto in produzione: il modello ha prodotto JSON non conforme.
            return LlmError("json_validate_failed", f"Generazione strutturata fallita: {err_msg}", retryable=True, http_status=status)
        if status == 400:
            # Parametri non accettati (modello inesistente, schema non supportato...):
            # è un problema di configurazione, riprovare non serve.
            return LlmError("provider_bad_request", f"Richiesta rifiutata: {err_code} {err_msg}", retryable=False, http_status=status)
        if status == 404:
            return LlmError("provider_model_not_found", f"Modello o endpoint inesistente: {err_msg}", retryable=False, http_status=status)
        if status >= 500:
            return LlmError("provider_unavailable", f"Errore temporaneo del provider ({status})", retryable=True, http_status=status)
        return LlmError("provider_error", f"Errore del provider ({status}): {err_msg}", retryable=False, http_status=status)
