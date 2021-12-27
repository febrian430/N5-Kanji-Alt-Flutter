class PracticeScore {
  const PracticeScore({required this.perfectRounds, required this.wrongAttempts});
  final int perfectRounds;
  final int wrongAttempts;
  // final Stopwatch
}

class GameResult {
  const GameResult({required this.expGained, required this.pointsGained});
  final int expGained;
  final int pointsGained;
}