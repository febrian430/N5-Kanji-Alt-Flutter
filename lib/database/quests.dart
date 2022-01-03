import 'dart:async';
import 'dart:developer';

import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/scoring/model.dart';
import 'package:sqflite/sqflite.dart';

const _tableQuests = "quests";
const _columnId = "id";
const _columnGame = "game";
const _columnMode = "mode";
const _columnChapter = "chapter";
const _columnIsPerfect = "is_perfect";
const _columnGoldReward = "gold_reward";
const _columnCount = "count";
const _columnTotal = "total";
const _columnStatus = "status";
const _columnType = "type";

const _enumQuiz = "quiz";
const _enumPractice = "practice";

class QuestProvider {
  final Database db;

  QuestProvider(this.db);

  static Future migrate(Database db) async {
    log("CREATING PRACTICE QUEST TABLE");
    await db.execute('''
    create table $_tableQuests ( 
      $_columnId integer primary key,
      $_columnGame null,
      $_columnMode text check($_columnMode IN ('${GAME_MODE.imageMeaning.name}', '${GAME_MODE.reading.name}', null)),
      $_columnChapter int not null,
      $_columnIsPerfect int not null default 0,
      $_columnGoldReward int not null,
      $_columnCount int not null,
      $_columnTotal int not null,
      $_columnStatus text check($_columnStatus IN ('${QUEST_STATUS.CLAIMED.name}', '${QUEST_STATUS.ONGOING.name}', '${QUEST_STATUS.COMPLETE.name}')) not null,
      $_columnType text check($_columnType IN ('$_enumQuiz','$_enumPractice')) not null
    )
    ''');
  }

  Future createPractice(PracticeQuest quest) async {
    quest.id = await db.insert(_tableQuests, quest.toMap());
  }

  Future createQuiz(QuizQuest quest) async {
    quest.id = await db.insert(_tableQuests, quest.toMap());
  }

  FutureOr<bool> claimPractice(PracticeQuest quest) async {
    quest.status = QUEST_STATUS.CLAIMED;
    return await db.update(_tableQuests, quest.toMap(),
      where: '$_columnId = ?',
      whereArgs: [quest.id]
    ) > 0;
  }

  Future<List<PracticeQuest>> getOnGoingPractice() async {
    var raw = await db.query(_tableQuests,
      where: '$_columnType = ? AND  $_columnStatus = ?',
      whereArgs: [_enumPractice, QUEST_STATUS.ONGOING.name]
    );

    return raw.map((questRaw) => PracticeQuest.fromMap(questRaw)).toList();
  }

  FutureOr<bool> updatePractice(PracticeQuest quest) async {
    return await db.update(_tableQuests, quest.toMap(),
        where: '$_columnId = ?',
        whereArgs: [quest.id]
    ) > 0;
  }

  FutureOr<bool> updateQuiz(QuizQuest quest) async {
    return await db.update(_tableQuests, quest.toMap(),
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
      _columnStatus: status.name,
      _columnType: _enumPractice,
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
    if(count == total) {
      status = QUEST_STATUS.COMPLETE;
    }
    SQLRepo.quests.updatePractice(this);
    return true;
  }

  void claim() {
    if(status != QUEST_STATUS.CLAIMED && count >= total) {
      SQLRepo.userPoints.addGold(goldReward);
      status = QUEST_STATUS.CLAIMED;
      SQLRepo.quests.updatePractice(this);
    }
  }
}

class QuizQuest {
  int? id;
  final int? chapter;
  final int requiresPerfect;
  final int goldReward;

  final int total;
  int count = 0;
  QUEST_STATUS status = QUEST_STATUS.ONGOING;

  QuizQuest({required this.chapter, required this.requiresPerfect, required this.total, required this.goldReward});

  QuizQuest.fromMap(Map<String, dynamic> map):
      id = map[_columnId],
      chapter = map[_columnChapter] as int,
      requiresPerfect = map[_columnIsPerfect] as int,
      goldReward = map[_columnGoldReward] as int,
      count = map[_columnCount] as int,
      total = map[_columnTotal] as int,
      status = QUEST_STATUS_MAP.fromString(map[_columnStatus])!;

  Map<String, Object?> toMap() {
    return <String, Object?> {
      _columnChapter: chapter,
      _columnIsPerfect: requiresPerfect,
      _columnGoldReward: goldReward,
      _columnCount: count,
      _columnTotal: total,
      _columnStatus: status.name,
      _columnType: _enumQuiz,
    };
  }

  bool evaluate(QuizReport report) {

    if(chapter != null && chapter != report.chapter) {
      return false;
    }

    if(requiresPerfect == 1 && (report.multiple.miss != 0 || report.jumble.miss == 0)) {
      return false;
    }

    count++;
    if(count == total) {
      status = QUEST_STATUS.COMPLETE;
    }
    SQLRepo.quests.updateQuiz(this);
    return true;
  }

  void claim() {
    if(status != QUEST_STATUS.CLAIMED && count >= total) {
      SQLRepo.userPoints.addGold(goldReward);
      status = QUEST_STATUS.CLAIMED;
      SQLRepo.quests.updateQuiz(this);
    }
  }
}