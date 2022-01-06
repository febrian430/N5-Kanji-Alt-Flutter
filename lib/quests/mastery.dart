import 'dart:developer';

import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/scoring/model.dart';

class MasteryHandler {
  static List<int> _flatten(List<List<int>> array) {
    if(array.isEmpty){
      return [];
    }
    return array.reduce((value, element) {
      print(value+element);
      return value+element;
    }).toList();
  }
  static Future<void> addMasteryFromQuiz(QuizReport report) async {
    var fromMC = _flatten(report.multiple.correctlyAnsweredKanji);
    print("jumble: ${report.jumble.correctlyAnsweredKanji.join(',')}");
    var fromJumble = _flatten(report.jumble.correctlyAnsweredKanji);
    List<int> combined = fromMC + fromJumble;
    log("ADDING MASTERY TO KANJI WITH ID: ${combined.join(", ")}");

    for (var kanjiId in combined) {
      SQLRepo.kanjis.addMastery(kanjiId);
    }

    await SQLRepo.quests.updateAndSyncForMastery();
  }

  static Future<List<MasteryQuest>> quests() async {
    return SQLRepo.quests.getOnGoingMasteryQuests();
  }

  
}