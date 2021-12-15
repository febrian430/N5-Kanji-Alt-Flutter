import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/repository/repo.dart';

Future<List<QuestionSet>> multipleChoiceQuestionSet(int n, int chapter, GAME_MODE mode, bool quiz) async {
  var kanjis = await ByChapterForQuestion(chapter, n, 1/2, quiz);

  return _makeQuestionSetsFrom(kanjis, mode);
}

Future<List<QuestionSet>> _makeQuestionSetsFrom(List<KanjiExample> kanjis, GAME_MODE mode) async {
  List<QuestionSet> questionSets = [];
  for (var i = 0; i < kanjis.length; i++) {
    questionSets.add(await _makeQuestionSet(kanjis[i], mode));
  }
  return questionSets;
}

Future<QuestionSet> _makeQuestionSet(KanjiExample kanji, GAME_MODE mode) async {
  Question question;
  List<Option> options;
  if(mode == GAME_MODE.imageMeaning){
    question = Question(key: kanji.id.toString(), isImage: true, value: kanji.image);
  } else {
    question = Question(key: kanji.id.toString(), isImage: false, value: kanji.rune);
  }
  options = await _findOptionsFor(kanji, mode);

  return QuestionSet(question: question, options: options);
}

Future<List<Option>> _findOptionsFor(KanjiExample question, GAME_MODE mode) async {
  List<Option> options;

  var kanjis = await random(n: 5, startChapter: question.chapter-1, endChapter: question.chapter+1);
  var otherOptions = kanjis.where((kanji) => kanji.id != question.id).toList();
  otherOptions.shuffle();
  otherOptions = otherOptions.take(3).toList();
  if(mode == GAME_MODE.imageMeaning) {
    options = [
      Option(value: question.rune, key: question.id.toString()),
      ...otherOptions.map((opt) => Option(value: opt.rune, key: opt.id.toString()))
    ];
  } else {
    options = [
        Option(value: question.spelling.join(), key: question.id.toString()),
        ...otherOptions.map((opt) => Option(value: opt.spelling.join(), key: opt.id.toString()))
    ];
  }
  options.shuffle();
  return options;
}