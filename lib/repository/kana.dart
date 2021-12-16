import 'dart:convert';

import 'package:flutter/services.dart';

class Kana {
  Kana({required this.rune, required this.spelling});

  final String rune;
  final String spelling;
  Kana.fromJson(Map<String, dynamic> json) 
  : rune = json["rune"],
    spelling = json["spelling"];
}

class KanaRepository {
  static List<Kana> _hiraganaCache = [];
  static List<Kana> _katakanaCache = [];

  static Future<List<Kana>> _hiragana() async {
    if(_hiraganaCache.isNotEmpty) {
        print("from cache hiragana");
      return _hiraganaCache;
    }
    List<Kana> hiras = [];
    const source = 'assets/kanji/hiragana.json';

    final jsonData = await rootBundle.loadString(source);
    var data = jsonDecode(jsonData);
    
    for (var json in (data as List)) {
      var kanji = Kana.fromJson(json);
      hiras.add(kanji);
    }
    _hiraganaCache = hiras;
    return _hiraganaCache;
  }

  static Future<List<Kana>> _katakana() async {
    if(_katakanaCache.isNotEmpty) {
      print("from cache katakana");

      return _katakanaCache;
    }
    List<Kana> katas = [];
    const source = 'assets/kanji/katakana.json';

    final jsonData = await rootBundle.loadString(source);
    var data = jsonDecode(jsonData);
    
    for (var json in (data as List)) {
      var kanji = Kana.fromJson(json);
      katas.add(kanji);
    }

    _katakanaCache = katas;
    return _katakanaCache;
  }

  static Future<List<Kana>> hiragana(List<String> exceptions) async {
    var hiraganas = await _hiragana();

    var filtered = hiraganas.where((hira) => !exceptions.contains(hira.rune)).toList();

    return filtered;
  }

}