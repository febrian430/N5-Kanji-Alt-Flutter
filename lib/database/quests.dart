import 'dart:async';
import 'dart:developer';

import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/scoring/model.dart';
import 'package:sqflite/sqflite.dart';

const _tablePracticeQuests = "practice_quests";
const _columnId = "id";
const _columnGame = "game";
const _columnMode = "mode";
const _columnChapter = "chapter";
const _columnIsPerfect = "is_perfect";
const _columnGoldReward = "gold_reward";
const _columnCount = "count";
const _columnTotal = "total";
const _columnStatus = "status";

class QuestProvider {
  final Database db;

  QuestProvider(this.db);

  static Future migrate(Database db) async {
    log("CREATING QUEST TABLE");
    await db.execute('''
    create table $_tablePracticeQuests ( 
      $_columnId integer primary key,
      $_columnGame text not null,
      $_columnMode text check($_columnMode IN ('${GAME_MODE.imageMeaning.name}', '${GAME_MODE.reading.name}')) not null,
      $_columnChapter int not null,
      $_columnIsPerfect int not null default 0,
      $_columnGoldReward int not null,
      $_columnCount int not null,
      $_columnTotal int not null,
      $_columnStatus text check($_columnStatus IN ('${QUEST_STATUS.CLAIMED.name}', '${QUEST_STATUS.ONGOING.name}')) not null
    )
    ''');
  }

  Future createPractice(PracticeQuest quest) async {
    db.insert(_tablePracticeQuests, quest.toMap());
  }

  FutureOr<bool> claimPractice(PracticeQuest quest) async {
    quest.status = QUEST_STATUS.CLAIMED;
    return await db.update(_tablePracticeQuests, quest.toMap(), 
      where: '$_columnId = ?',
      whereArgs: [quest.id]
    ) > 0;
  }

  Future<List<PracticeQuest>> getOnGoingPractice() async {
    var raw = await db.query(_tablePracticeQuests,
      where: '$_columnStatus = ?',
      whereArgs: [QUEST_STATUS.ONGOING.name]
    );

    return raw.map((questRaw) => PracticeQuest.fromMap(questRaw)).toList();
  }

  FutureOr<bool> update(PracticeQuest quest) async {
    return await db.update(_tablePracticeQuests, quest.toMap(),
      where: '$_columnId = ?',
      whereArgs: [quest.id]
    ) > 0;
  }
}

class PracticeQuest {
  int? id;
  final String game;
  GAME_MODE? mode;
  final int? chapter;
  final int requiresPerfect;
  
  final int total;
  int count = 0;

  final int goldReward;

  QUEST_STATUS status = QUEST_STATUS.ONGOING;

  PracticeQuest({required this.game, required this.mode, required this.chapter, required this.requiresPerfect, required this.total, required this.goldReward});

  PracticeQuest.fromMap(Map<String, dynamic> map):
      id = map[_columnId] as int,
      game = map[_columnGame] as String,
      chapter = map[_columnChapter] as int,
      requiresPerfect = map[_columnIsPerfect] as int,
      count = map[_columnCount] as int,
      total = map[_columnTotal] as int,
      goldReward = map[_columnGoldReward] as int
  {
        var statusDb = map[_columnStatus] as String;
        var modeDb = map[_columnMode] as String;

        status = QUEST_STATUS_MAP.fromString(statusDb)!;
        mode = GAME_MODE_MAP.fromString(modeDb)!;
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      _columnGame: game, 
      _columnMode: mode?.name,
      _columnChapter: chapter, 
      _columnIsPerfect: requiresPerfect, 
      _columnGoldReward: goldReward, 
      _columnCount: count, 
      _columnTotal: total, 
      _columnStatus: status.name
    };
  }
      

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

    if(requiresPerfect == 1 && report.result.perfectRounds != GameNumOfRounds) {
      return false;
    }

    count++;
    SQLRepo.quests.update(this);
    return true;
  }

  void claim() {
    if(status == QUEST_STATUS.ONGOING && count >= total) {
      SQLRepo.userPoints.addGold(goldReward);
      status = QUEST_STATUS.CLAIMED;
      SQLRepo.quests.update(this);
    }
  }
}