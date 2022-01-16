import 'dart:math';

import 'package:kanji_memory_hint/scoring/report.dart';

class QuizScoring {
  static GameResult evaluate(QuizScore multiple, QuizJumbleScore jumble) {
    var expMC = _getExpForMC(multiple);
    var expJumble = _getExpForJumble(jumble);

    var scoreMC = _getScoreForMC(multiple);
    var scoreJumble = _getScoreForJumble(jumble);

    return GameResult(
      expGained: min(expMC+expJumble, 300),
      pointsGained: scoreMC+scoreJumble
    );
  }

  static int _getExpForJumble(QuizJumbleScore score) {
    double expPerSlot = 150/score.totalSlots;
    var sumCorrectSlots = score.correctRoundSlots.reduce((sum, value) => sum+value);
    print("SLOTS CORRECT $sumCorrectSlots");
    
    return (sumCorrectSlots*expPerSlot).ceil();
  }

  static int _getScoreForJumble(QuizJumbleScore score) {
    double pointsPerSlot = 50/score.totalSlots;
    var sumCorrectSlots = score.correctRoundSlots.reduce((sum, value) => sum+value);

    return (sumCorrectSlots*pointsPerSlot).ceil();
  }

  static int _getExpForMC(QuizScore score) {
    return score.correct*15;
  }
  
  static int _getScoreForMC(QuizScore score) {
    return (score.correct*15*2/3/2).ceil();
  }
}