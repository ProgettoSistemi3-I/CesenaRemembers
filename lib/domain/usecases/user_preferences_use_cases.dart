import '../repositories/user_repository.dart';

class UserPreferencesUseCases {
  const UserPreferencesUseCases(this._repository);

  final IUserRepository _repository;

  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
    bool? crashlytics,
    bool? permissionsSetupCompleted,
    String? languageCode,
  }) => _repository.updatePreferences(
    uid: uid,
    notifiche: notifiche,
    darkMode: darkMode,
    gps: gps,
    crashlytics: crashlytics,
    permissionsSetupCompleted: permissionsSetupCompleted,
    languageCode: languageCode,
  );
}
