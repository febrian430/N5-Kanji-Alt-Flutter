import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/scoring/model.dart';

class PracticeQuestHandler {
  static List<PracticeQuest> onGoingQuests = [];
  static void supplyQuests() async {
    // onGoingQuests = [
    //   PracticeQuest(
    //     game: MixMatchGame.name,
    //     mode: GAME_MODE.reading,
    //     chapter: 1,
    //     requiresPerfect: 0,
    //     total: 5,
    //     goldReward: 5
    //   ),
    //   PracticeQuest(
    //     game: PickDrop.name,
    //     mode: GAME_MODE.imageMeaning,
    //     chapter: 1,
    //     requiresPerfect: 0,
    //     total: 2,
    //     goldReward: 10
    //   )
    // ];
    // onGoingQuests.forEach((element) {
    //   SQLRepo.quests.createPractice(element);
    // });
    onGoingQuests = await SQLRepo.quests.getOnGoingPractice();
    print(onGoingQuests);
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