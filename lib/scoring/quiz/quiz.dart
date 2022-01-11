import 'dart:math';

import 'package:kanji_memory_hint/scoring/report.dart';

class QuizScoring {
  static GameResult evaluate(QuizScore multiple, QuizJumbleScore jumble) {
    var expMC = _getExpForMC(multiple);
    var expJumble = _getExpForJumble(jumble);

    var scoreMC = _getScoreForMC(multiple);
    var scoreJumble = _getScoreForJumble(jumble);

    return GameResult(
      expGained: min(expMC+expJumble+30, 400),
      pointsGained: scoreMC+scoreJumble
    );
  }

  static int _getExpForJumble(QuizJumbleScore score) {
    int correct = score.correct*20;
    
    int hitScore = 0;
    score.correctlyAnsweredKanji.forEach((slots) {
      hitScore += slots.length;
    });
    return correct+hitScore;
  }

  static int _getScoreForJumble(QuizJumbleScore score) {
    int correct = score.correct*20;
    
    int hitScore = 0;
    score.correctlyAnsweredKanji.forEach((slots) {
      hitScore += slots.length;
    });

    return correct+hitScore;
  }

  static int _getExpForMC(QuizScore score) {
    return score.correct*20;
  }
  
  static int _getScoreForMC(QuizScore score) {
    return score.correct*20;
  }
}