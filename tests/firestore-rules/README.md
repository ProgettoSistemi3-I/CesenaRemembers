# Firestore Rules tests

The suite executes the repository's real \`firestore.rules\` file against the Firestore Emulator. It uses the isolated \`demo-cesenaremembers\` project ID and synthetic users only; it never connects to the production Firebase project.

## Requirements

- Node.js 20 or later
- Java 21
- Firebase CLI 15.34.1 (the CI workflow installs this version through \`npx\`)

## Run locally

From the repository root:

\`\`\`bash
cd tests/firestore-rules
npm install
cd ../..
npx firebase-tools@15.34.1 emulators:exec --only firestore --project demo-cesenaremembers "npm --prefix tests/firestore-rules test"
\`\`\`

## Coverage

The tests cover private/public read boundaries, ban enforcement, bounded public queries, deterministic leaderboard tie ordering, profile onboarding, progress and leaderboard projection synchronization, XP limits, consent validation, request send/cancel/reject/accept, reciprocal friendship and removal, friend-stat privacy, achievement claims, and the final account-deletion batch.

Complex multi-document operations are committed as atomic batches. The emulator therefore checks the actual Rules execution budgets (document-access calls and expressions), not a hand-maintained estimate.

## Backward compatibility

The suite includes explicit old-client legal-acceptance create/update cases.
Keep these cases when changing legal flows: production Rules are shared by
every installed release. Legal version identifiers are shape-validated rather
than allow-listed in Rules, and a Privacy Notice revision must not invalidate
a previous acknowledgement or gate ordinary app access.
