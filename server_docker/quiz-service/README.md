# Quiz API authentication

The `POST /api/generate-quiz` endpoint requires a Firebase Authentication ID
token from the `cesenaremembers1945` project.

## Request

Flutter obtains the current user's ID token through
`FirebaseAuth.instance.currentUser?.getIdToken()` and sends:

```http
Authorization: Bearer <FIREBASE_ID_TOKEN>
Content-Type: application/json
```

The token is refreshed by the Firebase client SDK when necessary. The server
verifies the token with Firebase Admin Python SDK before rate limiting or
calling the LLM. Invalid, malformed, missing or expired tokens receive HTTP
`401`. If Google's signing certificates cannot be fetched, the API fails
closed with HTTP `503`; it never accepts a token it could not verify.

The verifier checks the Firebase token signature, expiry, issuer and audience
against the configured project ID. It does not trust a UID supplied in the JSON
body. The authenticated UID is also used for a per-user rate limit, in addition
to the existing per-IP limit.

## Server configuration

The Firebase project ID is public configuration, not a secret. Set it in
`server_docker/quiz-service/.env`:

```dotenv
FIREBASE_PROJECT_ID=cesenaremembers1945
```

The same value is currently the code default. The Admin SDK is initialized
with the project ID and a keyless anonymous credential. For this endpoint,
`verify_id_token(check_revoked=False)` validates the token signature and
claims using Google's public signing certificates; it does not invoke
privileged Firebase Admin operations. The quiz container therefore needs
outbound HTTPS access to Google's certificate endpoint, but it does not need
a service-account JSON or private key.

Do not mount the notifier's service-account key into the quiz container. The
notifier uses that credential for separate administrative operations.

The verifier intentionally does not perform a token-revocation/account-disabled
lookup (`check_revoked=False`), which would require an authenticated Admin
credential and an additional request to Firebase Auth. Invalid signatures,
wrong-project tokens and expired tokens are still rejected. Firebase ID tokens
are short-lived and the Flutter SDK refreshes them automatically. Reconsider
revocation checks if the quiz endpoint later protects sensitive user data or
performs privileged actions.

## Tests

From this directory:

```bash
python -m pip install -r requirements.txt pytest
python -m pytest -q tests/
```

The integration tests replace the cryptographic verifier with a deterministic
test double. Production verification is performed by
`firebase_admin.auth.verify_id_token`.
