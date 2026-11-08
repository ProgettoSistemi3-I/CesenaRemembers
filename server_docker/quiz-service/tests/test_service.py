"""Test d'integrazione del servizio con provider LLM e token Firebase finti.

Esecuzione: python -m pytest -q tests/
"""

from __future__ import annotations

import importlib
import os
import sys
import threading
import time
from pathlib import Path

import pytest
import uvicorn

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / "tests"))

FAKE_PORT = 19100
VALID_TOKEN = "valid-test-id-token"
DEFAULT_HEADERS = {"Authorization": f"Bearer {VALID_TOKEN}"}


@pytest.fixture(scope="session", autouse=True)
def fake_provider():
    import fake_llm_server

    server = uvicorn.Server(uvicorn.Config(fake_llm_server.app, host="127.0.0.1", port=FAKE_PORT, log_level="warning"))
    thread = threading.Thread(target=server.run, daemon=True)
    thread.start()
    for _ in range(100):
        if server.started:
            break
        time.sleep(0.05)
    yield
    server.should_exit = True


def make_client(model: str, **env):
    from fastapi.testclient import TestClient

    os.environ.update({
        "LLM_PROVIDER": "openai_compatible",
        "LLM_BASE_URL": f"http://127.0.0.1:{FAKE_PORT}/v1",
        "LLM_API_KEY": "test-key",
        "LLM_MODEL": model,
        "LLM_RESPONSE_FORMAT": "json_schema_strict",
        "FIREBASE_PROJECT_ID": "cesenaremembers1945",
        "LLM_TIMEOUT_S": env.pop("LLM_TIMEOUT_S", "3"),
        "REQUEST_DEADLINE_S": env.pop("REQUEST_DEADLINE_S", "5"),
        **env,
    })
    import main

    importlib.reload(main)

    # Nei test sostituiamo solo la chiamata remota, verificando che il servizio
    # richieda sempre il controllo di revoca/disabilitazione.
    from google.auth.credentials import AnonymousCredentials

    main.firebase_admin.credentials.ApplicationDefault = lambda: AnonymousCredentials()

    def fake_verify_id_token(token, app=None, check_revoked=False):
        assert check_revoked is True
        if token == VALID_TOKEN:
            return {"uid": "test-user"}
        if token == "expired-test-id-token":
            raise main.firebase_auth.ExpiredIdTokenError("expired test token", None)
        if token == "revoked-test-id-token":
            raise main.firebase_auth.RevokedIdTokenError("revoked test token")
        if token == "disabled-test-id-token":
            raise main.firebase_auth.UserDisabledError("disabled test account")
        raise main.firebase_auth.InvalidIdTokenError("invalid test token")

    main.firebase_auth.verify_id_token = fake_verify_id_token
    return TestClient(main.app, headers=DEFAULT_HEADERS)



def test_firebase_app_uses_configured_project_and_test_adc_stub():
    import main
    from google.auth.credentials import AnonymousCredentials

    # make_client replaces ApplicationDefault with this in-memory test stub;
    # production requires the separately mounted read-only Auth service account.
    with make_client("fake-good"):
        firebase_app = main._get_firebase_app()
        assert firebase_app.project_id == "cesenaremembers1945"
        assert isinstance(
            firebase_app.credential.get_credential(),
            AnonymousCredentials,
        )


BODY = {
    "id": "rocca",
    "name": "Rocca Malatestiana",
    "description": "Fortezza medievale costruita dai Malatesta nel 1380.",
    "userXp": 0,
    "languageCode": "it",
}


def test_quiz_requires_a_valid_bearer_token():
    with make_client("fake-good") as c:
        missing = c.post(
            "/api/generate-quiz",
            json=BODY,
            headers={"Authorization": ""},
        )
        assert missing.status_code == 401
        assert missing.json()["detail"]["error"] == "missing_auth_token"

        wrong_scheme = c.post(
            "/api/generate-quiz",
            json=BODY,
            headers={"Authorization": "Basic not-a-token"},
        )
        assert wrong_scheme.status_code == 401


@pytest.mark.parametrize("token", [
    "invalid-test-id-token",
    "expired-test-id-token",
    "revoked-test-id-token",
    "disabled-test-id-token",
])
def test_invalid_or_expired_firebase_token_is_rejected(token):
    with make_client("fake-good") as c:
        response = c.post(
            "/api/generate-quiz",
            json=BODY,
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 401
        assert response.json()["detail"]["error"] == "invalid_auth_token"


def test_valid_request_returns_three_questions_flutter_compatible():
    with make_client("fake-good") as c:
        for xp in (0, 300, 500, 800):
            for lang in ("it", "en"):
                r = c.post(
                    "/api/generate-quiz",
                    json={**BODY, "userXp": xp, "languageCode": lang},
                )
                assert r.status_code == 200, r.text
                data = r.json()
                assert len(data["questions"]) == 3
                for q in data["questions"]:
                    assert isinstance(q["question"], str) and q["question"]
                    assert isinstance(q["options"], list) and len(q["options"]) == 4
                    assert isinstance(q["correctIndex"], int) and 0 <= q["correctIndex"] < 4
                    assert q["evidence"] and q["factIds"]
                assert data["meta"]["difficultyLevel"] == {0: 1, 300: 2, 500: 3, 800: 4}[xp]
                assert len({q["factIds"][0] for q in data["questions"]}) == 3


def test_all_ten_pois_accepted():
    from facts_loader import KNOWN_POI_IDS

    with make_client("fake-good") as c:
        for poi in KNOWN_POI_IDS:
            r = c.post("/api/generate-quiz", json={**BODY, "id": poi})
            assert r.status_code == 200, (poi, r.text)


def test_unknown_poi_and_path_traversal_rejected():
    with make_client("fake-good") as c:
        assert c.post("/api/generate-quiz", json={**BODY, "id": "unknown"}).status_code == 404
        for poi in ("../main", "rocca/../../etc/passwd", ""):
            r = c.post("/api/generate-quiz", json={**BODY, "id": poi})
            assert r.status_code == 422, poi


def test_invalid_parameters_rejected():
    with make_client("fake-good") as c:
        assert c.post("/api/generate-quiz", json={**BODY, "languageCode": "de"}).status_code == 422
        assert c.post("/api/generate-quiz", json={**BODY, "userXp": "abc"}).status_code == 422
        missing = dict(BODY)
        missing.pop("userXp")
        assert c.post("/api/generate-quiz", json=missing).status_code == 422


def test_hallucinations_never_returned_with_200():
    with make_client("fake-hallucinate") as c:
        r = c.post("/api/generate-quiz", json=BODY)
        assert r.status_code == 503
        assert r.json()["detail"]["error"] == "validation_failed"


def test_partial_failure_repaired_with_second_call():
    with make_client("fake-mixed") as c:
        r = c.post("/api/generate-quiz", json=BODY)
        assert r.status_code == 200, r.text
        text = r.text
        assert "25 aprile 1945" not in text and "Divisione" not in text


@pytest.mark.parametrize("model,status,code", [
    ("fake-badjson", 503, "invalid_json"),
    ("fake-400json", 503, "json_validate_failed"),
    ("fake-429", 503, "provider_rate_limited"),
    ("fake-401", 503, "provider_auth"),
])
def test_provider_errors_map_to_non_200(model, status, code):
    with make_client(model) as c:
        r = c.post("/api/generate-quiz", json=BODY)
        assert r.status_code == status
        assert r.json()["detail"]["error"] == code


def test_transient_500_is_retried():
    with make_client("fake-500once") as c:
        r = c.post("/api/generate-quiz", json=BODY)
        assert r.status_code == 200, r.text


def test_slow_provider_times_out_within_client_budget():
    with make_client("fake-slow", LLM_TIMEOUT_S="2", REQUEST_DEADLINE_S="4") as c:
        t = time.perf_counter()
        r = c.post("/api/generate-quiz", json=BODY)
        elapsed = time.perf_counter() - t
        assert r.status_code == 504
        assert elapsed < 6


def test_missing_key_is_not_200():
    with make_client("fake-good", LLM_API_KEY="") as c:
        os.environ.pop("GROQ_API_KEY", None)
        r = c.post("/api/generate-quiz", json=BODY)
        assert r.status_code == 503


def test_health_exposes_only_non_sensitive_service_metadata():
    with make_client("fake-good") as c:
        h = c.get("/health").json()
        assert h == {
            "status": "ok",
            "placesConfigured": 10,
            "questionsPerQuiz": 3,
        }
        assert "provider" not in h
        assert "model" not in h
        assert "keyConfigured" not in h
        assert c.get("/").status_code == 200
