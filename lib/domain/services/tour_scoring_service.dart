enum SpeedTier { none, steady, fast, lightning }

class TourScoreBreakdown {
  const TourScoreBreakdown({
    required this.baseXp,
    required this.timeMultiplier,
    required this.totalXp,
    required this.tier,
  });

  final int baseXp;
  final double timeMultiplier;
  final int totalXp;
  final SpeedTier tier;

  int get bonusPercent => ((timeMultiplier - 1) * 100).round();
}

class TourScoringService {
  const TourScoringService({
    this.xpPerCorrectAnswer = 20,
    this.minLegSecondsForBonus = 30,
  });

  final int xpPerCorrectAnswer;
  final int minLegSecondsForBonus;

  /// [legElapsedSeconds]: tempo impiegato per raggiungere la tappa corrente.
  TourScoreBreakdown calculate({
    required int correctAnswers,
    required int legElapsedSeconds,
  }) {
    final safeCorrect = correctAnswers < 0 ? 0 : correctAnswers;
    final baseXp = safeCorrect * xpPerCorrectAnswer;
    final (tier, multiplier) = _resolve(legElapsedSeconds);
    return TourScoreBreakdown(
      baseXp: baseXp,
      timeMultiplier: multiplier,
      totalXp: (baseXp * multiplier).round(),
      tier: baseXp == 0 ? SpeedTier.none : tier,
    );
  }

  (SpeedTier, double) _resolve(int seconds) {
    if (seconds < minLegSecondsForBonus) return (SpeedTier.none, 1.0);
    if (seconds <= 5 * 60) return (SpeedTier.lightning, 1.20);
    if (seconds <= 10 * 60) return (SpeedTier.fast, 1.10);
    if (seconds <= 15 * 60) return (SpeedTier.steady, 1.05);
    return (SpeedTier.none, 1.0);
  }
}
