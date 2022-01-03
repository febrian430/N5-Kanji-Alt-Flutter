import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/jumble/repo.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/repo.dart';

class QuizQuestionMaker {

  static Future<List> makeQuestionSet(int n, int chapter, GAME_MODE mode) async {
    List<QuizQuestionSet> mulchoice = await MultipleChoiceQuestionMaker
        .makeQuizQuestionSet(n, chapter, mode);
    List<JumbleQuizQuestionSet> jumbleQset = await JumbleQuestionMaker
        .makeQuizQuestionSet(n, chapter, mode);
    return [mulchoice, jumbleQset];
  }
}