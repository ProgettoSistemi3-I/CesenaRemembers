import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/models/user_model.dart';

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

    test('new profiles do not treat the default light value as an explicit choice', () {
      final profile = UserModel.fromJson(
        {
          'email': 'test@example.invalid',
          'displayName': 'Tester',
          'preferences': const <String, dynamic>{
            'modalitaNotte': false,
          },
        },
        'test-uid',
      );

      expect(profile.darkModeEnabled, isFalse);
      expect(profile.hasThemePreference, isFalse);
    });

    test('restores an explicit light-mode choice using its marker', () {
      final profile = UserModel.fromJson(
        {
          'email': 'test@example.invalid',
          'displayName': 'Tester',
          'preferences': {
            'modalitaNotte': false,
            'themePreferenceSetAt': DateTime.utc(2026, 11, 11),
          },
        },
        'test-uid',
      );

      expect(profile.darkModeEnabled, isFalse);
      expect(profile.hasThemePreference, isTrue);
    });

    test('restores an older explicit dark-mode choice', () {
      final profile = UserModel.fromJson(
        {
          'email': 'test@example.invalid',
          'displayName': 'Tester',
          'preferences': const <String, dynamic>{
            'modalitaNotte': true,
          },
        },
        'test-uid',
      );

      expect(profile.darkModeEnabled, isTrue);
      expect(profile.hasThemePreference, isTrue);
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
