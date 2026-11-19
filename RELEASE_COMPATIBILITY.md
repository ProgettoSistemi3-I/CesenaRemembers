# Release and backend compatibility

Cesena Remembers has one production Firestore database shared by every installed
Android release. Deploying Firestore Rules changes behavior for the Play Store
release immediately; it is not scoped to the app version being developed.
Treat Rules and every client write shape as a public compatibility contract.

## Non-negotiable compatibility rules

- New Rules must continue to authorize the document shapes and write operations
  used by already-published app releases. Add support first; do not rename or
  remove fields, tighten required fields, or reject historical version values
  while those clients may still be installed.
- Keep the existing users/{uid} legal-acceptance field names and timestamp
  semantics stable. Version identifiers must be non-empty strings of at most
  64 characters. Firestore Rules validate their shape and server timestamps,
  not an allow-list of the current version. This lets old binaries keep
  writing their own version identifiers after a Rules deployment.
- Rules are an authorization boundary, not a migration/version switch. Never
  make access to normal profile, friendship, progress, leaderboard or account
  operations depend on a Privacy Notice version.
- Use expand/migrate/contract for schema changes: deploy additive Rules and
  backend support first; release a client that can coexist with the old schema;
  migrate data separately if needed; remove legacy support only after an
  intentional, communicated minimum-client-version policy. Do not assume every
  user updates immediately.

## Terms, Privacy Notice and age-policy changes

The three records have different meanings and must not be treated as one
all-or-nothing privacy version:

- **Terms of Use** (termsVersionAccepted): the app compares this with the
  Terms version embedded in that app build. A material Terms revision can
  require a new affirmative acceptance in the new build. Firestore Rules do
  not hard-code the version, so older builds can still save their existing
  declaration format.
- **Minimum-age declaration** (agePolicyVersionConfirmed): version-gated by
  the app in the same way. Change it only when the eligibility policy actually
  changes, and review the legal/product consequences separately.
- **Privacy Notice** (privacyNoticeVersionAcknowledged): an acknowledgement
  that identifies the notice previously shown, not consent to every processing
  purpose. A new notice revision must not sign out existing users or make
  normal Firestore operations fail. Existing non-empty historical
  acknowledgements remain valid. A subsequent explicit sign-in records the
  notice version embedded in that app build through recordLegalAcceptance();
  an older binary continues to write its own identifier. If you need evidence
  that an existing user has actually seen a newly published notice, show a
  non-blocking in-app notice and record an acknowledgement only after the
  user opens/acknowledges that revision. Do not bulk-overwrite old timestamps
  or pretend users saw a notice they have not seen.

If a Privacy Notice change introduces a genuinely new optional processing
purpose, use a separate purpose-specific consent (for example, the existing
Crashlytics or notification consent fields), show the choice to the user, and
record its own timestamp/version. Do not infer consent from a Privacy Notice
version or silently enable optional collection. For a material Terms change,
use the app's checkbox-gated acceptance flow; do not solve it by tightening
Firestore Rules in a way that strands old clients.

## Development and release workflow

1. Start every change on a branch from main. Keep production deployment out
   of ordinary feature development. Do not deploy Rules or indexes just because
   the Dart code changed.
2. Make changes additive. When a new client starts writing a field or document,
   update Rules and tests to allow the old and new clients to coexist before
   shipping that client. Do not make a new field required for old writes.
3. Run local validation from the repository root:

       flutter pub get
       dart format --output=none --set-exit-if-changed lib test
       flutter analyze
       flutter test
       npx firebase-tools@15.34.1 emulators:exec --only firestore --project demo-cesenaremembers "npm --prefix tests/firestore-rules test"

   The Rules test project is an isolated emulator project; never point these
   tests at the production Firebase project.
4. Open a pull request to main. Review the complete diff, verify that the
   emulator suite and Flutter CI pass, and check that the Rules changes do not
   remove a legacy write shape. Do not merge with a failing Rules job.
5. If a release changes Rules or indexes, deploy the additive backend change
   only after the PR checks pass, using the production project explicitly:

       npx firebase-tools@15.34.1 deploy --only firestore:rules --project cesenaremembers1945

   Run the separate indexes deployment only when the index file changed:

       npx firebase-tools@15.34.1 deploy --only firestore:indexes --project cesenaremembers1945

   Wait for required indexes to finish building and verify the key existing
   flows with a production test account before publishing the app update. If
   the release does not change Rules/indexes, do not deploy them.
6. Update the version in pubspec.yaml. The number after the plus sign is the
   Android versionCode; it must be greater than the highest code already
   uploaded to Play Console. For example, change 1.0.0+3 to 1.0.1+4 only if 4
   is actually the next unused Play versionCode. Confirm that the release
   signing file android/key.properties is present and valid, then build the
   signed bundle from the reviewed commit:

       flutter build appbundle --release --dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID --dart-define=STADIA_MAPS_API_KEY=$STADIA_MAPS_API_KEY --dart-define=MAPBOX_ACCESS_TOKEN=$MAPBOX_ACCESS_TOKEN --dart-define=CARTO_API_KEY=$CARTO_API_KEY

   The GitHub Android validation workflow builds a debug APK for CI; it does
   not upload a signed AAB to Play. Test the signed AAB through an internal or
   closed Play track, then use a staged production rollout rather than
   immediately releasing to 100%.
7. Monitor Crashlytics, authentication, Firestore permission-denied errors,
   onboarding, tour completion and social flows during rollout. Increase the
   rollout only after the new build and the previous live build both behave
   correctly. Keep the last known-good Rules file and release commit available.

## Compatibility tests added

The Rules emulator suite now verifies that:
- a new client can record a newly published legal version without a Rules edit;
- an old client can create and update the same legal record using historical
  Terms, Privacy Notice and age-policy identifiers;
- malformed identifiers, client-generated timestamps and cross-user writes
  are still rejected.

These tests are a required release check, not a substitute for reviewing
whether a legal change actually requires new consent or a forced app update.
