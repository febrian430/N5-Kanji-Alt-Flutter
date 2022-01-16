import 'package:kanji_memory_hint/const.dart';

class GameResult {
  const GameResult({required this.expGained, required this.pointsGained});
  final int expGained;
  final int pointsGained;
} 

class PracticeGameReport {
  final String game;
  final GAME_MODE mode;
  final int chapter;
  final PracticeScore result;
  final GameResult gains;

  PracticeGameReport({required this.game, required this.mode, required this.chapter, required this.result, required this.gains});
}

class PracticeScore {
  const PracticeScore({required this.attemptsPerRound, required this.mode, required this.chapter, required this.perfectRounds, required this.wrongAttempts});
  final int perfectRounds;
  final int wrongAttempts;
  final List<int> attemptsPerRound;
  final GAME_MODE mode;
  final int chapter;
  // final Stopwatch
}

class QuizReport {
  final int chapter;

  final QuizScore multiple;
  final QuizJumbleScore jumble;
  final GameResult gains;

  QuizReport({required this.chapter, required this.multiple, required this.jumble, required this.gains});
}

class QuizScore {
  final int correct;
  final int miss;

  final List<List<int>> correctlyAnsweredKanji;

  QuizScore({required this.correct, required this.miss, required this.correctlyAnsweredKanji});
}

class QuizJumbleScore {
  final int correct;
  final int miss;
  final List<List<int>> correctlyAnsweredKanji;

  final List<int> correctRoundSlots;
  final int totalSlots;

  
  QuizJumbleScore({required this.correct, required this.correctRoundSlots, required this.totalSlots, required this.miss, required this.correctlyAnsweredKanji});
}
