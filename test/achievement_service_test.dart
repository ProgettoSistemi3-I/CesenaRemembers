import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/services/achievement_service.dart';

void main() {
  group('AchievementService tour speed thresholds', () {
    List<String> evaluate(
      int elapsedSeconds, {
      int? bestTourTimeSeconds,
    }) {
      return AchievementService.evaluateOnQuizCompletion(
        alreadyUnlocked: const [],
        visitedPoiIds: const ['rocca'],
        totalQuizCompleted: 1,
        totalToursCompleted: 1,
        totalXp: 100,
        correctAnswers: 1,
        totalQuestions: 3,
        tourElapsedSeconds: elapsedSeconds,
        bestTourTimeSeconds: bestTourTimeSeconds,
        isTourComplete: true,
      );
    }

    test('does not award speed badges for a tour shorter than five minutes', () {
      final awards = evaluate(299);

      expect(awards, isNot(contains('tour_under_1h')));
      expect(awards, isNot(contains('tour_under_30m')));
    });

    test('awards eligible speed badges from five minutes onward', () {
      final awards = evaluate(300);

      expect(awards, contains('tour_under_1h'));
      expect(awards, contains('tour_under_30m'));
    });

    test('awards only the one-hour badge for a tour between 30 and 60 minutes', () {
      final awards = evaluate(1800);

      expect(awards, contains('tour_under_1h'));
      expect(awards, isNot(contains('tour_under_30m')));
    });

    test('uses the persisted best time when an earlier record is under five minutes', () {
      final awards = evaluate(1200, bestTourTimeSeconds: 240);

      expect(awards, isNot(contains('tour_under_1h')));
      expect(awards, isNot(contains('tour_under_30m')));
    });
  });
}
