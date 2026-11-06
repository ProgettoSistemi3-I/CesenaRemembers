import 'package:flutter_test/flutter_test.dart';

import '../lib/models/user_model.dart';

void main() {
  group('UserModel consent preferences', () {
    test('profiles without a completed consent flow remain pending', () {
      final profile = UserModel.fromJson(
        {
          'email': 'test@example.invalid',
          'displayName': 'Tester',
          'preferences': const <String, dynamic>{},
        },
        'test-uid',
      );

      expect(profile.permissionsSetupCompleted, isFalse);
      expect(profile.notificheEnabled, isFalse);
      expect(profile.gpsEnabled, isTrue);
      expect(profile.crashlyticsEnabled, isFalse);
    });

    test('restores an explicit Crashlytics choice with its timestamp', () {
      final profile = UserModel.fromJson(
        {
          'email': 'test@example.invalid',
          'displayName': 'Tester',
          'preferences': {
            'permissionsSetupCompleted': true,
            'crashlyticsEnabled': true,
            'crashlyticsConsentAt': DateTime.utc(2026, 11, 6),
          },
        },
        'test-uid',
      );

      expect(profile.permissionsSetupCompleted, isTrue);
      expect(profile.crashlyticsEnabled, isTrue);
    });

    test('does not trust a Crashlytics flag without a consent timestamp', () {
      final profile = UserModel.fromJson(
        {
          'email': 'test@example.invalid',
          'displayName': 'Tester',
          'preferences': const {
            'permissionsSetupCompleted': true,
            'crashlyticsEnabled': true,
          },
        },
        'test-uid',
      );

      expect(profile.permissionsSetupCompleted, isTrue);
      expect(profile.crashlyticsEnabled, isFalse);
    });

    test('restores push notifications only with a recorded consent', () {
      final withoutTimestamp = UserModel.fromJson(
        {
          'email': 'test@example.invalid',
          'displayName': 'Tester',
          'preferences': const {
            'notifiche': true,
            'notificheConsenso': true,
          },
        },
        'test-uid',
      );
      final withTimestamp = UserModel.fromJson(
        {
          'email': 'test@example.invalid',
          'displayName': 'Tester',
          'preferences': {
            'notifiche': true,
            'notificheConsenso': true,
            'notificheConsensoAt': DateTime.utc(2026, 11, 6),
          },
        },
        'test-uid',
      );

      expect(withoutTimestamp.notificheEnabled, isFalse);
      expect(withTimestamp.notificheEnabled, isTrue);
    });
  });
}
