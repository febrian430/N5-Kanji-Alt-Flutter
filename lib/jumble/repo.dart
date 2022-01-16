import 'dart:developer';
import 'dart:math';

import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/jumble/model.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/map_indexed.dart';


const TOTAL_OPTIONS = 8;

class JumbleQuestionMaker {
  static Future<List<JumbleQuestionSet>> makeQuestionSet(int n, int chapter, GAME_MODE mode) async {
    var examples = await SQLRepo.gameQuestions.byChapterForQuestion(chapter, n, 1/2, false, mode);

    return _build(examples, mode);
  }

  static Future<List<JumbleQuizQuestionSet>> makeQuizQuestionSet(int n, int chapter, GAME_MODE mode) async {
    var examples = await SQLRepo.gameQuestions.byChapterForQuestion(chapter, n, 1/2, true, mode);
    List<List<int>> fromKanji = examples.map((e) => e.exampleOf).toList();

    var basicQuestionSet = await _build(examples, mode);

    return basicQuestionSet.mapIndexed((basic, i) {
      return JumbleQuizQuestionSet(
          question: basic.question,
          options: basic.options,
          fromKanji: fromKanji[i]
      );
    }).toList();
  }


  static Future<List<JumbleQuestionSet>> _build(List<Example> kanjis, GAME_MODE mode) async {

    if(mode == GAME_MODE.imageMeaning) {

      var distinctRunes = await SQLRepo.gameQuestions.distinctExampleRune(kanjis[0].chapter);
      return kanjis.map((kanji) {
        return _makeImageMeaning(kanji, distinctRunes, mode);
      }).toList();
    } else {
      List<JumbleQuestionSet> sets = [];
      var charsInChapter = await SQLRepo.gameQuestions.distinctSyllables(kanjis[0].chapter);
      for (var kanji in kanjis) {
        sets.add(await _makeReading(kanji, charsInChapter));
      }

      return sets;
    }
  }

  static List<String> _makeReadingOptions(Example kanji, List<String> distinct) {
    final keysToTake = TOTAL_OPTIONS - kanji.spelling.length;

    Set<String> except = <String>{};
    except.addAll(kanji.spelling);

    distinct.shuffle(Random(Timeline.now));

    var otherOptions = distinct.where((syllable) => !except.contains(syllable)).take(keysToTake).toList();

    var options = kanji.spelling + otherOptions;
    options.shuffle();
    return options;
  }

  static Future<JumbleQuestionSet> _makeReading(Example kanji, List<String> distinct) async {

    String questionVal = kanji.rune;
    var optionVals = _makeReadingOptions(kanji, distinct);

    JumbleQuestion question = JumbleQuestion(value: questionVal, key: kanji.spelling, isImage: false);
    List<Option> options = optionVals.mapIndexed((value, i) {
      return Option(id: i, value: value, key: value);
    }).toList();

    return JumbleQuestionSet(question: question, options: options);
  }

  static List<String> _makeImageMeaningOptions(Example kanji,  List<String> distinctRunes) {
    var correctKeys = kanji.rune.split('');
    final keysToTake = TOTAL_OPTIONS - correctKeys.length;
    var possible = distinctRunes.where((rune) => !correctKeys.contains(rune)).toList();
    possible.shuffle();
    var chosens = possible.take(keysToTake).toList();

    var options = correctKeys + chosens;
    options.shuffle();
    return options;
  }

  static JumbleQuestionSet _makeImageMeaning(Example kanji, List<String> distinctRunes, GAME_MODE mode) {

    String questionVal = kanji.image;

    List<String> correctKeys = kanji.rune.split("");

    List<String> optionVals = _makeImageMeaningOptions(kanji, distinctRunes);

    JumbleQuestion question = JumbleQuestion(value: questionVal, key: correctKeys, isImage: GAME_MODE.imageMeaning == mode);
    List<Option> options = optionVals.mapIndexed((value, i) {
      return Option(id: i, value: value, key: value);
    }).toList();

    return JumbleQuestionSet(question: question, options: options);
  }
}
