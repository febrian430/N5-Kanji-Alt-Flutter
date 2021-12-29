import 'package:sqflite/sqflite.dart';
import 'dart:async';



final String _userPointsTable = 'user_points';
final String _pointsColumn = 'points';
final String _expColumn = 'exp';


class UserPoint {
  int exp;
  int points;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      _pointsColumn: points,
      _expColumn: exp
    };
    return map;
  }

  UserPoint({required this.exp, required this.points});

  UserPoint.fromMap(Map<String, dynamic> map):
      exp = map[_expColumn] as int,
      points = map[_pointsColumn] as int;
}

class UserPointProvider {
  Database? db;

  Future open(String path) async {
    db ??= await openDatabase(path, version: 1,
        onCreate: (Database db, int version) 
        async {
          await db.execute('''
          create table $_userPointsTable ( 
            $_pointsColumn integer not null,
            $_expColumn integer not null)
          ''');
          UserPoint userPoint = UserPoint(exp: 0, points: 0);
          await db.insert(_userPointsTable, userPoint.toMap());
        }
    );
  }

  Future<UserPoint> get() async {
    List<Map<String, dynamic>> maps = await db!.query(
      _userPointsTable,
      columns: [_expColumn, _pointsColumn]
    );
    
    return UserPoint.fromMap(maps.first);
  }

  FutureOr<void> addExp(int exp) async {
    var userPoints = await get();
    userPoints.exp += exp;
    await db!.update(_userPointsTable, userPoints.toMap());
  }

  FutureOr<void> addPoints(int points) async {
    var userPoints = await get();
    userPoints.points += points;
    await db!.update(_userPointsTable, userPoints.toMap());
  }

  FutureOr<void> addExpAndPoints(int points, int exp) async {
    var userPoints = await get();
    userPoints.points += points;
    userPoints.exp += exp;
    await db!.update(_userPointsTable, userPoints.toMap());
  }

  Future close() async => db!.close();
}