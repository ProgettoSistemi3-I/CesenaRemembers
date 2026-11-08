# Automated testing

Cesena Remembers has automated checks at the domain, Flutter, backend and Firestore security-rule levels.

## Flutter and Dart

\`\`\`bash
flutter pub get
flutter analyze
flutter test --coverage
\`\`\`

The Dart suite covers profile validation and offensive-name filtering, achievement eligibility, score thresholds, nearest-neighbour route planning, route-provider fallbacks, tour-session state transitions, consent restoration, quiz authentication and quiz API fallback behavior. Existing widget, asset, seed-data and controller tests remain part of the same suite.

## Firestore Security Rules

See [tests/firestore-rules/README.md](tests/firestore-rules/README.md). The tests run against the actual Rules file in the Firestore Emulator and use only synthetic data in a demo project.

## Backend

\`\`\`bash
python -m pip install -r server_docker/quiz-service/requirements.txt pytest
python -m pytest -q server_docker/quiz-service/tests/
node --test server_docker/notifier-service/notification_messages.test.js
\`\`\`

## CI

The existing Android validation workflow runs \`flutter analyze\`, \`flutter test\`, quiz-service tests and notifier checks. The dedicated Firestore Rules workflow starts the emulator and runs the security integration suite on pushes to \`main\` / \`test/**\` and pull requests targeting \`main\`.
