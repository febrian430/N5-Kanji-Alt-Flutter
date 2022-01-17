import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/models/common.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
import 'package:quiver/testing/src/time/time.dart';

class MixMatchQuestionMaker {
  static Future<List<List<Question>>> makeOptions(int n, int chapter, GAME_MODE mode) async {

    List<List<Question>> options = [];

    var singles = await SQLRepo.gameQuestions.byChapter(chapter, single: true, hasImage: mode == GAME_MODE.imageMeaning ? true : null);
    var doubles = await SQLRepo.gameQuestions.byChapter(chapter, single: false, hasImage: mode == GAME_MODE.imageMeaning ? true : null);

    singles.shuffle();
    doubles.shuffle();

    singles = singles.take(n).toList();
    doubles = doubles.take(n).toList();

    if(mode == GAME_MODE.imageMeaning) {
      options = await Future.wait([_makeImageMeaningOptions(singles), _makeImageMeaningOptions(doubles)]);
    } else {
      options =  await Future.wait([_makeReadingOptions(singles), _makeReadingOptions(doubles)]);
    }

    return options;
  }

  static Future<List<Question>> _makeImageMeaningOptions(List<Example> candidates) async {
    List<Question> imageOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index, value: kanji.image, key: kanji.id.toString(), isImage: true);
    }).toList();

    var last = imageOptions.length;

    List<Question> runeOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index+last, value: kanji.rune, key: kanji.id.toString());
    }).toList();

    final List<Question> options = [...imageOptions, ...runeOptions];
    options.shuffle();

    return options;
  }

  static Future<List<Question>> _makeReadingOptions(List<Example> candidates) async {
    List<Question> runeOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index, value: kanji.rune, key: kanji.id.toString());
    }).toList();

    var last = runeOptions.length;

    List<Question> spellingOptions = candidates.mapIndexed((kanji, index) {
      return Question(id: index+last, value: kanji.spelling.join(""), key: kanji.id.toString());
    }).toList();

    final List<Question> options = [...runeOptions, ...spellingOptions];
    options.shuffle();

    return options;
  }
}
