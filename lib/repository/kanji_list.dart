import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/repository/repo.dart';

class Kanji {
  Kanji({required this.rune, required this.chapter});
  
  // final int id;
  final String rune;
  final int chapter;
  List<String> onyomi = [];
  List<String> kunyomi = [];
  List<KanjiExample> examples = [];

  Kanji.fromJson(Map<String, dynamic> json)
      : 
      // id = json['id'],
        rune = json['rune'],
        chapter = json['chapter']
  {
    for (var _kunyomi in json['kunyomi'] as List) {
      kunyomi.add(_kunyomi as String);
    }
    for (var _onyomi in json['onyomi'] as List) {
      onyomi.add(_onyomi as String);
    }
    for (var example in json['examples'] as List) {
      examples.add(KanjiExample.fromJson(example));
    }
  }  
}

List<Kanji> _kanjis = [];

Future<List<Kanji>> _all() async {
  const source = 'assets/kanji/kanji.json';

  final jsonData = await rootBundle.loadString(source);
  var data = jsonDecode(jsonData);
  // print(data);
  for (var element in (data as List)) {
    var kanji = Kanji.fromJson(element);
    _kanjis.add(kanji);
  }
  return _kanjis;
}

Future<List<Kanji>> kanjiList() async {
  if(_kanjis.isEmpty) {
    return await _all();
  }
  return _kanjis;
}