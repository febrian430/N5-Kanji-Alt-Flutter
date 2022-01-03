import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
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

  Future create(Quest quest) async {
    quest.id = await db.insert(_tableQuests, quest.toMap());
  }

  FutureOr<bool> claim(Quest quest) async {
    quest.status = QUEST_STATUS.CLAIMED;
    return await db.update(_tableQuests, quest.toMap(),
      where: '$_columnId = ?',
      whereArgs: [quest.id]
    ) > 0;
  }

  Future<List<PracticeQuest>> getOnGoingPractice() async {
    var raw = await db.query(_tableQuests,
      where: '$_columnType = ? AND  $_columnStatus != ?',
      whereArgs: [_enumPractice, QUEST_STATUS.CLAIMED.name]
    );

    return raw.map((questRaw) => PracticeQuest.fromMap(questRaw)).toList();
  }

  Future<List<QuizQuest>> getOnGoingQuiz() async {
    var raw = await db.query(_tableQuests,
        where: '$_columnType = ? AND  $_columnStatus != ?',
        whereArgs: [_enumQuiz, QUEST_STATUS.CLAIMED.name]
    );

    return raw.map((questRaw) => QuizQuest.fromMap(questRaw)).toList();
  }

  FutureOr<bool> update(Quest quest) async {
    return await db.update(_tableQuests, quest.toMap(),
        where: '$_columnId = ?',
        whereArgs: [quest.id]
    ) > 0;
  }
}

abstract class Quest {
  int? id;
  final int? chapter;
  final int requiresPerfect;
  final int goldReward;

  final int total;
  int count = 0;
  QUEST_STATUS status = QUEST_STATUS.ONGOING;

  Quest({this.chapter, required this.requiresPerfect, required this.goldReward, required this.total});

  Quest.fromMap(Map<String, dynamic> map):
        id = map[_columnId],
        chapter = map[_columnChapter] as int,
        requiresPerfect = map[_columnIsPerfect] as int,
        goldReward = map[_columnGoldReward] as int,
        count = map[_columnCount] as int,
        total = map[_columnTotal] as int,
        status = QUEST_STATUS_MAP.fromString(map[_columnStatus])!;

  Map<String, Object?> toMap();

  @protected
  void claim() {
    if(status != QUEST_STATUS.CLAIMED && count >= total) {
      SQLRepo.userPoints.addGold(goldReward);
      status = QUEST_STATUS.CLAIMED;
      SQLRepo.quests.update(this);
    }
  }
}

class PracticeQuest extends Quest {
  final String game;
  GAME_MODE? mode;

  PracticeQuest({required this.game, required this.mode, required int chapter, required int requiresPerfect, required int total, required int goldReward}) :
        super(chapter: chapter, requiresPerfect: requiresPerfect, total: total, goldReward: goldReward);

  PracticeQuest.fromMap(Map<String, dynamic> map):
    game = map[_columnGame] as String,
    super.fromMap(map)
  {
    var modeDb = map[_columnMode];
    if(modeDb != null){
      mode = GAME_MODE_MAP.fromString(modeDb)!;
    }
  }

  @override
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
    SQLRepo.quests.update(this);
    return true;
  }

  void claim() {
    if(status != QUEST_STATUS.CLAIMED && count >= total) {
      SQLRepo.userPoints.addGold(goldReward);
      status = QUEST_STATUS.CLAIMED;
      SQLRepo.quests.update(this);
    }
  }
}

class QuizQuest extends Quest{
  final String game = "Quiz";
  QuizQuest({required int chapter, required int requiresPerfect, required int total, required int goldReward}):
        super(chapter: chapter, goldReward: goldReward, requiresPerfect: requiresPerfect, total: total);

  QuizQuest.fromMap(Map<String, dynamic> map): super.fromMap(map);

  @override
  Map<String, Object?> toMap() {
    return <String, Object?> {
      _columnGame: game,
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
    SQLRepo.quests.update(this);
    return true;
  }
}