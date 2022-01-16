import 'dart:math';

import 'package:kanji_memory_hint/scoring/report.dart';

class PickDropScoring {
  static const _NUM_OF_OPTS = 8;

  static GameResult evaluate(PracticeScore score) {
    var points = _getPoints(score);
    var exp = _getExp(score);

    return GameResult(expGained: exp, pointsGained: points);
  }

  static int _getPoints(PracticeScore score) {
    var pointsForPerfect = 5*score.perfectRounds;
    var points = (score.perfectRounds*0.5).floor();
    return max(0, points) + pointsForPerfect + 5;
  }
// base exp: 100
// exp: 150-(wrongAttempts * 10)
  static int _getExp(PracticeScore score) {
    // var expForPerfect = 4*score.perfectRounds;
    // var exp = 40-(score.wrongAttempts*3);
    // return max(0, exp) + expForPerfect + 20;

    var expGained = score.attemptsPerRound.map((attempts){
      var numerator = max(1, _NUM_OF_OPTS-attempts);
      return (numerator/_NUM_OF_OPTS)*10;
    })
    .reduce((sum, value) => sum+value);
    return expGained.floor();
  }
}
