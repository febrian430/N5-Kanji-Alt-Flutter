import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/models/common.dart';

const _minChapter = 1;
const _maxChapter = 8;

class KanjiExample {
  KanjiExample({required this.id, required this.rune, required this.meaning, required this.spelling, required this.image, required this.chapter, required this.isSingle});
  final int id;
  final String rune;
  final String meaning;
  late final List<String> spelling;
  final String image;
  late final bool isSingle;
  final int chapter;

  KanjiExample.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        rune = json['rune'],
        meaning = json['meaning'],
        image = json['image'],
        chapter = json['chapter'] {

      spelling = (json['spelling'] as List).map((spellDynamic) {
        return spellDynamic.toString();
      }).toList();


      if(json['is_single'] != null){
        isSingle = json['is_single'] as bool;
      } else {
        isSingle = false;
      }

  }
}

List<KanjiExample> _distincts = [];



Future<List<KanjiExample>> _kanjiExamples() async {
  if(_distincts.length > 0) {
    return _distincts;
  }
  const source = 'assets/kanji/examples.json';
  // const source = 'distinct.json';
  final jsonData = await rootBundle.loadString(source);
  var data = jsonDecode(jsonData);
  // print(data);
  for (var element in (data as List)) {
    _distincts.add(KanjiExample.fromJson(element));
  }

  return _distincts;
}

Future<List<KanjiExample>> ByChapter(int chapter) async {
  var data = await _kanjiExamples();
  return data.where((KanjiExample kanji) => kanji.chapter == chapter).toList();
}

Future<List<KanjiExample>> ByChapterWithSingle(int chapter, bool isSingle) async {
  var data = await ByChapter(chapter);

  var list = data.where((KanjiExample kanji) => kanji.isSingle == isSingle);
  list.toList().shuffle();
  return list.toList();
}

Future<List<KanjiExample>> ByChapterForQuestion(int chapter, int n, double ratio, bool quiz) async {
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

Future<List<KanjiExample>> ByChapterRandom(int chapter) async {
  var data = await ByChapter(chapter);
  data.shuffle(Random(Timeline.now));
  return data;
}

Future<List<KanjiExample>> random({int n = 10, int startChapter = _minChapter, int endChapter = _maxChapter}) async {
  List<KanjiExample> kanjis = [];
  startChapter = max(startChapter, _minChapter);
  endChapter = min(endChapter, _maxChapter);

  for (var i = startChapter; i <= endChapter; i++) {
    kanjis += await ByChapter(i);
  }

  kanjis.shuffle(Random(Timeline.now));
  return kanjis.take(n).toList();
}




