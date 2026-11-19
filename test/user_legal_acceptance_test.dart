import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/core/legal/legal_document_versions.dart';
import 'package:cesena_remembers/data/user/user_profile_data_source.dart';

void main() {
  group('UserProfileDataSource.hasCurrentLegalAcceptance', () {
    late FakeFirebaseFirestore firestore;
    late UserProfileDataSource source;
    late Timestamp acceptedAt;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      source = UserProfileDataSource(firestore: firestore);
      acceptedAt = Timestamp.fromDate(DateTime.utc(2026, 11, 15));
    });

    test('keeps the previous privacy notice acknowledgement valid', () async {
      await firestore.collection('users').doc('legacy-user').set({
        'termsAcceptedAt': acceptedAt,
        'termsVersionAccepted': LegalDocumentVersions.termsAccepted,
        'privacyNoticeAcknowledgedAt': acceptedAt,
        'privacyNoticeVersionAcknowledged': '2026-11-15',
        'ageConfirmedAt': acceptedAt,
        'agePolicyVersionConfirmed':
            LegalDocumentVersions.minimumAgePolicyConfirmed,
      });

      expect(
        await source.hasCurrentLegalAcceptance('legacy-user'),
        isTrue,
      );
    });

    test('accepts the current privacy notice acknowledgement', () async {
      await firestore.collection('users').doc('new-user').set({
        'termsAcceptedAt': acceptedAt,
        'termsVersionAccepted': LegalDocumentVersions.termsAccepted,
        'privacyNoticeAcknowledgedAt': acceptedAt,
        'privacyNoticeVersionAcknowledged':
            LegalDocumentVersions.privacyNoticeAcknowledged,
        'ageConfirmedAt': acceptedAt,
        'agePolicyVersionConfirmed':
            LegalDocumentVersions.minimumAgePolicyConfirmed,
      });

      expect(await source.hasCurrentLegalAcceptance('new-user'), isTrue);
    });

    test('does not relax terms or minimum-age version checks', () async {
      await firestore.collection('users').doc('outdated-user').set({
        'termsAcceptedAt': acceptedAt,
        'termsVersionAccepted': '2026-11-14',
        'privacyNoticeAcknowledgedAt': acceptedAt,
        'privacyNoticeVersionAcknowledged': '2026-11-15',
        'ageConfirmedAt': acceptedAt,
        'agePolicyVersionConfirmed': '14-plus-old',
      });

      expect(
        await source.hasCurrentLegalAcceptance('outdated-user'),
        isFalse,
      );
    });
  });
}
