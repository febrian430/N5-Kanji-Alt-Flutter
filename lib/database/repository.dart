import 'package:kanji_memory_hint/database/user_point.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class SQLRepo {
  static final UserPointProvider userPoints = UserPointProvider();

  static Future open() async {
    var path = await getDatabasesPath();
    var dbPath = join(path, 'kantan_test.db');

    await userPoints.open(dbPath);
  }
}