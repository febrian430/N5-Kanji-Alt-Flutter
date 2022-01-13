import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/models/question_set.dart';

class PickDropQuestionMaker {
  static Future<List<QuestionSet>> makeQuestionSet(int n, int chapter, GAME_MODE mode) async {
    var kanjis = await SQLRepo.gameQuestions.byChapterForQuestion(chapter, n, 1/2, false);
    List<QuestionSet> questionSets = [];
    var optionKanjis = await SQLRepo.gameQuestions.byChapter(chapter);

    for (var kanji in kanjis) {
      questionSets.add(await _imageMeaning(kanji, optionKanjis));
    }
    return questionSets;
  }

  static Future<QuestionSet> _imageMeaning(Example kanji, List<Example> optionKanjis) async {
    List<Option> options = await _findOptionsFor(8, kanji, GAME_MODE.imageMeaning, optionKanjis);

    Question question = Question(value: kanji.image, key: kanji.id.toString(), isImage: true);
    return QuestionSet(question: question, options: options);
  }


  static Future<List<Option>> _findOptionsFor(int n, Example question, GAME_MODE mode, List<Example> optionKanjis) async {
    List<Option> options;

    var otherOptions = optionKanjis.where((kanji) => kanji.id != question.id).toList();
    otherOptions.shuffle();
    otherOptions = otherOptions.take(n-1).toList();
    
    if(mode == GAME_MODE.imageMeaning) {
      options = [
        Option(value: question.rune, key: question.id.toString()),
        ...otherOptions.map((opt) => Option(value: opt.rune, key: opt.id.toString()))
      ];
    } else {
      options = [
        Option(value: question.rune, key: question.id.toString()),
        ...otherOptions.map((opt) => Option(value: opt.spelling.join(), key: opt.id.toString()))
      ];
    }
    options.shuffle();
    return options;
  }

}

