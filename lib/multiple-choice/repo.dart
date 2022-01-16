import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


class MultipleChoiceQuestionMaker {
  static Future<List<QuestionSet>> makeQuestionSet(int n, int chapter, GAME_MODE mode) async {
    var kanjis = await SQLRepo.gameQuestions.byChapterForQuestion(chapter, n, 1/2, false, mode);

    return _makeQuestionSetsFrom(kanjis, mode);
  }

  static Future<List<QuizQuestionSet>> makeQuizQuestionSet(int n, int chapter, GAME_MODE mode) async {
    var examples = await SQLRepo.gameQuestions.byChapterForQuestion(chapter, n, 1/2, true, mode);

    List<List<int>> fromKanjiIds = examples.map((e) => e.exampleOf).toList();

    var basicQuestionSets = await _makeQuestionSetsFrom(examples, mode);
    return basicQuestionSets.mapIndexed((basic, i) {
      return QuizQuestionSet(
        question: basic.question,
        options: basic.options,
        fromKanji: fromKanjiIds[i]
      );
    }).toList();
  }

  static Future<List<QuestionSet>> _makeQuestionSetsFrom(List<Example> kanjis, GAME_MODE mode) async {
    var exampleOptions = await SQLRepo.gameQuestions.byChapter(kanjis[0].chapter);
    List<QuestionSet> questionSets = [];
    for (var i = 0; i < kanjis.length; i++) {
      questionSets.add(await _makeQuestionSet(kanjis[i], mode, exampleOptions));
    }
    return questionSets;
  }

  static Future<QuestionSet> _makeQuestionSet(Example kanji, GAME_MODE mode, List<Example> exampleOptions) async {
    Question question;
    List<Option> options;
    if(mode == GAME_MODE.imageMeaning){
      question = Question(key: kanji.id.toString(), isImage: true, value: kanji.image);
    } else {
      question = Question(key: kanji.id.toString(), isImage: false, value: kanji.rune);
    }
    options = await _findOptionsFor(kanji, mode, exampleOptions);

    return QuestionSet(question: question, options: options);
  }

  static Future<List<Option>> _findOptionsFor(Example question, GAME_MODE mode, List<Example> exampleOptions) async {
    List<Option> options;

    var otherOptions = exampleOptions.where((kanji) => kanji.id != question.id && question.isSingle == kanji.isSingle).toList();
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
}
