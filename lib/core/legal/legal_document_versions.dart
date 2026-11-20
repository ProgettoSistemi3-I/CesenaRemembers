/// Version identifiers recorded when users make the corresponding
/// sign-in declarations. These are audit identifiers, not Firestore schema
/// versions. A Privacy Notice revision must not invalidate an earlier
/// acknowledgement or force an existing session to sign out.
abstract final class LegalDocumentVersions {
  static const String termsAccepted = '2026-11-15';
  static const String privacyNoticeAcknowledged = '2026-11-19';
  static const String minimumAgePolicyConfirmed = '14-plus-v1';
}
