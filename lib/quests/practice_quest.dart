import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';
import 'package:kanji_memory_hint/scoring/model.dart';

class PracticeQuestHandler {
  static List<PracticeQuest> onGoingQuests = [];
  static void supplyQuests() async {
    if(MIGRATE) {
      onGoingQuests = [
        PracticeQuest(
            game: JumbleGame.name,
            mode: null,
            chapter: 1,
            requiresPerfect: 0,
            total: 5,
            goldReward: 25
        ),
        PracticeQuest(
            game: PickDrop.name,
            mode: GAME_MODE.imageMeaning,
            chapter: 1,
            requiresPerfect: 0,
            total: 2,
            goldReward: 10
        )
      ];
      for (var element in onGoingQuests) {
        await SQLRepo.quests.create(element);
      }
    }
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
    return onGoingQuests;
  }
}