import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/services/achievement_service.dart';

void main() {
  group('AchievementService eligibility', () {
    test('unlocks quiz and tour achievements only when their conditions are met', () {
      final awards = AchievementService.evaluateOnQuizCompletion(
        alreadyUnlocked: const [],
        visitedPoiIds: const ['rocca'],
        totalQuizCompleted: 15,
        totalToursCompleted: 1,
        totalXp: 500,
        correctAnswers: 3,
        totalQuestions: 3,
        tourElapsedSeconds: 1800,
        bestTourTimeSeconds: 1800,
        isTourComplete: true,
      );

      expect(
        awards,
        [
          'first_visit',
          'first_quiz',
          'first_tour',
          'quiz_15',
          'perfect_tour',
          'xp_500',
          'tour_under_1h',
        ],
      );
      expect(awards, isNot(contains('tour_under_30m')));
    });

    test('does not unlock completion-only achievements on an intermediate stop', () {
      final awards = AchievementService.evaluateOnQuizCompletion(
        alreadyUnlocked: const [],
        visitedPoiIds: const ['rocca'],
        totalQuizCompleted: 1,
        totalToursCompleted: 0,
        totalXp: 500,
        correctAnswers: 3,
        totalQuestions: 3,
        tourElapsedSeconds: 600,
        isTourComplete: false,
      );

      expect(awards, contains('first_visit'));
      expect(awards, contains('first_quiz'));
      expect(awards, contains('xp_500'));
      expect(awards, isNot(contains('first_tour')));
      expect(awards, isNot(contains('perfect_tour')));
      expect(awards, isNot(contains('tour_under_1h')));
    });

    test('does not duplicate already unlocked or newly evaluated achievements', () {
      final awards = AchievementService.evaluateOnQuizCompletion(
        alreadyUnlocked: const ['first_visit', 'first_quiz', 'xp_500'],
        visitedPoiIds: const ['rocca'],
        totalQuizCompleted: 1,
        totalToursCompleted: 0,
        totalXp: 500,
        correctAnswers: 0,
        totalQuestions: 3,
        tourElapsedSeconds: 0,
        isTourComplete: false,
      );

      expect(awards, isEmpty);
    });

    test('friend achievements have independent one-friend and five-friend thresholds', () {
      expect(
        AchievementService.evaluateOnFriendAdded(
          alreadyUnlocked: const [],
          friendCount: 1,
        ),
        ['friend_1'],
      );
      expect(
        AchievementService.evaluateOnFriendAdded(
          alreadyUnlocked: const ['friend_1'],
          friendCount: 5,
        ),
        ['friend_5'],
      );
      expect(
        AchievementService.evaluateOnFriendAdded(
          alreadyUnlocked: const ['friend_1', 'friend_5'],
          friendCount: 10,
        ),
        isEmpty,
      );
      expect(
        AchievementService.evaluateOnFriendAdded(
          alreadyUnlocked: const [],
          friendCount: 0,
        ),
        isEmpty,
      );
    });
  });
}
