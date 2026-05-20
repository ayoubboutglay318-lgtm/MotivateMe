import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Goal {
  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.target,
    required this.current,
    required this.unit,
  });

  final String id;
  String title;
  String category;
  String icon;
  double target;
  double current;
  String unit;

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0;

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'category': category, 'icon': icon,
    'target': target, 'current': current, 'unit': unit,
  };

  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
    id: j['id'], title: j['title'], category: j['category'], icon: j['icon'],
    target: (j['target'] as num).toDouble(),
    current: (j['current'] as num).toDouble(),
    unit: j['unit'],
  );
}

const kGoalCategories = [
  ('💰', 'Money'),
  ('💪', 'Gym'),
  ('📖', 'Study'),
  ('🚀', 'Business'),
  ('🏃', 'Fitness'),
  ('🎯', 'Personal'),
];

class GoalsService extends ChangeNotifier {
  static final GoalsService instance = GoalsService._();
  GoalsService._();

  List<Goal> _goals = [];
  List<Goal> get goals => List.unmodifiable(_goals);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('goals_list');
    if (raw != null) {
      final list = json.decode(raw) as List;
      _goals = list.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
    }
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _save();
    notifyListeners();
  }

  Future<void> updateProgress(String id, double newValue) async {
    final goal = _goals.firstWhere((g) => g.id == id);
    goal.current = newValue.clamp(0, goal.target);
    await _save();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('goals_list', json.encode(_goals.map((g) => g.toJson()).toList()));
  }
}
