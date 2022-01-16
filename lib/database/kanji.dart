import 'dart:async';
import 'dart:developer';

import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/repository/kanji_list.dart';
import 'package:sqflite/sqflite.dart';

const _tableKanjis = "kanjis";
const _columnId = "id";
const _columnRune = "rune";
const _columnChapter = "chapter";
const _columnOnyomi = "onyomi";
const _columnKunyomi = "kunyomi";
const _columnMastery = "mastery";
const _columnStrokeOrder = "stroke_order";

const _tableMastery = "masteries";
const _columnKanjiId = "kanji_id";


class Kanji {
  int? id;
  String rune;
  int chapter;
  int mastery;
  String onyomi;
  String kunyomi;
  String strokeOrder;
  // List<String> onyomi = [];
  // List<String> kunyomi = [];
  List<Example> examples = [];

  Kanji.fromMap(Map<String, dynamic> map) :
      id = map[_columnId] as int,
      rune = map[_columnRune] as String,
      chapter = map[_columnChapter] as int,
      mastery = map[_columnMastery] as int,
      onyomi = map[_columnOnyomi] as String,
      kunyomi = map[_columnKunyomi] as String,
      strokeOrder = map[_columnStrokeOrder] as String;
  
    // var onyomiDb = map[_columnOnyomi] as String;
    // var kunyomiDb = map[_columnKunyomi] as String;

    
    // onyomi = onyomiDb.split('/');
    // kunyomi = kunyomiDb.split('/');
  

  Map<String, Object?> toMap() {
    return <String, Object?> {
      _columnId: id,
      _columnRune: rune,
      _columnChapter: chapter,
      _columnOnyomi: onyomi,
      _columnKunyomi: kunyomi,
      _columnStrokeOrder: strokeOrder
      // _columnOnyomi: onyomi.join("/"),
      // _columnKunyomi: kunyomi.join("/"),
    };
  }

  Kanji.fromJson(Map<String, dynamic> json)
      :
        // id = json['id'],
        rune = json['rune'],
        chapter = json['chapter'],
        kunyomi = json['kunyomi'],
        onyomi = json['onyomi'],
        strokeOrder = json['stroke_order'],
        mastery = 0
  {
    // for (var _kunyomi in json['kunyomi'] as String) {
    //   kunyomi.add(_kunyomi as String);
    // }
    // for (var _onyomi in json['onyomi'] as List) {
    //   onyomi.add(_onyomi as String);
    // }
  }

  static List<Kanji> fromRows(List<Map<String, dynamic>> rows) {
    return rows.map((row) => Kanji.fromMap(row)).toList();
  }

  Future populate() async {
    examples = await SQLRepo.examples.examplesOf(id!);
  }
}

class KanjiProvider {
  final Database db;

  List<Kanji> _kanjis = [];

  KanjiProvider(this.db);

  static Future migrate(Database db) async {
    log("CREATING KANJI TABLE");
    await db.execute('''
      create table $_tableKanjis ( 
        $_columnId integer primary key,
        $_columnRune text not null,
        $_columnChapter int not null,
        $_columnKunyomi text not null,
        $_columnOnyomi text not null,
        $_columnStrokeOrder text not null
      )
    ''');

    log("CREATING MASTERY TABLE");
    await db.execute('''
      create table $_tableMastery ( 
        $_columnKanjiId integer,
        foreign key($_columnKanjiId) REFERENCES $_tableKanjis($_columnId)
      )
    ''');
  }

  Future seed() async {
    log("SEEDING KANJI");
    var list = await kanjiList();
    for (var kanji in list) {
      await create(kanji);
    }
    // var testKanji = await getByID(1);
    // addMastery(testKanji);
  }

  Future create(Kanji kanji) async {
    return await db.insert(_tableKanjis, kanji.toMap());
  }

  Future<List<Kanji>> byChapter(int chapter) async {
    await _read();

    return _kanjis.where((kanji) => kanji.chapter == chapter).toList();
  }

  FutureOr<void> _read({bool forceRefresh = false}) async {
    if(_kanjis.isEmpty || forceRefresh) {
      var rows = await db.rawQuery(
          '''SELECT $_columnId, $_columnRune, $_columnChapter, $_columnKunyomi, $_columnOnyomi, $_columnStrokeOrder,
          COUNT($_tableMastery.$_columnKanjiId) as $_columnMastery
          from $_tableKanjis left join $_tableMastery on $_tableKanjis.$_columnId = $_tableMastery.$_columnKanjiId
          group by $_tableKanjis.$_columnId
          order by $_columnId
      ''');

      _kanjis = Kanji.fromRows(rows);
      for (var kanji in _kanjis) { 
        await kanji.populate();
      }
    }
  }

  Future<List<Kanji>> all() async {
    await _read(forceRefresh: true);

    return _kanjis;
  }

  Future<Kanji> getByID(int kanjiID) async {
    await _read();

    return _kanjis.where((kanji) => kanji.id == kanjiID).single;
  }

  Future addMastery(int kanjiId) async {
    return await db.insert(_tableMastery, <String, Object?>{
      _columnKanjiId: kanjiId
    });
  }
}