// import 'dart:typed_data';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   /// ✅ Initialize Notifications
//   Future<void> init() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     // Initialize Timezone
//     tz.initializeTimeZones();
//     final String timeZoneName = tz.local.name;
//     tz.setLocalLocation(tz.getLocation(timeZoneName));
//   }

//   /// ✅ Schedule Notification (Admins Only)
//   Future<void> scheduleNotification(int id, String title, String body,
//       DateTime scheduledTime, String role) async {
//     if (role != 'admin') {
//       print('Notification skipped: Only admins receive notifications.');
//       return; // Skip notifications for students
//     }

//     // Convert DateTime to TZDateTime
//     final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
//       scheduledTime,
//       tz.local,
//     );

//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'lecture_channel_id',
//       'Lecture Reminders',
//       importance: Importance.max,
//       priority: Priority.high,
//       vibrationPattern:
//           Int64List.fromList([0, 1000, 500, 1000]), // Vibration pattern
//       enableVibration: true,
//       sound: RawResourceAndroidNotificationSound('pikachu'), // Use pikachu.mp3
//     );

//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledTZTime, // Use TZDateTime
//       platformChannelSpecifics,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents:
//           DateTimeComponents.time, // Match time for recurring notifications
//       androidScheduleMode:
//           AndroidScheduleMode.exactAllowWhileIdle, // Add the required parameter
//     );
//     print('Notification scheduled for admin.');
//   }
// }

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ✅ Initialize Notifications
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize Timezone
    tz.initializeTimeZones();
    final String timeZoneName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print('Notification service initialized.');
  }

  /// ✅ Schedule Notification (Admins Only)
  Future<void> scheduleNotification(int id, String title, String body,
      DateTime scheduledTime, String role) async {
    if (role != 'admin') {
      print('❌ Notification skipped: Only admins receive notifications.');
      return; // Skip notifications for students
    }

    // Convert DateTime to TZDateTime
    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'lecture_channel_id',
      'Lecture Reminders',
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern:
          Int64List.fromList([0, 1000, 500, 1000]), // Vibration pattern
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('pikachu'), // Use pikachu.mp3
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZTime, // Use TZDateTime
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // Match time for recurring notifications
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // Add the required parameter
    );
    print('✅ Notification scheduled for admin.');
  }
}

void main() async {
  final NotificationService notificationService = NotificationService();
  await notificationService.init();

  // Simulate console input
  stdout.write('Enter role (admin/student): ');
  String role = stdin.readLineSync()?.toLowerCase() ?? 'student';

  DateTime lectureTime = DateTime.now()
      .add(Duration(seconds: 10)); // 10 seconds later for quick testing

  notificationService.scheduleNotification(
    1,
    'Lecture Reminder',
    'Don\'t forget your lecture at 2 PM!',
    lectureTime,
    role,
  );
}
