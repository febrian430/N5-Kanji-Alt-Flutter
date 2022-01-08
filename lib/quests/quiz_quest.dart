import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/scoring/report.dart';

class QuizQuestHandler {
  static List<QuizQuest> _ongoingQuests = [];

  static void supplyQuests() async {
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