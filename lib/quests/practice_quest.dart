import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:kanji_memory_hint/mix-match/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';
import 'package:kanji_memory_hint/scoring/model.dart';

class PracticeQuest {
  final String game;
  final GAME_MODE? mode;
  final int? chapter;
  final bool requiresPerfect;
  
  final int total;
  int count = 0;

  final int goldReward;

  bool claimed = false;

  PracticeQuest({required this.game, required this.mode, required this.chapter, required this.requiresPerfect, required this.total, required this.goldReward});

  bool evaluate(PracticeGameReport report) {
    
    if(game != report.game) {
      return false;
    }

    if(mode != null && mode != report.mode){
      return false;
    }

    if(chapter != null && chapter != report.chapter) {
      return false;
    }

    if(requiresPerfect && report.result.perfectRounds != GameNumOfRounds) {
      return false;
    }

    count++;
    return true;
  }

  void claim() {
    if(!claimed && count >= total) {
      SQLRepo.userPoints.addGold(goldReward);
      claimed = true;
    }
  }
}

class PracticeQuestHandler {
  static List<PracticeQuest> onGoingQuests = [];

  static void supplyQuests() {
    onGoingQuests = [
      PracticeQuest(
        game: MixMatchGame.name, 
        mode: GAME_MODE.reading, 
        chapter: 1, 
        requiresPerfect: false, 
        total: 5, 
        goldReward: 5
      ),
      PracticeQuest(
        game: PickDrop.name, 
        mode: GAME_MODE.imageMeaning, 
        chapter: 1, 
        requiresPerfect: false, 
        total: 2, 
        goldReward: 10
      )
    ];
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