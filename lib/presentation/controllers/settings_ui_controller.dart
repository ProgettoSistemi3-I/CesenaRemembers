import 'package:flutter/material.dart';

import '../../core/logging/app_logger.dart';

import '../services/locale_preference_store.dart';
import '../../domain/usecases/user_preferences_use_cases.dart';
import '../../domain/usecases/user_profile_use_cases.dart';

class SettingsUiController extends ChangeNotifier {
  SettingsUiController(
    this._localeNotifier, {
    required UserPreferencesUseCases preferencesUseCases,
    required UserProfileUseCases profileUseCases,
  }) : _preferencesUseCases = preferencesUseCases,
       _profileUseCases = profileUseCases,
       selectedLanguage = _localeNotifier.value.languageCode == 'en'
           ? 'English'
           : 'Italiano';

  final ValueNotifier<Locale> _localeNotifier;
  final UserPreferencesUseCases _preferencesUseCases;
  final UserProfileUseCases _profileUseCases;
  String selectedLanguage;

  Future<void> setLanguage(String value) async {
    if (selectedLanguage == value) return;
    selectedLanguage = value;
    final locale = Locale(value == 'English' ? 'en' : 'it');
    _localeNotifier.value = locale;
    await LocalePreferenceStore.saveLocale(locale);
    final uid = _profileUseCases.getCurrentUserUid();
    if (uid != null) {
      try {
        await _preferencesUseCases.updatePreferences(
          uid: uid,
          languageCode: locale.languageCode,
        );
      } catch (error, stackTrace) {
        AppLogger.error(
          'Unable to persist the selected language preference',
          error: error,
          stackTrace: stackTrace,
          name: 'SettingsUiController',
        );
        // La lingua locale resta applicata anche offline.
      }
    }
    notifyListeners();
  }
}
