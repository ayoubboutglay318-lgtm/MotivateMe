import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakService extends ChangeNotifier {
  static const _keyStreak = 'streak_count';
  static const _keyLastOpen = 'streak_last_open';

  int _streak = 0;
  List<bool> _week = List.filled(7, false);

  int get streak => _streak;
  List<bool> get week => List.unmodifiable(_week);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpen = prefs.getString(_keyLastOpen);
    final today = _dateKey(DateTime.now());
    _streak = prefs.getInt(_keyStreak) ?? 0;

    final weekData = prefs.getStringList('streak_week') ?? [];
    _week = List.filled(7, false);

    if (lastOpen == null) {
      _streak = 1;
      await _save(prefs, today);
    } else if (lastOpen == today) {
      // already opened today, just load
    } else {
      final last = DateTime.parse(lastOpen);
      final diff = DateTime.now().difference(last).inDays;
      if (diff == 1) {
        _streak += 1;
      } else {
        _streak = 1;
        _week = List.filled(7, false);
      }
      await _save(prefs, today);
    }

    // Mark today in week view
    final dayOfWeek = DateTime.now().weekday - 1; // 0=Mon
    _week[dayOfWeek] = true;
    for (final d in weekData) {
      final parsed = DateTime.tryParse(d);
      if (parsed != null) {
        final diff = DateTime.now().difference(parsed).inDays;
        if (diff < 7) {
          final idx = (DateTime.now().weekday - 1 - diff + 7) % 7;
          _week[idx] = true;
        }
      }
    }

    notifyListeners();
  }

  Future<void> _save(SharedPreferences prefs, String today) async {
    await prefs.setInt(_keyStreak, _streak);
    await prefs.setString(_keyLastOpen, today);
    final existing = prefs.getStringList('streak_week') ?? [];
    if (!existing.contains(today)) {
      existing.add(today);
      if (existing.length > 7) existing.removeAt(0);
      await prefs.setStringList('streak_week', existing);
    }
  }

  static String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
