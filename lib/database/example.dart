import 'dart:developer';

import 'package:kanji_memory_hint/const.dart';
import 'package:kanji_memory_hint/database/example_json.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:sqflite/sqflite.dart';

const _tableKanji = "kanjis";

const _tableExample = "examples";
const _columnId = "id";
const _columnRune = "rune";
const _columnMeaning = "meaning";
const _columnSpelling = "spelling";
const _columnChapter = "chapter";
const _columnImage = "image";
const _columnIsSingle = "is_single";
const _columnExampleOf = "example_of";
const _columnKanjiChapters = "chapters";
const _columnCost = "cost";
const _columnRewardStatus = "reward_status";

const _tableKanjiExample = "kanji_examples";
const _columnKanjiId = "kanji_id";
const _columnExampleId = "example_id";

class ExampleProvider {
  final Database db;

  List<Example> _examples = [];

  ExampleProvider(this.db);

  static Future migrate(Database db) async {
    log("CREATING EXAMPLE TABLE");
    // $_columnChapter int not null,
    await db.execute('''
      create table $_tableExample ( 
        $_columnId integer primary key,
        $_columnRune text not null,
        
        $_columnMeaning text not null,
        $_columnSpelling text not null,
        $_columnImage text not null,
        $_columnIsSingle int not null,
        $_columnCost int not null,
        $_columnRewardStatus text check($_columnRewardStatus IN ('${REWARD_STATUS.AVAILABLE.name}', '${REWARD_STATUS.CLAIMED.name}')) default '${REWARD_STATUS.AVAILABLE.name}'
      )
    ''');

    log("CREATING KANJI EXAMPLE TABLE");
    await db.execute('''
      create table $_tableKanjiExample ( 
        $_columnKanjiId int references $_tableKanji($_columnKanjiId),
        $_columnExampleId int references $_tableExample($_columnId),
        primary key($_columnKanjiId, $_columnExampleId)
      )
    ''');
  }

  Future<void> _read({bool forceRefresh = false}) async {
    if(_examples.isEmpty || forceRefresh) {
      var rows = await db.rawQuery(''' 
        select e.*, group_concat(ke.$_columnKanjiId, '#') as $_columnExampleOf from $_tableExample e
        join $_tableKanjiExample ke on e.$_columnId = ke.$_columnExampleId
        group by e.$_columnId
      ''');

      _examples = Example.fromRows(rows);
    }
  }

  Future<void> _readFromJoinTable({bool forceRefresh = false}) async {
    if(_examples.isEmpty || forceRefresh) {
      var rows = await db.rawQuery(''' 
        select e.*, 
          group_concat(ke.$_columnKanjiId, '#') as $_columnExampleOf,
          group_concat(k.$_columnChapter, '#') as $_columnKanjiChapters
        from $_tableExample e
        join $_tableKanjiExample ke on e.$_columnId = ke.$_columnExampleId
        join $_tableKanji k on k.$_columnId = ke.$_columnKanjiId
        group by e.$_columnId
      ''');

      _examples = Example.fromRows(rows);
    }
  }

  Future<int> create(Example example, List<int> kanjiIds) async {
    int id = await db.insert(_tableExample, example.toMap());

    for(var kanjiId in kanjiIds) {
      await db.insert(_tableKanjiExample, {
        _columnKanjiId: kanjiId,
        _columnExampleId: id
      });
    }
    return id;
  }

  Future<void> seed() async {
    log("SEEDING KANJI EXAMPLE");
    var examples = await kanjiExamples();

    for (var example in examples) {
      await create(example, example.exampleOf);
    }
  }

  Future<List<Example>> all() async {
    await _readFromJoinTable();
    // var rows = await db.query(_tableExample);

    return _examples;
  }

  Future claimReward(Example example) async {
    await db.transaction((txn) async {
      example.rewardStatus = REWARD_STATUS.CLAIMED;
      await txn.update(_tableExample, example.toMap(),
        where: '$_columnId = ?',
        whereArgs: [example.id]
      );

      await txn.rawQuery('''
        update user_points
        set gold = gold - ${example.cost}
      '''
      );

    });
  }

  Future<List<Example>> examplesOf(int kanjiId) async {
    var rows = await db.rawQuery('''
      select e.*,
      group_concat(k.$_columnChapter, '#') as $_columnKanjiChapters
      from examples e join kanji_examples ke on e.id = ke.example_id
      join $_tableKanji k on k.$_columnId = ke.$_columnKanjiId
      where ke.kanji_id = ? 
      group by e.id
      ''',
      [kanjiId]
    );
    return Example.fromRows(rows);
  }

  Future<List<Example>> byChapter(int chapter, {bool? single, bool? hasImage}) async {
    await _readFromJoinTable();
    return _examples.where((example) {
      if(single != null && example.isSingle != single) {
        return false;
      }

      if(hasImage != null && example.hasImage != hasImage) {
        return false;
      } 
      print(example.chapters);
      return example.chapters.contains(chapter);
    }).toList();
  }
}

class Example {
  int? id;
  String rune;
  String meaning;
  String image;
  late List<String> spelling;
  late bool isSingle;
  List<int> chapters;
  int cost;
  REWARD_STATUS rewardStatus;

  bool hasImage;
  List<int> exampleOf = [];

  static List<Example> fromRows(List<Map<String, dynamic>> rows){
    return rows.map((row) => Example.fromMap(row)).toList();
  }

  Example.fromMap(Map<String, dynamic> map):
      id = map[_columnId] as int,
      rune = map[_columnRune] as String,
      meaning = map[_columnMeaning] as String,
      image = map[_columnImage] as String,
      isSingle = (map[_columnIsSingle] as int) == 1,
      chapters = (map[_columnKanjiChapters] as String).split("#").map((e) => int.parse(e)).toList(),
      spelling = map[_columnSpelling].toString().split("#"),
      cost = map[_columnCost] as int,
      rewardStatus = REWARD_STATUS_MAP.fromString(map[_columnRewardStatus])!,

      hasImage = (map[_columnImage] as String).isNotEmpty
  {
    exampleOf = map[_columnExampleOf] != null ? 
        map[_columnExampleOf].toString()
        .split("#")
        .map((e) => int.parse(e)).toList()
        :
        [];
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      // _columnId: id,
      _columnRune: rune,
      _columnMeaning: meaning,
      _columnImage: image,
      // _columnChapter: chapters.join("#"),
      _columnSpelling: spelling.join("#"),
      _columnIsSingle: isSingle ? 1 : 0,
      _columnCost: cost,
      _columnRewardStatus: rewardStatus.name
    };
  }


  Example.fromJson(Map<String, dynamic> json):
        id = json['id'],
        rune = json['rune'],
        meaning = json['meaning'],
        image = json['image'],
        // chapter = json['chapter'] as int,
        chapters = [0],
        hasImage = (json['image'] as String).isNotEmpty,
        cost = json['cost'] as int,
        rewardStatus = REWARD_STATUS_MAP.fromString(json['reward_status'] as String)!
  {
    spelling = (json['spelling'] as List).map((spellDynamic) {
      return spellDynamic.toString();
    }).toList();

    exampleOf = (json['example_of'] as List).map((exampleOfRaw){
      return exampleOfRaw as int;
    }).toList();

    if(json['is_single'] != null){
      isSingle = json['is_single'] as bool;
    } else {
      isSingle = false;
    }
  }

  Future claim() async {
    return SQLRepo.examples.claimReward(this);
  }
}