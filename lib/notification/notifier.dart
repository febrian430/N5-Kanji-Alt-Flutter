import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kanji_memory_hint/main.dart';
import 'package:kanji_memory_hint/menu_screens/start_select.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifier {
  static late FlutterLocalNotificationsPlugin _notificationPlugin;
  static late final AndroidNotificationDetails _androidNotificationDetail;

  static tz.TZDateTime _getSchedule({required Time time, required List<int> days}) {
    var day = Time(8);
    DateTime.sunday;
    return tz.TZDateTime.now(tz.local).add(Duration(seconds: 3));
  }

  static tz.TZDateTime _getScheduleTest({required Time time, required List<int> days}) {
    return tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3));
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

  static Future createNotifier() async {
    _notificationPlugin.cancelAll();
    _notificationPlugin.zonedSchedule(
      0,
      'Title',
      'Body',
      _getScheduleTest(time: Time(8), days: [DateTime.sunday, DateTime.monday]),
      NotificationDetails(
          android: _androidNotificationDetail
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime
    );
  }

  static void _onSelectNotification(String? payload) {
    // Navigator.push(context, route)
  }

  
}