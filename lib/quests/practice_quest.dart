import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';
import 'package:kanji_memory_hint/scoring/model.dart';

class PracticeQuestHandler {
  static List<PracticeQuest> onGoingQuests = [];
  static void supplyQuests() async {
    onGoingQuests = await SQLRepo.quests.getOnGoingPractice();
  }

  static int checkForQuests(PracticeGameReport report) {
    var affected = 0;

    onGoingQuests.forEach((quest) { 
      var isAffected = quest.evaluate(report);
      affected += isAffected ? 1 : 0;
    });

    return affected;
  }

  static Future<List<PracticeQuest>> quests() async {
    onGoingQuests = await SQLRepo.quests.getOnGoingPractice();
    return onGoingQuests;
  }
}