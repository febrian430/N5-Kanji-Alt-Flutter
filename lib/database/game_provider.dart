import 'dart:developer';
import 'dart:math';

import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/kanji.dart';

class GameQuestionProvider {
  final KanjiProvider _kanji;
  final ExampleProvider _exampleProvider;

  GameQuestionProvider(this._kanji, this._exampleProvider);

  Future<List<Example>> byChapterForQuestion(int chapter, int n, double ratio, bool quiz) async {
    int singleCount = (n * ratio).floor();
    int doubleCount = n - singleCount;

    var futures = await Future.wait(
        [_exampleProvider.byChapter(chapter, single: true), _exampleProvider.byChapter(chapter, single: false)]);
    futures[0].shuffle();
    futures[1].shuffle();
    var combined = [
      ...futures[0].take(singleCount),
      ...futures[1].take(doubleCount)
    ];

    if (quiz == true) {
      combined.shuffle();
    }

    return combined;
  }

  Future<List<Example>> byChapter(int chapter, {bool? single, bool? hasImage}) async {
    return _exampleProvider.byChapter(chapter, single: single, hasImage: hasImage);
  }

  Future<List<String>> distinctExampleRune(int chapter) async {
    var examples = await byChapter(chapter);
    Set<String> seen = {};
    List<String> distinct = [];


    for(var example in examples) {
      for(var rune in example.rune.split('')){
        if(!seen.contains(rune)) {
          distinct.add(rune);
          seen.add(rune);
        }
      }
    }
    return distinct;
  }

  Future<List<String>> distinctSyllables(int chapter) async {
    Set<String> seen = <String>{};
    List<String> distinct = [];
    var examples = await byChapter(chapter);

    for (var example in examples) {
      for(var spelling in example.spelling){
        if(!seen.contains(spelling)) {
          distinct.add(spelling);
          seen.add(spelling);
        }
      }
    }
    return distinct;
  }

  Future<List<Example>> random({int n = 10, int startChapter = 1, int endChapter = GameNumOfRounds}) async {
    List<Example> kanjis = [];
    startChapter = max(startChapter, 1);
    endChapter = min(endChapter, GameNumOfRounds);

    for (var i = startChapter; i <= endChapter; i++) {
      kanjis += await _exampleProvider.byChapter(i);
    }

    kanjis.shuffle(Random(Timeline.now));
    return kanjis.take(n).toList();
  }
} 