import 'package:kanji_memory_hint/database/kanji.dart';

class KanjiViewParam {
  List<Kanji> kanjis;
  int index;

  KanjiViewParam(this.kanjis, this.index);
}