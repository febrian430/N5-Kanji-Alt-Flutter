import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kanji_memory_hint/database/reminder.dart';
import 'package:kanji_memory_hint/database/repository.dart';
import 'package:kanji_memory_hint/main.dart';
import 'package:kanji_memory_hint/menu_screens/start_select.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifier {
  static late FlutterLocalNotificationsPlugin _notificationPlugin;
  static late final AndroidNotificationDetails _androidNotificationDetail;



  static tz.TZDateTime _setDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);

    return scheduledDate.isBefore(now) ? 
          scheduledDate.add(const Duration(days: 1)) : scheduledDate;
  }

  static tz.TZDateTime _getScheduleTest({required Time time, required List<int> days}) {
    var sch = _setDaily(time);

    while(!days.contains(sch.weekday)){
      sch = sch.add(const Duration(days: 1));
    }
    return sch;
  }

  static Future initialize() async {
    tz.initializeTimeZones();
    final jakarta = tz.getLocation('Asia/Jakarta');
    tz.setLocalLocation(jakarta);

    _notificationPlugin = FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('app_icon');
    
    const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
    );

    _androidNotificationDetail = const AndroidNotificationDetails(
          "reminder_notification", 
          "Reminder",
          channelDescription: "Shows you notification as a reminder at specified day and time you specified",
          importance: Importance.high,
    );

    _notificationPlugin.initialize(initSettings,
      onSelectNotification: (String? payload) {
        MaterialPageRoute(
          builder: (context) {
            return StartSelect();
          });
      }
    );
  }

  static Future createNotifier(TimeOfDay time, Set<int> days) async {
    _notificationPlugin.cancelAll();

    var reminder = Reminder(days.toSet(), TimeOfDay(hour: time.hour, minute: time.minute));
    SQLRepo.reminder.updateReminder(reminder);

    _notificationPlugin.zonedSchedule(
      0,
      'Kantan Kanji',
      "It's time to study",
      _getScheduleTest(
        time: Time(time.hour, time.minute), 
        days: [...days]
      ),
      NotificationDetails(
          android: _androidNotificationDetail
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime
    );
  }

  static Future<Reminder?> current() async {
    return await SQLRepo.reminder.getReminder();
  }
  
}