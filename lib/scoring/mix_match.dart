import 'dart:math';

import 'package:kanji_memory_hint/scoring/model.dart';



class MixMatchScoring {
  static GameResult evaluate(PracticeScore score) {
    var points = _getPoints(score);
    var exp = _getExp(score);

    return GameResult(expGained: exp, pointsGained: points);
  }

  static int _getPoints(PracticeScore score) {
    var pointsForPerfect = 5*score.perfectRounds;
    var points = (5-(score.wrongAttempts*0.5)).floor();
    return max(0, points) + pointsForPerfect + 5;
  }
// base exp: 100
// exp: 150-(wrongAttempts * 10)
  static int _getExp(PracticeScore score) {
      var expForPerfect = 50*score.perfectRounds;
      var exp = 150-(score.wrongAttempts*10);
      return max(0, exp) + expForPerfect + 100;
  }
}
