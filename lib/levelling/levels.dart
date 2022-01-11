import 'package:kanji_memory_hint/database/repository.dart';

class Levels {
  static const _levelReqs = [2000, 3000, 4000, 5000, 6000, 7000];

  //pretty sure theres a math method for this
  static List<int> _levelAndRemainingExp(int exp) {
    var remaining = exp;
    var level = 1;

    for(var req in _levelReqs) {
      if(remaining >= req) {
        remaining -= req;
        level++;
      } else {
        break;
      }
    }
    return [level, remaining];
  }

  static Future<List<int>> current() async {
    var points = await SQLRepo.userPoints.get();
    print("${points.exp} ${points.gold}");
    return _levelAndRemainingExp(points.exp);
  }

  static int? next(int level) {
    if(level < 7) {
      return _levelReqs[level-1];
    } else {
      return null;    
    }
  }
}