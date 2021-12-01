import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/repository/repo.dart';

typedef DestroyerFunc = List<String> Function(KanjiExample kanji);

DestroyerFunc getDestroyer(GAME_MODE mode){
  if(mode == GAME_MODE.imageMeaning){
    return _breakRuneAsKey;
  } else {
    return _breakSpellingAsKey;
  }
}

List<String> _breakRuneAsKey(KanjiExample kanji) {
  return kanji.rune.split("");
}

List<String> _breakSpellingAsKey(KanjiExample kanji) {
  return kanji.spelling.split("");
}