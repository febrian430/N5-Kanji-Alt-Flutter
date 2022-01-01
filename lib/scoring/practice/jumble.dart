import 'dart:math';

import 'package:kanji_memory_hint/scoring/model.dart';



class JumbleScoring {
  static GameResult evaluate(PracticeScore score, int slotsToFill) {
    var points = _getPoints(score);
    var exp = _getExp(score, slotsToFill);

    return GameResult(expGained: exp, pointsGained: points);
  }

  static int _getPoints(PracticeScore score) {
    var pointsForPerfect = (5*score.perfectRounds).floor();
    var points = (5-(score.wrongAttempts*0.5)).floor();
    return max(0, points) + pointsForPerfect + 5;
  }

  static int _getExp(PracticeScore score, int slotsToFill) {
      var expForPerfect = 25*score.perfectRounds;
      var exp = 20*slotsToFill-(score.wrongAttempts*10);
      return max(0, exp) + expForPerfect + 200;
  }
}

