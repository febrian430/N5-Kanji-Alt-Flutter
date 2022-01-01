import 'package:kanji_memory_hint/database/quests.dart';
import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:kanji_memory_hint/quests/practice_quest.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class SQLRepo {
  static Database? db;
  static late final UserPointProvider userPoints;
  static late final QuestProvider quests;

  static Future drop() async {
    var path = await getDatabasesPath();
    var dbPath = join(path, "kantan_test.db");
    await deleteDatabase(dbPath);
  }

  static Future open() async {
    // await drop();
    var path = await getDatabasesPath();
    var dbPath = join(path, 'kantan_test.db');
    db ??= await openDatabase(dbPath, version: 1,
      onCreate: (Database db, int version) async {
        await UserPointProvider.migrate(db);
        await QuestProvider.migrate(db);
      }
    );

    userPoints = UserPointProvider(db!);
    quests = QuestProvider(db!);
    PracticeQuestHandler.supplyQuests();
  }
}