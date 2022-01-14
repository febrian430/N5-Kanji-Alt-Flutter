import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/scoring/report.dart';

class PracticeGameArguments {
    PracticeGameArguments({required this.selectedGame, required this.gameType});

    GAME_TYPE gameType;
    int chapter = 1;
    GAME_MODE mode = GAME_MODE.imageMeaning;
    String selectedGame; 

    List<List<Question>>? mixMatchRestart;
    List<QuestionSet>? pickDropRestart;
    List<JumbleQuestionSet>? jumbleRestart;
}

class ResultParam {
  ResultParam({required this.onRestart, required this.route, required this.game, required this.chapter, required this.mode, required this.stopwatch, required this.score, required this.result});

  final PracticeScore score;
  final GameResult result;
  final String game;
  final int chapter;
  final GAME_MODE mode;
  final String route;
  final Stopwatch stopwatch;

  final Function() onRestart;
}