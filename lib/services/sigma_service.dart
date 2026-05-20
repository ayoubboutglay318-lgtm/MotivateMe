import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MotivationMode { classic, sigma, gym, study, business, monk }

class ModeInfo {
  const ModeInfo({
    required this.mode,
    required this.emoji,
    required this.name,
    required this.tagline,
    required this.accent,
  });
  final MotivationMode mode;
  final String emoji;
  final String name;
  final String tagline;
  final Color accent;
}

const kModes = [
  ModeInfo(
    mode: MotivationMode.classic,
    emoji: '⭐',
    name: 'Classic',
    tagline: 'Timeless motivation',
    accent: Color(0xFFFFD700),
  ),
  ModeInfo(
    mode: MotivationMode.sigma,
    emoji: '🐺',
    name: 'Sigma',
    tagline: 'Hardcore mindset',
    accent: Color(0xFFFF4444),
  ),
  ModeInfo(
    mode: MotivationMode.gym,
    emoji: '💪',
    name: 'Gym',
    tagline: 'Built different',
    accent: Color(0xFFFF6B35),
  ),
  ModeInfo(
    mode: MotivationMode.study,
    emoji: '📚',
    name: 'Study',
    tagline: 'Knowledge is power',
    accent: Color(0xFF4FC3F7),
  ),
  ModeInfo(
    mode: MotivationMode.business,
    emoji: '💼',
    name: 'Business',
    tagline: 'Build your empire',
    accent: Color(0xFF4CAF50),
  ),
  ModeInfo(
    mode: MotivationMode.monk,
    emoji: '🧘',
    name: 'Monk',
    tagline: 'Peace and clarity',
    accent: Color(0xFF9C27B0),
  ),
];

class SigmaService extends ChangeNotifier {
  static final SigmaService instance = SigmaService._();
  SigmaService._();

  MotivationMode _mode = MotivationMode.classic;
  MotivationMode get mode => _mode;
  bool get sigmaMode => _mode == MotivationMode.sigma;
  ModeInfo get currentMode => kModes.firstWhere((m) => m.mode == _mode);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSigma = prefs.getBool('sigma_mode') ?? false;
    final savedIndex = prefs.getInt('motivation_mode') ?? (savedSigma ? 1 : 0);
    _mode = MotivationMode.values[savedIndex.clamp(0, MotivationMode.values.length - 1)];
    notifyListeners();
  }

  Future<void> setMode(MotivationMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('motivation_mode', mode.index);
    await prefs.setBool('sigma_mode', mode == MotivationMode.sigma);
    notifyListeners();
  }

  Future<void> toggle() async {
    final next = _mode == MotivationMode.sigma ? MotivationMode.classic : MotivationMode.sigma;
    await setMode(next);
  }
}
