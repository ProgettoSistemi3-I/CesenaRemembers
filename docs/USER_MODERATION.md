# User reporting and blocking

This branch adds profile reporting and user blocking to Cesena Remembers.

## User-visible behaviour

- The public profile menu offers **Report profile** and **Block user**.
- A report identifies the exact user-generated field (displayName or username), a reason and optional details (maximum 500 characters).
- A block is written before the app attempts to remove existing friend requests or a reciprocal friendship. Firestore Rules therefore reject new requests and friend acceptance as soon as the block document exists.
- Blocking removes the friendship and any pending request in either direction using the existing narrowly-scoped social operations.
- The owner can inspect and remove their outgoing block entries in Settings → Privacy → Blocked users.
- Unblocking does not recreate friendships or friend requests.
- Public name/username projections remain public to authenticated users; blocking disables social interaction rather than hiding public profile fields.

## Firestore data model

user_blocks/{blockerUid}/blocked/{blockedUid}
  createdAt: timestamp

user_reports/{reportId}
  reporterUid: string
  reportedUid: string
  reportedField: displayName | username
  reportedValue: string
  reportedDisplayName: string
  reportedUsername: string
  reason: inappropriate_name | impersonation | harassment | spam | other
  details: string
  createdAt: timestamp
  status: pending

Reports are write-only for app clients. Firestore Rules require the authenticated UID to match reporterUid, require the reported profile to exist, check the submitted profile snapshot against Firestore and force status = pending. Clients cannot read, update or delete report records. Moderators must inspect them through the Firebase Console or a trusted Admin SDK environment; never put service-account credentials in the app.

Block entries can only be listed/read/created by their owner. Deletion by the owner is allowed even if the account is suspended so the account-deletion flow can clean its own outgoing block list.

## Social and push enforcement

The shared hasBlockBetween(uidA, uidB) Rules helper checks both directions. It is used when creating friend requests and accepting a request, and detailed friend statistics are no longer readable across a blocked relationship.

The notifier compares request/friend UIDs (not only array lengths) and checks both block documents immediately before sending a friend-request or friend-accepted push.

A block document is written first. Existing relationships are then removed through the existing social DataSource operations so their dedicated Rules validations and mirrored documents continue to apply. If cleanup fails, the block remains active and the profile UI reports that some existing social data may need another cleanup attempt. New social actions remain denied by Rules while the block exists.

## Moderation workflow

1. Review new documents in Firestore user_reports (collection-level query in Firebase Console / Admin SDK).
2. Check the stored reported-field snapshot and reason, then assess the profile against the Terms of Use.
3. Update the moderation status from a trusted administrator session to reviewed, action_taken or dismissed.
4. If a suspension is warranted, use the existing banned_users / scripts/ban_user.py procedure. Do not auto-ban on a single user report.
5. Reports are retained for up to 24 months from receipt. Run scripts/cleanup_user_reports.py periodically with a protected Firebase Admin service account (dry-run by default; add --apply to delete expired reports). Preserve older records only where a documented legal or claims-preservation need requires it.

## Firestore Rules tests

The Node test project in tests/firestore_rules exercises:
- owner-only block list access and mutation;
- blocked relationship rejection at the friend-request document boundary;
- allowed friend request creation when no block exists;
- valid report creation, private report records, and rejection of forged or client-modified reports.

Run with Node.js installed:

    cd tests/firestore_rules
    npm install
    npm test

The test command starts the Firestore Emulator using the repository's firebase.json (port 8080). It does not access production Firestore. The Flutter app, notifier container and legal pages must still be built/deployed with the release pipeline before this feature is shipped.
