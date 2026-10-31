import '../repositories/user_repository.dart';

class UserProgressUseCases {
  const UserProgressUseCases(this._repository);

  final IUserRepository _repository;

  Stream<List<Map<String, dynamic>>> getLeaderboardStream({required String uid, int limit = 50}) =>
      _repository.getLeaderboardStream(uid: uid, limit: limit);

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
  }) => _repository.registerQuizCompletion(
    uid: uid,
    poiId: poiId,
    xpGained: xpGained,
    correctAnswers: correctAnswers,
    totalQuestions: totalQuestions,
    tourElapsedSeconds: tourElapsedSeconds,
    isTourComplete: isTourComplete,
    tourTotalXp: tourTotalXp,
    tourCorrectAnswers: tourCorrectAnswers,
    tourTotalQuestions: tourTotalQuestions,
  );

  Future<void> unlockPendingAchievement(String uid, String achievementId) =>
      _repository.unlockPendingAchievement(uid, achievementId);
}
