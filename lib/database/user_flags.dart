import 'dart:developer';

import 'package:sqflite/sqflite.dart';

const _tableUserFlags = "user_flags";
const _columnMixMatch = "has_played_mixmatch";
const _columnJumble = "has_played_jumble";
const _columnPickDrop = "has_played_pickdrop";
const _columnMute = "is_muted";

class UserFlagsProvider {
  UserFlagsProvider(this.db);

  final Database db;

  static Future migrate(Database db) async {
    log("CREATING USER FLAGS TABLE");
    await db.execute('''
    create table $_tableUserFlags ( 
      $_columnMixMatch int not null default false,
      $_columnJumble int not null default false,
      $_columnPickDrop int not null default false,
      $_columnMute int not null default false
    )
    ''');
    
    var flags = {
      _columnMixMatch: false,
      _columnJumble: false,
      _columnPickDrop: false,
      _columnMute: false
    };
    await db.insert(_tableUserFlags, flags);
  }

  Future<UserFlags> get() async {
    var rows = await db.query(_tableUserFlags);
    return UserFlags.fromMap(rows.first);
  }

  Future _set(String column, bool value) async {
    await db.execute('''
      UPDATE $_tableUserFlags
      SET $column = ${value ? 1 : 0}
    ''');
  }

  Future setMixMatchTrue() async {
    await _set(_columnMixMatch, true);
  }

  Future setJumbleTrue() async {
    await _set(_columnJumble, true);
  }

  Future setPickdropTrue() async {
    await _set(_columnPickDrop, true);
  }

  Future setMute(bool mute) async {
    await _set(_columnMute, mute);
  }
}

class UserFlags {
  bool mixmatch;
  bool jumble;
  bool pickdrop;
  bool muted;

  UserFlags({required this.mixmatch, required this.jumble, required this.pickdrop, required this.muted});

  UserFlags.fromMap(Map<String, dynamic> map) :
    mixmatch = map[_columnMixMatch] as int == 1,
    jumble = map[_columnJumble] as int == 1,
    pickdrop = (map[_columnPickDrop] as int) == 1,
    muted = map[_columnMute] as int == 1;

  Map<String, Object?> toMap() {
    return {
      _columnMixMatch: mixmatch,
      _columnJumble: jumble,
      _columnPickDrop: pickdrop,
      _columnMute: muted
    };
  }

}