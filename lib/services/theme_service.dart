import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  const AppTheme({
    required this.name,
    required this.emoji,
    required this.accent,
    required this.bg,
    required this.card,
    required this.border,
  });
  final String name;
  final String emoji;
  final Color accent;
  final Color bg;
  final Color card;
  final Color border;
}

const kThemes = [
  AppTheme(
    name: 'Gold',
    emoji: '👑',
    accent: Color(0xFFFFD700),
    bg: Color(0xFF182035),
    card: Color(0xFF1E2C42),
    border: Color(0xFF2A3D5A),
  ),
  AppTheme(
    name: 'Red Fire',
    emoji: '🔥',
    accent: Color(0xFFFF4444),
    bg: Color(0xFF1A0505),
    card: Color(0xFF2A0A0A),
    border: Color(0xFF4A1010),
  ),
  AppTheme(
    name: 'Blue Ice',
    emoji: '⚡',
    accent: Color(0xFF4FC3F7),
    bg: Color(0xFF050F1A),
    card: Color(0xFF0D1E2C),
    border: Color(0xFF1A3040),
  ),
  AppTheme(
    name: 'Green',
    emoji: '🌿',
    accent: Color(0xFF4CAF50),
    bg: Color(0xFF051A05),
    card: Color(0xFF0A2C0A),
    border: Color(0xFF1A401A),
  ),
  AppTheme(
    name: 'Purple',
    emoji: '🌌',
    accent: Color(0xFF9C27B0),
    bg: Color(0xFF0D0520),
    card: Color(0xFF1A0D35),
    border: Color(0xFF2D1555),
  ),
];

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._();
  ThemeService._();

  int _themeIndex = 0;
  int get themeIndex => _themeIndex;
  AppTheme get current => kThemes[_themeIndex];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeIndex = (prefs.getInt('theme_index') ?? 0).clamp(0, kThemes.length - 1);
    notifyListeners();
  }

  Future<void> setTheme(int index) async {
    _themeIndex = index.clamp(0, kThemes.length - 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', _themeIndex);
    notifyListeners();
  }
}
