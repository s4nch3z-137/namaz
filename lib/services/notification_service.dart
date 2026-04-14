import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    try {
      // Only initialize on mobile platforms that support notifications
      if (Platform.isAndroid) {
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const InitializationSettings initializationSettings =
            InitializationSettings(
          android: initializationSettingsAndroid,
        );

        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
      } else if (Platform.isIOS) {
        const DarwinInitializationSettings initializationSettingsIOS =
            DarwinInitializationSettings();

        const InitializationSettings initializationSettings =
            InitializationSettings(
          iOS: initializationSettingsIOS,
        );

        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
      } else if (Platform.isLinux) {
        const LinuxInitializationSettings initializationSettingsLinux =
            LinuxInitializationSettings(defaultActionName: 'Open notification');

        const InitializationSettings initializationSettings =
            InitializationSettings(
          linux: initializationSettingsLinux,
        );

        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
      }
      // Note: Web and Windows don't support real notifications in this version
    } catch (e) {
      print('Notification service init error: $e');
      // Silently fail - app continues without notifications
    }
  }

  Future<void> schedulePrayerNotification(
      int id, String prayerName, DateTime time) async {
    if (time.isBefore(DateTime.now())) return; // Don't schedule in the past

    try {
      if (Platform.isAndroid) {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails('prayer_times_channel', 'Prayer Times',
                channelDescription: 'Notifications for daily Salah times',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker');

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            'Time for $prayerName',
            'It is time to pray $prayerName. Get your golden streak!',
            tz.TZDateTime.from(time, tz.local),
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      } else if (Platform.isIOS) {
        const DarwinNotificationDetails iosPlatformChannelSpecifics =
            DarwinNotificationDetails();

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(iOS: iosPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            'Time for $prayerName',
            'It is time to pray $prayerName. Get your golden streak!',
            tz.TZDateTime.from(time, tz.local),
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      } else if (Platform.isLinux) {
        const LinuxNotificationDetails linuxPlatformChannelSpecifics =
            LinuxNotificationDetails();

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(linux: linuxPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            'Time for $prayerName',
            'It is time to pray $prayerName. Get your golden streak!',
            tz.TZDateTime.from(time, tz.local),
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
      // Web and Windows: notifications not supported, silently skip
    } catch (e) {
      // Silently fail on platforms that don't support notifications
      print('Notification scheduling failed: $e');
    }
  }
}
