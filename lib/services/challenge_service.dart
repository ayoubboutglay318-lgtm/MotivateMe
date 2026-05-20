import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayTask {
  const DayTask({required this.id, required this.label, required this.icon, this.xp = 10});
  final String id;
  final String label;
  final String icon;
  final int xp;
}

const kDailyTasks = [
  DayTask(id: 'wake',    label: 'Wake up before 7 AM',    icon: '🌅', xp: 15),
  DayTask(id: 'workout', label: 'Workout / Exercise',       icon: '💪', xp: 20),
  DayTask(id: 'read',    label: 'Read 10 pages',            icon: '📖', xp: 15),
  DayTask(id: 'noex',    label: 'No excuses today',         icon: '🔥', xp: 10),
];

const int _xpPerDay = 50;

int xpToLevel(int xp) => (xp / 200).floor() + 1;
int xpForNextLevel(int xp) {
  final level = xpToLevel(xp);
  return level * 200 - xp;
}
double xpLevelProgress(int xp) {
  final level = xpToLevel(xp);
  final base = (level - 1) * 200;
  return ((xp - base) / 200).clamp(0.0, 1.0);
}

String levelTitle(int level) {
  if (level >= 10) return 'Legend';
  if (level >= 7)  return 'Elite';
  if (level >= 5)  return 'Warrior';
  if (level >= 3)  return 'Fighter';
  return 'Rookie';
}

class ChallengeService extends ChangeNotifier {
  static final ChallengeService instance = ChallengeService._();
  ChallengeService._();

  int _currentDay = 0;
  List<Set<String>> _completedTasks = List.generate(30, (_) => {});
  String? _startDate;
  int _totalXp = 0;

  int get currentDay => _currentDay;
  bool get isStarted => _currentDay > 0;
  bool get isComplete => _currentDay > 30;
  int get totalXp => _totalXp;
  int get level => xpToLevel(_totalXp);
  double get levelProgress => xpLevelProgress(_totalXp);
  String get levelName => levelTitle(level);

  Set<String> todayCompleted() {
    if (_currentDay == 0 || _currentDay > 30) return {};
    return _completedTasks[_currentDay - 1];
  }

  bool isDayDone(int day) {
    if (day < 1 || day > 30) return false;
    return _completedTasks[day - 1].length >= kDailyTasks.length;
  }

  int get totalDone => List.generate(30, (i) => isDayDone(i + 1)).where((v) => v).length;

  String get badge {
    final done = totalDone;
    if (done >= 30) return '🥇 Gold Champion';
    if (done >= 21) return '🏅 Diamond Fighter';
    if (done >= 14) return '🥈 Silver Warrior';
    if (done >= 7)  return '🥉 Bronze Fighter';
    if (done >= 3)  return '⚡ Rising Star';
    return '';
  }

  int get todayXp {
    if (_currentDay == 0 || _currentDay > 30) return 0;
    final done = _completedTasks[_currentDay - 1];
    return kDailyTasks
        .where((t) => done.contains(t.id))
        .fold(0, (sum, t) => sum + t.xp);
  }

  int get todayMaxXp => kDailyTasks.fold(0, (sum, t) => sum + t.xp);

  double get todayCompletionPct {
    if (_currentDay == 0) return 0;
    final done = _completedTasks[_currentDay - 1];
    return done.length / kDailyTasks.length;
  }

  bool get isMilestone {
    final done = totalDone;
    return done == 7 || done == 14 || done == 21 || done == 30;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentDay = prefs.getInt('ch_day') ?? 0;
    _startDate  = prefs.getString('ch_start');
    _totalXp    = prefs.getInt('ch_xp') ?? 0;
    final raw   = prefs.getStringList('ch_tasks') ?? [];
    _completedTasks = List.generate(30, (i) {
      if (i < raw.length) {
        final decoded = json.decode(raw[i]) as List;
        return decoded.cast<String>().toSet();
      }
      return <String>{};
    });
    _advanceDayIfNeeded();
  }

  void _advanceDayIfNeeded() {
    if (_startDate == null || _currentDay == 0) return;
    final start = DateTime.parse(_startDate!);
    final today = DateTime.now();
    final diff = today.difference(DateTime(start.year, start.month, start.day)).inDays;
    final expectedDay = diff + 1;
    if (expectedDay > _currentDay && _currentDay <= 30) {
      _currentDay = expectedDay.clamp(1, 31);
    }
  }

  Future<void> start() async {
    _currentDay = 1;
    _startDate  = DateTime.now().toIso8601String();
    await _save();
    notifyListeners();
  }

  Future<void> reset() async {
    _currentDay = 0;
    _startDate = null;
    _totalXp = 0;
    _completedTasks = List.generate(30, (_) => {});
    await _save();
    notifyListeners();
  }

  Future<bool> toggleTask(String taskId) async {
    if (_currentDay == 0 || _currentDay > 30) return false;
    final idx = _currentDay - 1;
    final task = kDailyTasks.firstWhere((t) => t.id == taskId);
    bool completed = false;
    if (_completedTasks[idx].contains(taskId)) {
      _completedTasks[idx].remove(taskId);
      _totalXp = (_totalXp - task.xp).clamp(0, 999999);
    } else {
      _completedTasks[idx].add(taskId);
      _totalXp += task.xp;
      completed = true;
      if (isDayDone(idx + 1)) {
        _totalXp += _xpPerDay;
      }
    }
    await _save();
    notifyListeners();
    return completed;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ch_day', _currentDay);
    await prefs.setInt('ch_xp', _totalXp);
    if (_startDate != null) await prefs.setString('ch_start', _startDate!);
    await prefs.setStringList('ch_tasks',
        _completedTasks.map((s) => json.encode(s.toList())).toList());
  }
}
