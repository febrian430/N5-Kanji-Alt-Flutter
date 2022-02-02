import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/jumble/game.dart';
import 'package:kanji_memory_hint/mix-match/game.dart';
import 'package:kanji_memory_hint/pick-drop/game.dart';
import 'package:kanji_memory_hint/scoring/report.dart';
import 'package:kanji_memory_hint/map_indexed.dart';
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
const _enumMastery = "mastery";

Iterable<PracticeQuest> _practiceQuestReducer(Iterable<PracticeQuest> sum, Iterable<PracticeQuest> value) {
  return [...sum, ...value];
}

class QuestProvider {
  final Database db;

  QuestProvider(this.db);

  static Future migrate(Database db) async {
    log("CREATING PRACTICE QUEST TABLE");
    await db.execute('''
    create table $_tableQuests ( 
      $_columnId integer primary key,
      $_columnGame text null,
      $_columnMode text check($_columnMode IN ('${GAME_MODE.imageMeaning.name}', '${GAME_MODE.reading.name}', null)),
      $_columnChapter int,
      $_columnIsPerfect int default 0,
      $_columnGoldReward int not null,
      $_columnCount int not null,
      $_columnTotal int not null,
      $_columnStatus text check($_columnStatus IN ('${QUEST_STATUS.CLAIMED.name}', '${QUEST_STATUS.ONGOING.name}', '${QUEST_STATUS.COMPLETE.name}')) default '${QUEST_STATUS.ONGOING.name}',
      $_columnType text check($_columnType IN ('$_enumQuiz','$_enumPractice', '$_enumMastery')) not null
    )
    ''');
  }

  List<MasteryQuest> _getMasterySeed() {
      List<int> counts = [1];
      for(int i = 5; i < 85; i+= 5) {
        counts.add(i);
      }
      counts.add(84);
      print("mastery quests total reward ${counts.length * 5}");
      return counts.map((count) => MasteryQuest(goldReward: 10, total: count)).toList();
  }

  List<PracticeQuest> _getPracticeSeed() {

    const games = [MixMatchGame.name, JumbleGame.name, PickDrop.name];

    const noPerfectTotals = [1, 10, 20];
    const noPerfectRewards = [1,10, 10];

    const totals = [1,3,5];
    const reward = [5,10,10];
    const modes = [GAME_MODE.imageMeaning, GAME_MODE.reading];
    const chapters = USE_CHAPTERS;

    int totalRewardPractice = 0;

    final noPerfectQuests = noPerfectTotals.mapIndexed((total, index){
      return games.map((game) {

        totalRewardPractice += noPerfectRewards[index];
        
        return PracticeQuest(
          game: game, 
          mode: null, 
          requiresPerfect: 0, 
          total: total, 
          goldReward: noPerfectRewards[index]
        );
      });
    }).reduce(_practiceQuestReducer).toList();

    final quests = chapters.map((chapter) {
      return totals.mapIndexed((total, index) {
        return games.map((game) {
          totalRewardPractice += noPerfectRewards[index];

          if(game == PickDrop.name) {
            return [
              PracticeQuest(
                game: game, 
                mode: GAME_MODE.imageMeaning, 
                requiresPerfect: 1, 
                total: total, 
                goldReward: reward[index]
              )
            ];
          } else {
            return modes.map((mode) {
              return PracticeQuest(
                game: game, 
                mode: mode, 
                requiresPerfect: 1, 
                total: total, 
                goldReward: reward[index]
              );
            });
          }
        }).reduce(_practiceQuestReducer);
      }).reduce(_practiceQuestReducer);
    }).reduce(_practiceQuestReducer).toList();

    print("Total reward practice $totalRewardPractice");

    return [
      ...noPerfectQuests,
      ...quests
    ];
  }

  List<QuizQuest> _getQuizSeed(){

    const totals = [1,3,5];
    const rewards = [10, 20, 20];
    const chapters = USE_CHAPTERS;

    int totalReward = 0;

    var quests = chapters.map((chapter) {
      return totals.mapIndexed((total, index) {
        totalReward += rewards[index];
        
        return QuizQuest(
          chapter: chapter, 
          requiresPerfect: 1, 
          total: total, 
          goldReward: rewards[index]
        );
      });
    }).reduce((sum, value) => [...sum, ...value]).toList();

    print("quiz total reward $totalReward");

    return quests;
  }

  Future seed() async {
    var masteryQuests = _getMasterySeed();
    var practiceQuests = _getPracticeSeed();
    var quizQuests = _getQuizSeed();
    List<Quest> quests = [
      ...practiceQuests,
      ...quizQuests,
      ...masteryQuests
    ];

    for (var element in quests) {
      await SQLRepo.quests.create(element);
    }
    log("SEEDED QUESTS");
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

  String _orderByStatus() {
    return '''
      case $_columnStatus
        when '${QUEST_STATUS.COMPLETE.name}' then 3
        when '${QUEST_STATUS.ONGOING.name}' then 2
        when '${QUEST_STATUS.CLAIMED.name}' then 1
      end DESC
      ''';
  }

  Future<List<PracticeQuest>> getOnGoingPractice() async {
    var rows = await db.query(_tableQuests,
      where: '$_columnType = ?',
      whereArgs: [_enumPractice],
      orderBy: _orderByStatus()
    );
    
    
    return rows.map((questRaw) => PracticeQuest.fromMap(questRaw)).toList();
  }

  

  Future<List<QuizQuest>> getOnGoingQuiz() async {
    var rows = await db.query(_tableQuests,
        where: '$_columnType = ?',
        whereArgs: [_enumQuiz],
        orderBy: _orderByStatus()
    );
  

    return rows.map((questRaw) => QuizQuest.fromMap(questRaw)).toList();
  }

  Future<List<MasteryQuest>> getOnGoingMasteryQuests() async {
    await updateAndSyncForMastery();
    var rows = await db.query(_tableQuests,
      where: '$_columnType = ?',
      whereArgs: [_enumMastery],
      orderBy: _orderByStatus()
    );

    return rows.map((questRaw) => MasteryQuest.fromMap(questRaw)).toList();
  }

  Future<int> updateAndSyncForMastery() async {
    var raw = await db.rawQuery('''
      select count(*) as kanji_mastered
        from ( select kanji_id 
        from masteries 
        group by kanji_id
        having count(kanji_id) >= 5)
    ''');
    int str = raw[0]["kanji_mastered"] as int;
    int count = str;

    await db.rawUpdate('''
      update $_tableQuests
      set count = $count
      where $_columnType = '$_enumMastery'
    ''');
    return count;
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
  final int goldReward;

  final int total;
  int count = 0;
  QUEST_STATUS status = QUEST_STATUS.ONGOING;

  Quest({required this.goldReward, required this.total});

  Quest.fromMap(Map<String, dynamic> map):
        id = map[_columnId],

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

abstract class GameQuest extends Quest{
  final int? chapter;
  final int requiresPerfect;

  GameQuest({this.chapter, this.requiresPerfect = 0, required int total, required int goldReward}) :
        super(total: total, goldReward: goldReward);

  GameQuest.fromMap(Map<String, Object?> map):
    chapter = map[_columnChapter] as int?,
    requiresPerfect = map[_columnIsPerfect] as int,
    super.fromMap(map);
}

class MasteryQuest extends Quest {
  MasteryQuest({required int goldReward, required int total}) : super(goldReward: goldReward, total: total);

  MasteryQuest.fromMap(Map<String, dynamic> map): super.fromMap(map);

  @override
  Map<String, Object?> toMap() {
    return <String, Object?> {
      _columnGoldReward: goldReward,
      _columnTotal: total,
      _columnStatus: status.name,
      _columnCount: count,
      _columnType: _enumMastery,
    };
  }

  String toString() {
    return "Get $total Kanjis right in Quiz five times";
  }
}

class PracticeQuest extends GameQuest {
  final String game;
  GAME_MODE? mode;


  PracticeQuest({required this.game, required this.mode, int? chapter, required int requiresPerfect, required int total, required int goldReward}) :
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
      _columnGoldReward: goldReward, 
      _columnIsPerfect: requiresPerfect,
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

    if(requiresPerfect == 1 && report.result.wrongAttempts == 0) {
      return false;
    }

    count++;
    if(count >= total) {
      status = QUEST_STATUS.COMPLETE;
    }
    SQLRepo.quests.update(this);
    return true;
  }

  String toString() {
    String str = "Play $game";

    if(chapter != null) {
      str += " topic $chapter";
    }

    if(mode != null){
      if(mode == GAME_MODE.imageMeaning) {
        str += " with Image Meaning mode";
      } else {
        str += " with Reading mode";
      }
    }

    if(requiresPerfect == 1) {
       str += " perfectly";
    }

    str += " $total times";

    
    return str;
  }

  void claim() {
    if(status != QUEST_STATUS.CLAIMED && count >= total) {
      SQLRepo.userPoints.addGold(goldReward);
      status = QUEST_STATUS.CLAIMED;
      SQLRepo.quests.update(this);
    }
  }
}

class QuizQuest extends GameQuest{
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

    if(requiresPerfect == 1 && (report.multiple.miss != 0 || report.jumble.miss != 0)) {
      return false;
    }

    count++;
    if(count == total) {
      status = QUEST_STATUS.COMPLETE;
    }
    SQLRepo.quests.update(this);
    return true;
  }

  String toString() {
    String str = "Play Quiz";
    if(chapter != null) {
      str += " topic $chapter";
    }

    if(requiresPerfect == 1) {
      str += " perfectly";
    }

    str += " $total times";

    
    return str;
  }
}