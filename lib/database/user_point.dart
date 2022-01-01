import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'dart:async';



final String _userPointsTable = 'user_points';
final String _goldColumn = 'gold';
final String _expColumn = 'exp';


class UserPoint {
  int exp;
  int gold;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      _goldColumn: gold,
      _expColumn: exp
    };
    return map;
  }

  UserPoint({required this.exp, required this.gold});

  UserPoint.fromMap(Map<String, dynamic> map):
      exp = map[_expColumn] as int,
      gold = map[_goldColumn] as int;
}

class UserPointProvider {
  UserPointProvider(this.db);

  final Database db;

  static Future migrate(Database db) async {
    log("CREATING USER POINTS TABLE");
    await db.execute('''
    create table $_userPointsTable ( 
      $_goldColumn integer not null,
      $_expColumn integer not null)
    ''');
    UserPoint userPoint = UserPoint(exp: 0, gold: 0);
    await db.insert(_userPointsTable, userPoint.toMap());
  }

  Future<UserPoint> get() async {
    List<Map<String, dynamic>> maps = await db.query(
      _userPointsTable,
      columns: [_expColumn, _goldColumn]
    );
    
    return UserPoint.fromMap(maps.first);
  }

  FutureOr<void> addExp(int exp) async {
    var userPoints = await get();
    userPoints.exp += exp;
    await db.update(_userPointsTable, userPoints.toMap());
  }

  FutureOr<void> addGold(int gold) async {
    var userPoints = await get();
    userPoints.gold += gold;
    await db.update(_userPointsTable, userPoints.toMap());
  }

  FutureOr<void> addExpAndGold(int exp, int gold) async {
    var userPoints = await get();
    userPoints.gold += gold;
    userPoints.exp += exp;
    await db.update(_userPointsTable, userPoints.toMap());
  }

  Future close() async => db.close();
}