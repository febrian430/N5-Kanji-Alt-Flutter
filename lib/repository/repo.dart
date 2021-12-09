import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/models/common.dart';

const _minChapter = 1;
const _maxChapter = 10;

class KanjiExample {
  KanjiExample({required this.id, required this.rune, required this.meaning, required this.spelling, required this.image, required this.chapter});
  final int id;
  final String rune;
  final String meaning;
  late final List<String> spelling;
  final String image;
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




