import 'dart:async';
import 'dart:developer';

import 'package:kanji_memory_hint/database/example.dart';
import 'package:kanji_memory_hint/repository/kanji_list.dart';
import 'package:sqflite/sqflite.dart';

const _tableKanjis = "kanjis";
const _columnId = "id";
const _columnRune = "rune";
const _columnChapter = "chapter";
const _columnOnyomi = "onyomi";
const _columnKunyomi = "kunyomi";
const _columnMastery = "mastery";

const _tableMastery = "masteries";
const _columnKanjiId = "kanji_id";


class Kanji {
  int? id;
  String rune;
  int chapter;
  int mastery;
  List<String> onyomi = [];
  List<String> kunyomi = [];
  List<Example> examples = [];

  Kanji.fromMap(Map<String, dynamic> map) :
      id = map[_columnId] as int,
      rune = map[_columnRune] as String,
      chapter = map[_columnChapter] as int,
      mastery = map[_columnMastery] as int
  {
    var onyomiDb = map[_columnOnyomi] as String;
    var kunyomiDb = map[_columnKunyomi] as String;

    onyomi = onyomiDb.split('/');
    kunyomi = kunyomiDb.split('/');
  //  call db to populate example
  }

  Map<String, Object?> toMap() {
    return <String, Object?> {
      _columnId: id,
      _columnRune: rune,
      _columnChapter: chapter,
      _columnOnyomi: onyomi.join("/"),
      _columnKunyomi: kunyomi.join("/"),
    };
  }


  Kanji.fromJson(Map<String, dynamic> json)
      :
        // id = json['id'],
        rune = json['rune'],
        chapter = json['chapter'],
        mastery = 0
  {
    for (var _kunyomi in json['kunyomi'] as List) {
      kunyomi.add(_kunyomi as String);
    }
    for (var _onyomi in json['onyomi'] as List) {
      onyomi.add(_onyomi as String);
    }
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
        $_columnOnyomi text not null
      )
    ''');

    log("CREATING MASTERY TABLE");
    await db.execute('''
      create table $_tableMastery ( 
        $_columnKanjiId integer primary key,
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
    var testKanji = await getByID(1);
    addMastery(testKanji);
  }

  Future create(Kanji kanji) async {
    return await db.insert(_tableKanjis, kanji.toMap());
  }

  FutureOr<void> _read({bool forceRefresh = false}) async {
    if(_kanjis.isEmpty || forceRefresh) {
      var rows = await db.rawQuery(
          '''SELECT $_columnId, $_columnRune, $_columnChapter, $_columnKunyomi, $_columnOnyomi,
          COUNT($_tableMastery.$_columnKanjiId) as $_columnMastery
          from $_tableKanjis left join $_tableMastery on $_tableKanjis.$_columnId = $_tableMastery.$_columnKanjiId
          group by $_tableKanjis.$_columnId
          order by $_columnId
      ''');

      _kanjis = rows.map((rawKanji) {
        return Kanji.fromMap(rawKanji);
      }).toList();
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

  Future addMastery(Kanji kanji) async {
    return await db.insert(_tableMastery, <String, Object?>{
      _columnKanjiId: kanji.id
    });
  }
}