import '../entities/quiz_load_result.dart';

abstract class IQuizRepository {
  /// Invalidates cached questions after a completed attempt.
  void invalidateCacheForPoi(String poiId) {}

  Future<QuizLoadResult> getQuizForPoi(
    String poiId,
    String poiName,
    int userXP, {
    required String languageCode,
    required String poiDescription,
  });
}
