import 'package:cesena_remembers/domain/services/achievement_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const alreadyUnlocked = [
    'first_visit',
    'first_quiz',
    'first_tour',
    'quiz_15',
    'perfect_tour',
    'xp_500',
  ];

  List<String> evaluateAt(int elapsedSeconds) {
    return AchievementService.evaluateOnQuizCompletion(
      alreadyUnlocked: alreadyUnlocked,
      visitedPoiIds: const ['santa_cristina'],
      totalQuizCompleted: 15,
      totalToursCompleted: 1,
      totalXp: 500,
      correctAnswers: 30,
      totalQuestions: 30,
      tourElapsedSeconds: elapsedSeconds,
      isTourComplete: true,
    );
  }

  test('does not award speed achievements below five minutes', () {
    final achievements = evaluateAt(299);
    expect(achievements, isNot(contains('tour_under_1h')));
    expect(achievements, isNot(contains('tour_under_30m')));
  });

  test('awards both speed achievements at five minutes', () {
    final achievements = evaluateAt(300);
    expect(achievements, contains('tour_under_1h'));
    expect(achievements, contains('tour_under_30m'));
  });

  test('awards only the one-hour achievement at thirty minutes', () {
    final achievements = evaluateAt(1800);
    expect(achievements, contains('tour_under_1h'));
    expect(achievements, isNot(contains('tour_under_30m')));
  });

  test('does not award speed achievements at or above one hour', () {
    final achievements = evaluateAt(3600);
    expect(achievements, isNot(contains('tour_under_1h')));
    expect(achievements, isNot(contains('tour_under_30m')));
  });
}
