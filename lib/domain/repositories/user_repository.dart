import '../entities/userprofile.dart';

abstract class IUserRepository {
  Future<UserProfile> getUserProfile(String uid);
  Stream<UserProfile?> getUserProfileStream(String uid);
  String? getCurrentUserUid();
  Future<void> ensureUserDocument({required String uid, required String email});
  Future<void> recordLegalAcceptance({
    required String uid,
    required String email,
  });
  Future<void> completeInitialProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    required String avatarId,
    required String languageCode,
  });
  Future<void> updateProfileBasics({
    required String uid,
    String? displayName,
    String? avatarId,
  });
  Future<bool> isUsernameAvailable(String username);
  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
    bool? crashlytics,
    bool? permissionsSetupCompleted,
    String? languageCode,
  });
  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
    bool isTourComplete = false,
    int? tourTotalXp,
    int? tourCorrectAnswers,
    int? tourTotalQuestions,
  });
  Future<void> unlockPendingAchievement(String uid, String achievementId);
  Future<void> ensureFriendAchievements({required String uid});
  Future<void> deleteUserData({required String uid});
  Future<List<UserProfile>> searchUsers(String query);
  Stream<List<Map<String, dynamic>>> getLeaderboardStream({required String uid, int limit = 50});
  Future<int?> getLeaderboardRank({required String uid});

  // Social
  Future<void> sendFriendRequest(String currentUid, String targetUid);
  Future<void> cancelFriendRequest(String currentUid, String targetUid);
  Future<void> acceptFriendRequest(String currentUid, String requesterUid);
  Future<void> rejectFriendRequest(String currentUid, String requesterUid);
  Future<void> removeFriend(String currentUid, String friendUid);
  Future<List<UserProfile>> getUsersByIds(List<String> uids);
  Future<bool> checkAreFriends(String currentUid, String targetUid);

  // User reporting and blocking
  Future<void> blockUser(String currentUid, String targetUid);
  Future<void> unblockUser(String currentUid, String targetUid);
  Future<List<String>> getBlockedUserIds(String uid);
  Future<void> reportUser({
    required String reporterUid,
    required String reportedUid,
    required String reportedField,
    required String reason,
    required String details,
  });

  Future<void> saveFcmToken(String uid, String token);
  Future<void> removeFcmToken(String uid, String token);

  // Ban
  Future<bool> isUserBanned(String uid);

  // Onboarding
  Future<void> markOnboardingCompleted(String uid);
}
