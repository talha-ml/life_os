// lib/core/utils/notification_helper.dart
import 'dart:typed_data'; // 🚀 NEW: For custom vibration patterns
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      // Initialize TimeZones for accurate scheduling
      tz.initializeTimeZones();

      // Setup for Android
      const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // Setup for iOS
      const iosInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      // 🚀 PREMIUM: Initialize and handle Notification Taps
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification Tapped! Payload: ${response.payload}');
          // Future enhancement: Navigate directly to the task detail screen using this payload
        },
      );

      // 🚀 PREMIUM: Request Android 13+ POST_NOTIFICATIONS & EXACT_ALARM Permissions
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();

    } catch (e) {
      debugPrint("Notification Init Error: $e");
    }
  }

  // Schedule a notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // If time has already passed, don't schedule
      if (scheduledTime.isBefore(DateTime.now())) return;

      // 🚀 PREMIUM: Custom Vibration Pattern (Wait, Vibrate, Wait, Vibrate)
      final Int64List vibrationPattern = Int64List.fromList([0, 500, 200, 500]);

      final androidDetails = AndroidNotificationDetails(
        'lifeos_premium_channel',
        'Mission Alerts',
        channelDescription: 'High priority alerts for your scheduled missions',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        color: const Color(0xFF6C63FF), // App's primary Indigo color
        ledColor: const Color(0xFF6C63FF),
        ledOnMs: 1000,
        ledOffMs: 500,
        vibrationPattern: vibrationPattern,
        styleInformation: const BigTextStyleInformation(''), // Allows long text to expand
      );

      final iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive, // 🚀 PREMIUM: iOS Focus Mode Bypass
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Ensures it rings even in Doze mode
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'task_id_$id', // Passed when notification is tapped
      );
    } catch (e) {
      debugPrint("Notification Schedule Error: $e");
    }
  }

  // Cancel a notification if task is deleted or completed early
  static Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint("Notification Cancel Error: $e");
    }
  }
}