import 'package:daily_planner/main.dart';
import 'package:daily_planner/models/task.dart';
import 'package:daily_planner/navigator_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationController {
  static const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'su.rakkade.daily_planner', // Change this to a unique channel ID
    'Main channel',
    channelDescription: 'Main channel for Daily Planner',
    importance: Importance.max,
    priority: Priority.high,
  );

  static Future<void> scheduleNotification(
      Task task, DateTime scheduledTime) async {
    print(scheduledTime.toString());
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          task.id,
          AppLocalizations.of(NavigatorService.navigatorKey.currentContext!)!
              .taskReminder,
          task.content,
          tz.TZDateTime.local(
              scheduledTime.year,
              scheduledTime.month,
              scheduledTime.day,
              scheduledTime.hour,
              scheduledTime.minute,
              scheduledTime.second),
          const NotificationDetails(android: androidPlatformChannelSpecifics),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } catch (e) {
      if (kDebugMode) {
        print("Notification error: $e");
      }
      return Future(() => null);
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      if (kDebugMode) {
        print("Notification error: $e");
      }
      return Future(() => null);
    }
  }
}
