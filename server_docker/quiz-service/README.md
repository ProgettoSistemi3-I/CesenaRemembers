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

The Firebase project ID is public configuration. Set it in
`server_docker/quiz-service/.env`:

```dotenv
FIREBASE_PROJECT_ID=cesenaremembers1945
```

### Read-only Firebase Auth credential

The API verifies the token signature and project claims, and also checks that
the account is enabled and the token has not been revoked. The latter check
requires the Admin SDK to read the Firebase Authentication user record.

Create a **dedicated service account** for the quiz container and grant it only
the project-level IAM role **Firebase Authentication Viewer**
(`roles/firebaseauth.viewer`). This role supplies the read-only
`firebaseauth.users.get` permission required by the revocation check. Do not
grant Firebase Admin/Owner, Firestore access, or reuse the notifier service
account.

Create a JSON key for this service account and place it on the server at:

```text
server_docker/quiz-service/firebase-auth-reader.json
```

The file is ignored by Git and excluded from the Docker build context. Compose
bind-mounts it read-only at `/run/secrets/firebase-auth-reader.json` and sets
`GOOGLE_APPLICATION_CREDENTIALS`; it is not copied into the image. Keep the
key outside backups/logs accessible to ordinary users and rotate it if exposed.

After installing the key, rebuild and restart the service from
`server_docker`:

```bash
docker compose up -d --build quiz-server
docker compose logs --tail=100 quiz-server
```

If the credential is missing, invalid, or lacks `firebaseauth.users.get`,
the service fails closed rather than silently reverting to signature-only
verification. The additional Auth lookup adds a network request to Firebase
for each token verification; allow outbound HTTPS access to Firebase Auth.
The notifier continues to use its own separate service account.

## Tests

From this directory:

```bash
python -m pip install -r requirements.txt pytest
python -m pytest -q tests/
```

The integration tests replace the cryptographic verifier with a deterministic
test double. Production verification is performed by
`firebase_admin.auth.verify_id_token`.
