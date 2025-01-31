// notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? fcmToken;

  Future<void> initialize() async {
    await requestPermissions();
    await initializeNotifications();
    await getFCMToken();
  }

  Future<void> requestPermissions() async {
    await Permission.notification.request();
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> getFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotifications(
      List<Map<String, dynamic>> notificationSchedule) async {
    if (notificationSchedule.isEmpty) {
      return;
    }

    await Workmanager().cancelAll();

    for (int i = 0; i < notificationSchedule.length; i++) {
      final schedule = notificationSchedule[i];
      final TimeOfDay notificationTime = schedule['time'];

      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final initialDelay = scheduledTime.difference(now);

      await Workmanager().registerPeriodicTask(
        'daily_notification_$i',
        'dailyNotification',
        frequency: const Duration(days: 1),
        initialDelay: initialDelay,
        inputData: {
          'id': i,
          'title': schedule['title'],
          'body':
              'Your daily notification at ${notificationTime.hour}:${notificationTime.minute}',
        },
        constraints: Constraints(
          networkType: NetworkType.not_required,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final scheduleJson = prefs.getString('notification_schedule');
    if (scheduleJson != null) {
      final List<dynamic> decoded = json.decode(scheduleJson);
      return decoded
          .map((item) => {
                'time': TimeOfDay(
                  hour: item['hour'] as int,
                  minute: item['minute'] as int,
                ),
                'title': item['title'] as String,
              })
          .toList();
    }
    return [];
  }

  Future<void> saveSchedule(
      List<Map<String, dynamic>> notificationSchedule) async {
    final prefs = await SharedPreferences.getInstance();
    final scheduleJson = json.encode(
      notificationSchedule
          .map((item) => {
                'hour': item['time'].hour,
                'minute': item['time'].minute,
                'title': item['title'],
              })
          .toList(),
    );
    await prefs.setString('notification_schedule', scheduleJson);
  }
}
