import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:kanji_memory_hint/database/kanji.dart';

List<Kanji> _kanjis = [];

Future<List<Kanji>> _all() async {
  // const source = 'assets/kanji/kanji.json';
  const source = 'assets/kanji/kanji_user_test.json';

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