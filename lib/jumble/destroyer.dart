import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/repository/repo.dart';

typedef DestroyerFunc = List<String> Function(KanjiExample kanji);

DestroyerFunc getDestroyer(GAME_MODE mode){
    return _breakRuneAsKey;
}

List<String> _breakRuneAsKey(KanjiExample kanji) {
  return kanji.rune.split("#");
}