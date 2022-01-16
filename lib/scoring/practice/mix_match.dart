import 'dart:math';

import 'package:kanji_memory_hint/scoring/report.dart';



class MixMatchScoring {
  static const _NUM_OF_QUESTIONS = 8;
  static const _NUM_OF_OPTIONS = 16;

  static GameResult evaluate(PracticeScore score) {
    var exp = _getExp(score);
    var points = (exp*2/3).floor();;

    return GameResult(expGained: exp, pointsGained: points);
  }

  // static int _getPoints(PracticeScore score) {
  //   var pointsForPerfect = 5*score.perfectRounds;
  //   var points = (5-(score.wrongAttempts*0.5)).floor();
  //   return max(0, points) + pointsForPerfect + 5;
  // }

// all perfect = 200
// amount of questions: 32
// max wrong until 0 exp: 30

  static int _getExp(PracticeScore score) {
      // var expForPerfect = 15*score.perfectRounds;
      // var exp = 60-(score.wrongAttempts*2);
      // return max(0, exp) + expForPerfect + 10;

    const maxExpPerAnswer = 9.375; // with max exp 150 per game

    var expGained = score.attemptsPerRound
    .map((attempts) {
      var numerator = max(1, (_NUM_OF_OPTIONS-1)-attempts);
      return (numerator*maxExpPerAnswer/(_NUM_OF_OPTIONS-1));
    })
    .reduce((sum, value) => sum+value);

    return expGained.floor();
  }
}

