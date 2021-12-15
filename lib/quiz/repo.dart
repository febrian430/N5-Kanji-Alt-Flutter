import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/jumble/repo.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/multiple-choice/repo.dart';

Future<List> getQuizQuestions(int chapter, GAME_MODE mode) async {
  List<QuestionSet> mulchoice = await multipleChoiceQuestionSet(5, chapter, mode);
  List<JumbleQuestionSet> jumbleQset = await jumbleQuestionSets(5, chapter, mode);
  return [mulchoice, jumbleQset];
}