import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/models/multiple_choice.model.dart';



class KanjiExample {
  const KanjiExample({required this.id, required this.rune, required this.meaning, required this.spelling, required this.image, required this.chapter});
  final int id;
  final String rune;
  final String meaning;
  final String spelling;
  final String image;
  final int chapter;

  KanjiExample.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        rune = json['rune'],
        meaning = json['meaning'],
        spelling = json['spelling'],
        image = json['image'],
        chapter = json['chapter'];        
}

List<KanjiExample> _distincts = [];

Future<List<KanjiExample>> kanjiExamples() async {
  if(_distincts.length > 0) {
    return _distincts;
  }
  const source = 'assets/kanji/distinct_test.json';
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
  var data = await kanjiExamples();
  return data.where((KanjiExample kanji) => kanji.chapter == chapter).toList();
}




