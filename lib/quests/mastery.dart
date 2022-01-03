import 'package:kanji_memory_hint/database/repository.dart';

class MasteryHandler {
  static Future<void> addMastery(List<int> kanjiIds) async {
    for (var kanjiId in kanjiIds) {
      SQLRepo.kanjis.addMastery(kanjiId);
    }
  }
}