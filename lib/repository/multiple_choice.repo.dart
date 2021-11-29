import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/repository/repo.dart';

Future<List<QuestionSet>> multipleChoiceQuestionSet(int n) async {
  final kanjis = await kanjiExamples();
  
  return _makeQuestionSetsFrom(kanjis, n);
}

Future<List<QuestionSet>> _makeQuestionSetsFrom(List<KanjiExample> kanjis, int n) async {
  List<QuestionSet> questionSets = [];
  for (var i = 0; i < n; i++) {
    questionSets.add(await _makeQuestionSet(kanjis[i]));
  }
  questionSets.shuffle();
  return questionSets;
}

Future<QuestionSet> _makeQuestionSet(KanjiExample kanji) async {
  final question = Question(key: kanji.id, isImage: false, value: kanji.image);
  final options = await _findOptionsFor(kanji);
  return QuestionSet(question: question, options: options);
}

Future<List<Option>> _findOptionsFor(KanjiExample question) async {
  var kanjis = await kanjiExamples();
  var otherOptions = kanjis.where((kanji) => kanji.id != question.id).toList();
  otherOptions.shuffle();
  otherOptions = otherOptions.take(3).toList();
  List<Option> options = [
    Option(value: question.meaning, key: question.id),
    ...otherOptions.map((opt) => Option(value: opt.rune, key: opt.id))
  ];
  options.shuffle();
  return options;
}