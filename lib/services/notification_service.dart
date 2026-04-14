import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    try {
      if (kIsWeb) return; 

      if (defaultTargetPlatform == TargetPlatform.android) {
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const InitializationSettings initializationSettings =
            InitializationSettings(
          android: initializationSettingsAndroid,
        );

        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        const DarwinInitializationSettings initializationSettingsIOS =
            DarwinInitializationSettings();

        const InitializationSettings initializationSettings =
            InitializationSettings(
          iOS: initializationSettingsIOS,
        );

        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        const LinuxInitializationSettings initializationSettingsLinux =
            LinuxInitializationSettings(defaultActionName: 'Open notification');

        const InitializationSettings initializationSettings =
            InitializationSettings(
          linux: initializationSettingsLinux,
        );

        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings);
      }
    } catch (e) {
      print('Notification service init error: $e');
    }
  }

  Future<void> schedulePrayerNotification(
      int id, String prayerName, DateTime time) async {
    if (time.isBefore(DateTime.now())) return; 

    try {
      if (kIsWeb) return; // Web doesn't support local scheduled notifications this way

      if (defaultTargetPlatform == TargetPlatform.android) {
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
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
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
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
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
    } catch (e) {
      print('Notification scheduling failed: $e');
    }
  }
}
