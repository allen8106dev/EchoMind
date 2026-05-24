import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin
  notifications =
  FlutterLocalNotificationsPlugin();

  static Future init() async {

    const AndroidInitializationSettings
    androidSettings =
    AndroidInitializationSettings(
        '@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future showPersistentNotification() async {

    const AndroidNotificationDetails
    androidDetails =
    AndroidNotificationDetails(
      'echo_channel',
      'EchoMind Service',

      channelDescription:
      'Persistent diary notification',

      importance: Importance.low,
      priority: Priority.low,

      ongoing: true,
      autoCancel: false,

      colorized: true,

      color: Color(0xFF2563EB),
    );

    const NotificationDetails details =
    NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      0,

      '🧠 EchoMind',

      'Capture your thoughts instantly',

      details,

      payload: 'quick_add',
    );
  }
}