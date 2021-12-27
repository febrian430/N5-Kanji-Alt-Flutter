import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/scoring/mix_match.dart';

class PracticeGameArguments {
    PracticeGameArguments({required this.selectedGame});

    int chapter = 1;
    GAME_MODE mode = GAME_MODE.imageMeaning;
    String selectedGame; 
}

class ResultParam {
  ResultParam({required this.stopwatch, required this.score, required this.result});

  final PracticeScore score;
  final GameResult result;
  final Stopwatch stopwatch;
}