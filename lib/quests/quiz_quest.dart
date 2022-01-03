import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/scoring/model.dart';

class QuizQuestHandler {
  static List<QuizQuest> _ongoingQuests = [];

  static void supplyQuests() async {
    if(MIGRATE) {
      _ongoingQuests = [
        QuizQuest(
            chapter: 1,
            requiresPerfect: 0,
            total: 5,
            goldReward: 5
        ),
        QuizQuest(
            chapter: 1,
            requiresPerfect: 0,
            total: 2,
            goldReward: 10
        )
      ];
      for (var element in _ongoingQuests) {
        await SQLRepo.quests.create(element);
      }
    }
    _ongoingQuests = await SQLRepo.quests.getOnGoingQuiz();
  }

  static int checkForQuests(QuizReport report) {
    var affected = 0;

    _ongoingQuests.forEach((quest) {
      var isAffected = quest.evaluate(report);
      affected += isAffected ? 1 : 0;
    });

    return affected;
  }

  static Future<List<QuizQuest>> quests() async {
    _ongoingQuests = await SQLRepo.quests.getOnGoingQuiz();
    return _ongoingQuests;
  }
}