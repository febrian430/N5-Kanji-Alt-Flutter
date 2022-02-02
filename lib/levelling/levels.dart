import 'dart:math';

import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/repository.dart';

class Levels {
  // static const _levelReqs = [1500, 3000, 4500, 6000, 7500, 9000];
  static const _baseAndDifference = 150;

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

  // n/2*(2a + (n − 1) d)
  static int _sumToN(int n, int diff) {
    print((n*(n+1)*diff)/2);
    return ((n*(n+1)*diff)/2).floor();
  }

  static List<int> _levelAndRemainingExp(int exp) {
    int level = _getLevel(exp);

    int remaining = exp - _sumToN(level, _baseAndDifference);
    return [level+1, remaining];
  }

  static Future<List<int>> current() async {
    var points = await SQLRepo.userPoints.get();
    return _levelAndRemainingExp(points.exp);
  }

  static String image(int level) {
    int imageIndex;
    if(level >= 40) {
      imageIndex = 5;
    }
    else if(level >= 30) {
      imageIndex = 4;
    }
    else if(level >= 20) {
      imageIndex = 3;
    }
    else if(level >= 10) {
      imageIndex = 2;
    } else {
      imageIndex = 1;
    }
    return LEVELS_FOLDER + imageIndex.toString() + '.png';
  }

  static int? next(int level) {
    return (level)*_baseAndDifference;
  }

  static Future addExp(int exp) async {
    await SQLRepo.userPoints.addExp(exp);
  }
}