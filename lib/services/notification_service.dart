import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'motivate_daily';
  static const _notifId = 1;
  static const _keyHour = 'notif_hour';
  static const _keyMinute = 'notif_minute';
  static const _keyEnabled = 'notif_enabled';

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<TimeOfDay> getSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: prefs.getInt(_keyHour) ?? 8,
      minute: prefs.getInt(_keyMinute) ?? 0,
    );
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? true;
  }

  Future<void> schedule(TimeOfDay time, {bool enabled = true}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHour, time.hour);
    await prefs.setInt(_keyMinute, time.minute);
    await prefs.setBool(_keyEnabled, enabled);

    await _plugin.cancel(_notifId);
    if (!enabled) return;

    // Compute next occurrence in local time, convert to UTC for scheduling
    final localNow = DateTime.now();
    final offset = localNow.timeZoneOffset;

    var localTarget = DateTime(
      localNow.year, localNow.month, localNow.day, time.hour, time.minute,
    );
    if (!localTarget.isAfter(localNow)) {
      localTarget = localTarget.add(const Duration(days: 1));
    }
    final utcTarget = localTarget.subtract(offset);
    final scheduled = tz.TZDateTime.from(utcTarget, tz.UTC);

    await _plugin.zonedSchedule(
      _notifId,
      '💪 Daily Motivation',
      'Open the app for your quote of the day!',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily Motivation',
          channelDescription: 'Your daily motivational quote',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel() async {
    await _plugin.cancel(_notifId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, false);
  }
}
