import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/services/tour_scoring_service.dart';

void main() {
  group('TourScoringService', () {
    const service = TourScoringService();

    test('does not award a speed bonus before the minimum leg duration', () {
      final score = service.calculate(correctAnswers: 3, legElapsedSeconds: 29);

      expect(score.baseXp, 60);
      expect(score.timeMultiplier, 1.0);
      expect(score.totalXp, 60);
      expect(score.tier, SpeedTier.none);
    });

    test('applies the lightning multiplier at 30 seconds and through five minutes', () {
      final atMinimum = service.calculate(correctAnswers: 3, legElapsedSeconds: 30);
      final atFiveMinutes = service.calculate(correctAnswers: 3, legElapsedSeconds: 300);

      expect(atMinimum.tier, SpeedTier.lightning);
      expect(atMinimum.totalXp, 72);
      expect(atFiveMinutes.tier, SpeedTier.lightning);
      expect(atFiveMinutes.bonusPercent, 20);
    });

    test('switches tiers exactly after five, ten and fifteen minutes', () {
      expect(
        service.calculate(correctAnswers: 1, legElapsedSeconds: 301).tier,
        SpeedTier.fast,
      );
      expect(
        service.calculate(correctAnswers: 1, legElapsedSeconds: 600).tier,
        SpeedTier.fast,
      );
      expect(
        service.calculate(correctAnswers: 1, legElapsedSeconds: 601).tier,
        SpeedTier.steady,
      );
      expect(
        service.calculate(correctAnswers: 1, legElapsedSeconds: 900).tier,
        SpeedTier.steady,
      );
      expect(
        service.calculate(correctAnswers: 1, legElapsedSeconds: 901).tier,
        SpeedTier.none,
      );
    });

    test('clamps negative correct answers to zero XP', () {
      final score = service.calculate(correctAnswers: -5, legElapsedSeconds: 30);

      expect(score.baseXp, 0);
      expect(score.totalXp, 0);
      expect(score.tier, SpeedTier.none);
    });
  });
}
