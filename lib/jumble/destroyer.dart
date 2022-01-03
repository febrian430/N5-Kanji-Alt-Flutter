import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';

typedef DestroyerFunc = List<String> Function(Example kanji);

DestroyerFunc getDestroyer(GAME_MODE mode){
    return _breakRuneAsKey;
}

List<String> _breakRuneAsKey(Example kanji) {
  return kanji.rune.split("#");
}