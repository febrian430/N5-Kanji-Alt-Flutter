import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/repository/repo.dart';

Future<List<QuestionSet>> getPickDropQuestionSets(int n, int chapter, GAME_MODE mode) async {
  var kanjis = await ByChapterRandom(chapter);
  kanjis = kanjis.take(n).toList();
  List<QuestionSet> questionSets = [];
  
  for (var kanji in kanjis) {
    questionSets.add(await _imageMeaning(kanji));
  }
  return questionSets;
}

Future<QuestionSet> _imageMeaning(KanjiExample kanji) async {
  List<Option> options = await _findOptionsFor(8, kanji, GAME_MODE.imageMeaning);

  Question question = Question(value: kanji.image, key: kanji.id.toString(), isImage: true);
  return QuestionSet(question: question, options: options);
}


Future<List<Option>> _findOptionsFor(int n, KanjiExample question, GAME_MODE mode) async {
  List<Option> options;

  var kanjis = await random(n: n-1, startChapter: question.chapter-1, endChapter: question.chapter+1);
  var otherOptions = kanjis.where((kanji) => kanji.id != question.id).toList();
  otherOptions.shuffle();
  otherOptions = otherOptions.take(n-1).toList();
  if(mode == GAME_MODE.imageMeaning) {
    options = [
      Option(value: question.meaning, key: question.id.toString()),
      ...otherOptions.map((opt) => Option(value: opt.rune, key: opt.id.toString()))
    ];
  } else {
    options = [
        Option(value: question.rune, key: question.id.toString()),
        ...otherOptions.map((opt) => Option(value: opt.spelling, key: opt.id.toString()))
    ];
  }
  options.shuffle();
  return options;
}

