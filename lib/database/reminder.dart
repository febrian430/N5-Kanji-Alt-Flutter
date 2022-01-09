import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';

const _tableReminder = "reminder";
const _columnDays = "days";
const _columnTime = "time";

class ReminderProvider {
  final Database db;

  ReminderProvider(this.db);

  static Future migrate(Database db) async {
    log("CREATING REMINDER NOTIFICATION TABLE");
    await db.execute('''
      create table $_tableReminder(
        $_columnDays text not null,
        $_columnTime text not null
      )
    ''');
  }

  Future updateReminder(Reminder reminder) async {
    await db.delete(_tableReminder);
    return await db.insert(_tableReminder, reminder.toMap());
  }

  Future<Reminder?> getReminder() async {
    var raw = await db.query(_tableReminder);
    if(raw.isEmpty) {
      return null;
    }
    return Reminder.fromMap(raw[0]);
  }
}

class Reminder {
  late Set<int> days;
  late TimeOfDay time;

  Reminder(this.days, this.time);

  Reminder.fromMap(Map<String, Object?> map):
    days = (map[_columnDays] as String).split(',').map((day) => int.parse(day)).toSet()
  {
    var splittedTime = (map[_columnTime] as String).split(',').map((component) => int.parse(component)).toList();
    time = TimeOfDay(hour: splittedTime[0], minute: splittedTime[1]);
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      _columnDays: days.join(','),
      _columnTime: '${time.hour.toString()},${time.minute.toString()}'
    };
  }
}