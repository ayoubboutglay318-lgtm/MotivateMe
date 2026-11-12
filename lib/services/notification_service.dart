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
  static const _keyHour = 'notif_hour';
  static const _keyMinute = 'notif_minute';
  static const _keyEnabled = 'notif_enabled';
  static const _keyInterval = 'notif_interval_hours'; // hours between notifications
  static const _keyLastScheduled = 'notif_last_scheduled';
  static const _maxQuoteId = 49;
  static const _streakReminderId = 900;

  static const _quotes = [
    'Push yourself — no one else will do it for you.',
    'Great things never come from comfort zones.',
    'Dream it. Wish it. Do it.',
    'The harder you work, the greater you\'ll feel when you achieve it.',
    'Success doesn\'t find you. Go out and get it.',
    'Don\'t stop when you\'re tired. Stop when you\'re done.',
    'Wake up with determination. Go to bed with satisfaction.',
    'Do something today that your future self will thank you for.',
    'Little things make big days.',
    'It\'s going to be hard, but hard is not impossible.',
    'Don\'t wish for it. Work for it.',
    'The key to success is to focus on goals, not obstacles.',
    'Believe you can and you\'re halfway there.',
    'Every day is a chance to get better.',
    'Your limitation — it\'s only your imagination.',
    'Sometimes later becomes never. Do it now.',
    'Hustle in silence. Let success make the noise.',
    'Great things take time. Stay patient and stay positive.',
    'You didn\'t come this far only to come this far.',
    'Be stronger than your excuses.',
    'The secret of getting ahead is getting started.',
    'You are capable of more than you know.',
    'Strive for progress, not perfection.',
    'Make it happen. Shock everyone.',
    'One day or day one — you decide.',
    'You got this. Keep going.',
    'Your only limit is your mind.',
    'Act as if what you do makes a difference. It does.',
    'You are braver than you believe and stronger than you seem.',
    'The road to success is always under construction.',
    'Be the energy you want to attract.',
    'Stop doubting yourself. Work hard and make it happen.',
    'You don\'t get what you wish for. You get what you work for.',
    'Discipline is doing what needs to be done even when you don\'t want to.',
    'Small steps every day lead to big results.',
    'Champions keep going when they don\'t want to.',
    'Your mind is a powerful thing. Fill it with positive thoughts.',
    'Difficult roads often lead to beautiful destinations.',
    'The best time to start was yesterday. The next best time is now.',
    'Success is the sum of small efforts repeated day in and day out.',
  ];

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

    // Auto-reschedule if last schedule was 5+ days ago
    final prefs = await SharedPreferences.getInstance();
    final lastScheduled = prefs.getString(_keyLastScheduled);
    final enabled = prefs.getBool(_keyEnabled) ?? true;
    if (enabled && lastScheduled != null) {
      final last = DateTime.tryParse(lastScheduled);
      if (last != null && DateTime.now().difference(last).inDays >= 5) {
        final time = await getSavedTime();
        final interval = await getIntervalHours();
        await schedule(time, enabled: true, intervalHours: interval);
      }
    }
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

  Future<int> getIntervalHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyInterval) ?? 2;
  }

  Future<void> schedule(TimeOfDay startTime, {bool enabled = true, int? intervalHours}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHour, startTime.hour);
    await prefs.setInt(_keyMinute, startTime.minute);
    await prefs.setBool(_keyEnabled, enabled);

    final interval = intervalHours ?? (prefs.getInt(_keyInterval) ?? 2);
    await prefs.setInt(_keyInterval, interval);

    // Only clear the quote notifications; the streak reminder has its own id.
    for (var id = 1; id <= _maxQuoteId; id++) {
      await _plugin.cancel(id);
    }
    if (!enabled) {
      await _plugin.cancel(_streakReminderId);
      return;
    }

    final localNow = DateTime.now();
    final dayOfYear = localNow.difference(DateTime(localNow.year)).inDays;

    // Build notification times for one day (start → 10pm, every intervalHours)
    final times = <TimeOfDay>[];
    int currentMins = startTime.hour * 60 + startTime.minute;
    const endMins = 22 * 60; // 10pm
    while (currentMins <= endMins) {
      times.add(TimeOfDay(hour: currentMins ~/ 60, minute: currentMins % 60));
      currentMins += interval * 60;
    }

    // Schedule next 7 days
    int notifId = 1;
    int quoteOffset = 0;
    for (int day = 0; day < 7; day++) {
      for (final tod in times) {
        final localTarget = DateTime(
          localNow.year, localNow.month, localNow.day + day,
          tod.hour, tod.minute,
        );
        if (!localTarget.isAfter(localNow)) continue;

        // Convert local DateTime to TZDateTime correctly via UTC epoch
        final scheduled = tz.TZDateTime.from(localTarget, tz.UTC);
        final quote = _quotes[(dayOfYear + quoteOffset) % _quotes.length];
        quoteOffset++;

        await _plugin.zonedSchedule(
          notifId++,
          '💪 Daily Motivation',
          quote,
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
        );

        if (notifId > _maxQuoteId) break; // iOS keeps at most 64 pending
      }
      if (notifId > _maxQuoteId) break;
    }

    await prefs.setString(_keyLastScheduled, localNow.toIso8601String());
    await scheduleStreakReminder(prefs.getInt('streak_count') ?? 1);
  }

  /// Warns at 8 PM tomorrow that the streak is about to break.
  ///
  /// Called every time the app opens: opening the app moves the reminder to
  /// the following evening, so it only ever fires on a day the user hasn't
  /// opened the app yet.
  Future<void> scheduleStreakReminder(int streak) async {
    await _plugin.cancel(_streakReminderId);
    if (!await isEnabled()) return;

    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day + 1, 20);
    final title = streak >= 2
        ? '🔥 Your $streak-day streak ends tonight'
        : '🔥 Keep your streak alive';
    const body = 'Open Motivate Me for today\'s quote. It takes 5 seconds.';

    await _plugin.zonedSchedule(
      _streakReminderId,
      title,
      body,
      tz.TZDateTime.from(target, tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivate_streak',
          'Streak reminders',
          channelDescription: 'A reminder before your streak breaks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel() async {
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, false);
  }
}
