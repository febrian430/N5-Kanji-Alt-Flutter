import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/database/example.dart';

const _minChapter = 1;
const _maxChapter = 8;

List<Example> _distincts = [];



Future<List<Example>> kanjiExamples() async {
  if(_distincts.length > 0) {
    return _distincts;
  }
  const source = 'assets/kanji/examples_user_test.json';
  // const source = 'distinct.json';
  final jsonData = await rootBundle.loadString(source);
  var data = jsonDecode(jsonData);
  // print(data);
  for (var element in (data as List)) {
    // print(element['example_of']);
    _distincts.add(Example.fromJson(element));
  }

  return _distincts;
}

Future<List<Example>> ByChapter(int chapter) async {
  var data = await kanjiExamples();
  return data.where((Example kanji) => kanji.chapter == chapter).toList();
}

Future<List<Example>> ByChapterWithSingle(int chapter, bool isSingle) async {
  var data = await ByChapter(chapter);

  var list = data.where((Example kanji) => kanji.isSingle == isSingle);
  list.toList().shuffle();
  return list.toList();
}

Future<List<Example>> ByChapterForQuestion(int chapter, int n, double ratio, bool quiz) async {
  int singleCount = (n*ratio).floor();
  print(singleCount);
  int doubleCount = n - singleCount;

  var futures = await Future.wait([ByChapterWithSingle(chapter, true), ByChapterWithSingle(chapter, false)]);
  futures[0].shuffle();
  futures[1].shuffle();
  var combined = [...futures[0].take(singleCount), ...futures[1].take(doubleCount)];
  
  if(quiz == true){
    combined.shuffle();
  }

  return combined;
}

Future<List<Example>> ByChapterRandom(int chapter) async {
  var data = await ByChapter(chapter);
  data.shuffle(Random(Timeline.now));
  return data;
}

Future<List<Example>> random({int n = 10, int startChapter = _minChapter, int endChapter = _maxChapter}) async {
  List<Example> kanjis = [];
  startChapter = max(startChapter, _minChapter);
  endChapter = min(endChapter, _maxChapter);

  for (var i = startChapter; i <= endChapter; i++) {
    kanjis += await ByChapter(i);
  }

  kanjis.shuffle(Random(Timeline.now));
  return kanjis.take(n).toList();
}




