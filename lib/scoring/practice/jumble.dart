import 'dart:math';

import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/scoring/report.dart';



class JumbleScoring {
  static GameResult evaluate(PracticeScore score, int slotsToFill, List<int> perfectRoundsSlots) {
    var points = _getPoints(score);
    var exp = _getExp(score, slotsToFill, perfectRoundsSlots);

    return GameResult(expGained: exp, pointsGained: points);
  }

  static int _getPoints(PracticeScore score) {
    var pointsForPerfect = (5*score.perfectRounds).floor();
    var points = (5-(score.wrongAttempts*0.5)).floor();
    return max(0, points) + pointsForPerfect + 5;
  }

  static int _getExp(PracticeScore score, int slotsToFill, List<int> perfectRoundsSlots) {
      int expForPerfect = 0;
      int exp;

      if(score.mode == GAME_MODE.imageMeaning) {
        perfectRoundsSlots.forEach((slots) {
          expForPerfect += slots*2;
        });

        exp = 40-(score.wrongAttempts);
      } else {
        perfectRoundsSlots.forEach((slots) {
          expForPerfect += slots;
        });
        exp = 40-(score.wrongAttempts*20/slotsToFill).floor();
      }
    
      return max(100, max(0, exp) + expForPerfect + 20);
  }
}

