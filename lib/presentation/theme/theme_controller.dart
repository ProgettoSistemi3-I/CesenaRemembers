import 'package:material_ui/material_ui.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/usecases/user_profile_use_cases.dart';

class ThemeController extends ChangeNotifier {
  final UserProfileUseCases _profileUseCases;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkModeEffective {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  ThemeController({required UserProfileUseCases profileUseCases})
    : _profileUseCases = profileUseCases;

  Future<void> initTheme() async {
    await _loadThemeFromFirebase();
  }

  Future<void> refreshFromProfile() async {
    await _loadThemeFromFirebase();
    notifyListeners();
  }

  Future<void> _loadThemeFromFirebase() async {
    final uid = _profileUseCases.getCurrentUserUid();
    if (uid == null) {
      _themeMode = ThemeMode.system;
      return;
    }

    try {
      final profile = await _profileUseCases.getUserProfile(uid);
      _themeMode = !profile.hasThemePreference
          ? ThemeMode.system
          : profile.darkModeEnabled
              ? ThemeMode.dark
              : ThemeMode.light;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error loading theme from profile',
        error: error,
        stackTrace: stackTrace,
        name: 'ThemeController',
      );
      _themeMode = ThemeMode.system;
    }
  }

  void useSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
