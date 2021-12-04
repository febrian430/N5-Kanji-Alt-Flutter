import 'package:kanji_memory_hint/const.dart';

class PracticeGameArguments {
    PracticeGameArguments({required this.selectedGame});

    int chapter = 1;
    GAME_MODE mode = GAME_MODE.imageMeaning;
    String selectedGame; 
}

class ResultParam {
  ResultParam({required this.wrongCount, required this.decreaseFactor});

  final int wrongCount;
  final int decreaseFactor;
}