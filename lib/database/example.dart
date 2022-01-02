import 'dart:developer';

import 'package:kanji_memory_hint/database/example_json.dart';
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

const _tableKanjiExample = "kanji_examples";
const _columnKanjiId = "kanji_id";
const _columnExampleId = "example_id";

class ExampleProvider {
  final Database db;

  List<Example> _examples = [];

  ExampleProvider(this.db);

  static Future migrate(Database db) async {
    log("CREATING EXAMPLE TABLE");
    await db.execute('''
      create table $_tableExample ( 
        $_columnId integer primary key,
        $_columnRune text not null,
        $_columnChapter int not null,
        $_columnMeaning text not null,
        $_columnSpelling text not null,
        $_columnImage text not null,
        $_columnIsSingle text not null
      )
    ''');

    log("CREATING KANJI EXAMPLE TABLE");
    await db.execute('''
      create table $_tableKanjiExample ( 
        $_columnKanjiId integer references $_tableKanji($_columnKanjiId),
        $_columnExampleId integer references $_tableExample($_columnId),
        primary key($_columnKanjiId, $_columnExampleId)
      )
    ''');
  }

  Future<int> create(Example example, int kanjiId) async {
    int id = await db.insert(_tableExample, example.toMap());
    await db.insert(_tableKanjiExample, {
      _columnKanjiId: kanjiId,
      _columnExampleId: id
    });
    return id;
  }

  Future<void> seed() async {
    log("SEEDING KANJI EXAMPLE");
    var examples = await kanjiExamples();

    for (var example in examples) {
      for (var kanjiId in example.exampleOf) {
        await create(example, kanjiId);
      }
    }
  }
}

class Example {
  int? id;
  String rune;
  String meaning;
  String image;
  late List<String> spelling;
  late bool isSingle;
  int chapter;

  bool hasImage;
  late List<int> exampleOf;

  Example.fromMap(Map<String, dynamic> map):
      id = map[_columnId] as int,
      rune = map[_columnRune] as String,
      meaning = map[_columnMeaning] as String,
      image = map[_columnImage] as String,
      isSingle = (map[_columnIsSingle] as int) == 1,
      chapter = map[_columnChapter] as int,
      spelling = map[_columnSpelling].toString().split("#"),

      hasImage = (map[_columnImage] as String).isNotEmpty
  {
    exampleOf = map[_columnExampleOf].toString()
        .split("#")
        .map((e) => e as int).toList();
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      // _columnId: id,
      _columnRune: rune,
      _columnMeaning: meaning,
      _columnImage: image,
      _columnChapter: chapter,
      _columnSpelling: spelling.join("#"),
      _columnIsSingle: isSingle ? 1 : 0,
    };
  }


  Example.fromJson(Map<String, dynamic> json):
        id = json['id'],
        rune = json['rune'],
        meaning = json['meaning'],
        image = json['image'],
        chapter = json['chapter'] as int,
        hasImage = (json['image'] as String).isNotEmpty
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
}