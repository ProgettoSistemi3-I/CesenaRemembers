# Automated testing

Cesena Remembers has automated checks at the domain, Flutter, backend and Firestore security-rule levels.

## Flutter and Dart

\`\`\`bash
flutter pub get
flutter analyze
flutter test --coverage
\`\`\`

The Dart suite covers profile validation and offensive-name filtering, achievement eligibility, score thresholds, nearest-neighbour route planning, route-provider fallbacks, tour-session state transitions and GPS-permission restoration, consent restoration, quiz authentication and cache invalidation, user progress/social Firestore transactions, AuthGate routing and MainShell account-state resets. Existing widget, asset, seed-data and controller tests remain part of the same suite.

## Firestore Security Rules

See [tests/firestore-rules/README.md](tests/firestore-rules/README.md). The tests run against the actual Rules file in the Firestore Emulator and use only synthetic data in a demo project.

## Backend

\`\`\`bash
python -m pip install -r server_docker/quiz-service/requirements.txt pytest
python -m pytest -q server_docker/quiz-service/tests/
node --test server_docker/notifier-service/notification_messages.test.js
\`\`\`

## Release smoke test (physical Android device)

The automated Android build does not replace a final smoke test on a physical
device with the real Play upload keystore. Before publishing, install the
signed release APK and verify:
- sign-in, legal acknowledgement and switching between two accounts;
- location permission grant/revocation during a tour, including process
  restart and removal of the foreground-service notification after revocation;
- restoring a tour, completing quizzes (including an attempt that grants zero
  XP), and verifying a newly loaded quiz is not the previous cached attempt;
- sending/accepting friend requests, reporting/blocking/unblocking accounts,
  account deletion and app relaunch;
- notification permission both enabled and denied, plus light/dark themes.

## CI

The existing Android validation workflow runs \`flutter analyze\`, \`flutter test\`, quiz-service tests and notifier checks. The dedicated Firestore Rules workflow starts the emulator and runs the security integration suite on pushes to \`main\` / \`test/**\` and pull requests targeting \`main\`.
