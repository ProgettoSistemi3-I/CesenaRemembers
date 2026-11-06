# Pre-release readiness checklist

This file contains operational checks that cannot be completed by editing repository files alone. Do not treat the release as ready until every applicable item is confirmed.

## Privacy, legal roles and minors

- [ ] Have the project operators and their legal representatives review the published Privacy Notice and Terms. The notice identifies the project operators as joint controllers; make sure the factual allocation of purposes and means is correct and that the Article 26 GDPR joint-controller arrangement is validly executed.
- [ ] Confirm in writing the role of the school that makes the server infrastructure available at `pascal.ispascalcomandini.it`, including who can access server logs and whether a processor arrangement is required.
- [ ] Review the legal bases stated in the Privacy Notice. In particular, document the legitimate-interest assessment for searchable profiles, social functions, leaderboard visibility, abuse prevention and account moderation.
- [ ] Approve or change the moderation-record retention period. The implementation assigns a 24-calendar-month `retentionUntil` to `banned_users`; the record stores UID, reason and `bannedAt` and is intentionally not removed by normal account deletion. Schedule `scripts/purge_expired_bans.py --apply` (for example daily via cron) only after the retention period has been approved. Legacy records without `retentionUntil` are reported and left untouched until they are reviewed/backfilled.
- [ ] Decide the minimum age and onboarding policy before publishing. In Italy, the 14-year threshold in Article 2-quinquies of the Privacy Code applies to consent for directly offered information-society services when consent is the legal basis; it is not a general contractual-capacity rule. A self-declaration “I am at least 14” does not provide parental authorisation for a younger user. Either exclude users below the chosen minimum age with an age check, or build and test a valid parental-authorisation flow for users for whom it is required.
- [ ] In Google Play Console, set the target audience and age groups to match the actual product and the onboarding policy. Complete the Families/children declarations where applicable, Data Safety, content rating and privacy-policy URL. These declarations are external to this repository.
- [ ] Verify that the public account-deletion page and the in-app deletion flow are both available and tested: `https://cesenaremembers.com/legal/delete-account.html`.

## Deployment and credentials

- [ ] Place the Firebase Admin service-account key at `server_docker/notifier-service/serviceAccountKey.json` on the server only. It is excluded from Docker build context and is mounted read-only into the notifier container; never commit it or bake it into the image.
- [ ] From `server_docker`, validate the Compose configuration and start the notifier with `docker compose up -d --build notifier-service`. Confirm the container remains healthy and its logs do not contain credential or permission errors.
- [ ] Verify that the certificate mounted for Nginx is the same certificate bundled at `assets/certs/server.crt`. The app trusts that certificate specifically; certificate replacement requires a coordinated app update and server deployment. Check validity/expiry and test the public endpoint at `https://pascal.ispascalcomandini.it:8000`.
- [ ] Schedule the moderation-retention cleanup using a protected service account with delete access to `banned_users`; test the dry-run output before enabling `--apply`.
- [ ] Confirm Docker log rotation is active on the target host. Compose configures at most three 10 MB JSON log files for each service container; host-level logs and external reverse-proxy logs need their own policy.
- [ ] Keep the quiz container on the dedicated `quiz-backend` Docker network shared only with Nginx. Do not publish the Uvicorn port on the host or attach unrelated containers to that network while `FORWARDED_ALLOW_IPS=*` is configured.

## Functional and security tests

- [ ] Test notifications for incoming friend requests and accepted requests with the app foregrounded, backgrounded and terminated.
- [ ] Test disabling notifications, force-closing/restarting the app, then receiving another request. No token should remain registered for a disabled user and no push should be sent.
- [ ] Test FCM token refresh and pruning of invalid/unregistered tokens. Verify the user's `fcmTokens` array remains at or below the Firestore Rules limit of 20.
- [ ] Run Firestore Rules tests for all account, profile, friend-request, leaderboard, friend-statistics and moderation flows. Confirm every rules branch remains under the Firestore expression-evaluation limit.
- [ ] Run the required `public_profiles` migration against a backup/controlled dataset before deploying the rules that depend on it.
- [ ] Verify Firebase App Check enforcement and Play Integrity using the actual Play signing configuration, not only a debug build.
- [ ] Execute `flutter pub get`, `flutter gen-l10n` if required by the local Flutter configuration, `flutter analyze`, the complete Flutter test suite, and a signed release AAB build. Also validate `docker compose config`, build the notifier image and test the deployed backend.
- [ ] Confirm that the APK/APK release artifact hosted on GitHub and the Google Play listing correspond to the same reviewed release.
