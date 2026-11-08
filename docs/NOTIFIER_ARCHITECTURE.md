# Notifier: privacy assessment and Cloud Functions proposal

## Current implementation

`server_docker/notifier-service/index.js` subscribes to the entire `users` collection using `onSnapshot()`. Firestore sends complete document snapshots to the notifier process; reading only selected keys from `change.doc.data()` does not limit the fields transferred to the process. The documents can contain email addresses and other private profile information.

The notifier currently uses only:
- `receivedFriendRequests`, `sentFriendRequests` and `friends` to detect new requests and accepted friendships;
- `fcmTokens` and `preferences` to determine whether and how to send the push notification.

It does not add the email address to notification messages, but the complete snapshot is still received and loaded by the service. The privacy notice now describes that behaviour accurately.

## Why a simple projection is not available

The Firestore Node.js Admin SDK documents that a query using `select(...)` applies a field mask and returns only the selected fields, but **queries with field masks cannot be used with `onSnapshot()`**. A `.select()` call therefore cannot be added to the current real-time collection listener as a privacy fix.

References:
- [Firestore Node.js Query.select reference](https://googleapis.dev/nodejs/firestore/latest/Query.html): field masks and the `onSnapshot()` limitation.
- [Cloud Functions for Firebase — Firestore events](https://firebase.google.com/docs/functions/firestore-events): event delivery is at least once and ordering is not guaranteed.

## Would moving the current listener to a Cloud Function solve this?

Not if the function is triggered on `users/{uid}`. A document update trigger receives the event snapshots for the full document; it does not turn the event into a field projection. It would move execution from the Raspberry Pi to Google Cloud, but it would not, by itself, remove email and unrelated profile fields from the event payload.

A Cloud Function can, however, support a better event-driven design if it listens to small, dedicated event documents rather than private user documents.

## Recommended design

1. **Friend request received:** trigger an `onDocumentCreated` function on `friend_requests/{recipientUid}/inbox/{senderUid}`. That document already contains only the sender UID, recipient UID and creation timestamp, so the trigger payload is much smaller and does not include the user's email/profile document.
2. **Friend request accepted:** do not infer acceptance from deletion of the inbox document. The current app deletes that document for accept, reject and cancel, so an `onDocumentDeleted` trigger cannot reliably distinguish those actions. Move the acceptance operation to a callable/HTTPS function that validates the request, performs the friendship updates transactionally and writes a dedicated `notification_events/{eventId}` outbox document with only the recipient UID, actor UID, event type and timestamp. Alternatively, implement an equally trusted server-side outbox write as part of the acceptance flow.
3. **Notification preferences and tokens:** have the function fetch only the required fields with a normal one-shot query using `select(...)` (not a real-time listener), or introduce a dedicated `notification_settings/{uid}` document containing only FCM tokens, notification consent and language. The dedicated document is the cleaner long-term boundary; either approach avoids subscribing to full `users` documents.
4. **Idempotency:** record processed event IDs (or otherwise use an idempotency key) before/while sending notifications. Firestore triggers are delivered at least once and may arrive out of order, so a function must tolerate duplicate and reordered invocations.
5. **Operations:** configure retries/dead-letter handling, monitor delivery failures, clean invalid FCM tokens, and give the function a narrowly scoped service identity. Keep FCM tokens and consent checks server-side.

## Migration decision

A Cloud Function is a sound long-term direction, but it is not a drop-in replacement for the present listener. The accepted-friend notification needs an explicit event because the current delete event is ambiguous; token/preferences access also needs a deliberate data-minimisation boundary. For this change set, the service has therefore been left operationally unchanged and the privacy notice has been corrected. Implement the event/outbox migration separately with emulator tests for request, accept, reject, cancel, block, duplicate delivery and revoked notification consent.
