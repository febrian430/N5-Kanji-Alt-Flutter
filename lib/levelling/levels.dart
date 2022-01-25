import 'dart:math';

import 'package:kanji_memory_hint/database/repository.dart';

class Levels {
  // static const _levelReqs = [1500, 3000, 4500, 6000, 7500, 9000];
  static const _baseAndDifference = 1500;

  //find sum n
  // S = n/2*(2a + (n − 1) d)
  //to get n
  // n = ( -b + sqrt(b^2 - 4ac) ) / 2a
  static int _getLevel(int exp) {
    int a = _baseAndDifference;
    int b = _baseAndDifference;
    int c = -exp*2;

    int delta = b*b - 4*a*c;
    if ( delta >= 0 ){
        double x1 = -b + sqrt(delta);
        x1 /= 2*a;
        return x1.floor().toInt();
    } else {
        return -1;
    }
  }

  //pretty sure theres a math method for this
  static List<int> _levelAndRemainingExp(int exp) {
    // var remaining = exp;
    // var level = 1;

    // for(var req in _levelReqs) {
    //   if(remaining >= req) {
    //     remaining -= req;
    //     level++;
    //   } else {
    //     break;
    //   }
    // }
    // return [level, remaining];

    int level = _getLevel(exp);
    int remaining = exp - (level*_baseAndDifference);
    return [level+1, remaining];
  }

  static Future<List<int>> current() async {
    var points = await SQLRepo.userPoints.get();
    print("${points.exp} ${points.gold}");
    return _levelAndRemainingExp(points.exp);
  }

  static int? next(int level) {
    return (level+1)*_baseAndDifference;
  }

  static Future addExp(int exp) async {
    await SQLRepo.userPoints.addExp(exp);
  }
}