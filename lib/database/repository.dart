import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/game_provider.dart';
import 'package:kanji_memory_hint/database/kanji.dart';
import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/reminder.dart';
import 'package:kanji_memory_hint/database/user_flags.dart';
import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:kanji_memory_hint/quests/quiz_quest.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class SQLRepo {
  static Database? db;
  static late final UserPointProvider userPoints;
  static late final QuestProvider quests;
  static late final KanjiProvider kanjis;
  static late final ExampleProvider examples;
  static late final GameQuestionProvider gameQuestions;
  static late final ReminderProvider reminder;
  static late final UserFlagsProvider userFlags;

  static Future drop() async {
    var path = await getDatabasesPath();
    var dbPath = join(path, "kantan_test.db");
    await deleteDatabase(dbPath);
  }

  static Future open() async {
    if(MIGRATE) {
      await drop();
    }

    bool initial = false;
    var path = await getDatabasesPath();
    var dbPath = join(path, 'kantan_test.db');
    db ??= await openDatabase(dbPath, version: 1,
      onCreate: (Database db, int version) async {
        await UserPointProvider.migrate(db);
        await QuestProvider.migrate(db);
        await KanjiProvider.migrate(db);
        await ExampleProvider.migrate(db);
        await ReminderProvider.migrate(db);
        await UserFlagsProvider.migrate(db);
        initial = true;
      }
    );

    userPoints = UserPointProvider(db!);
    quests = QuestProvider(db!);
    kanjis = KanjiProvider(db!);
    examples = ExampleProvider(db!);
    gameQuestions = GameQuestionProvider(kanjis, examples);
    reminder = ReminderProvider(db!);
    userFlags = UserFlagsProvider(db!);

    if(initial){
      await kanjis.seed();
      await examples.seed();
      await quests.seed();
    }

    PracticeQuestHandler.supplyQuests();
    QuizQuestHandler.supplyQuests();


  }
}