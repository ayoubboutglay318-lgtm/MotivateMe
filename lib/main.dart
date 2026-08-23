// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'services/challenge_service.dart';
import 'services/favorites_service.dart';
import 'services/goals_service.dart';
import 'services/notification_service.dart';
import 'services/quotes_service.dart';
import 'services/sigma_service.dart';
import 'services/streak_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Firebase.initializeApp() — enable after registering com.ayoub.motivate_me in Firebase console

  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool('onboarded') ?? false;

  final favs = FavoritesService();
  final streak = StreakService();
  await Future.wait([
    favs.load(), streak.load(),
    ChallengeService.instance.load(),
    GoalsService.instance.load(),
    AuthService.instance.load(),
    SigmaService.instance.load(),
    ThemeService.instance.load(),
  ]);

  runApp(MotivateApp(favoritesService: favs, streakService: streak, showOnboarding: !onboarded));
}

class MotivateApp extends StatefulWidget {
  const MotivateApp({
    super.key,
    required this.favoritesService,
    required this.streakService,
    this.showOnboarding = false,
  });
  final FavoritesService favoritesService;
  final StreakService streakService;
  final bool showOnboarding;

  @override
  State<MotivateApp> createState() => _MotivateAppState();
}

class _MotivateAppState extends State<MotivateApp> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
    // Defer the permission prompt until after onboarding explains why
    // notifications matter, rather than surprising first-time users with
    // it immediately on launch.
    if (!_showOnboarding) _initNotifications();
    ThemeService.instance.addListener(_onTheme);
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() => setState(() {});

  Future<void> _initNotifications() async {
    try {
      await NotificationService.instance.init();
      final saved = await NotificationService.instance.getSavedTime();
      final enabled = await NotificationService.instance.isEnabled();
      if (enabled) await NotificationService.instance.schedule(saved);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance.current;
    return MaterialApp(
      title: 'MotivateMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: theme.bg,
        colorScheme: ColorScheme.dark(
          primary: theme.accent,
          secondary: theme.accent,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: theme.card,
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
      home: _showOnboarding
          ? OnboardingScreen(onDone: () {
              setState(() => _showOnboarding = false);
              _initNotifications();
            })
          : HomeScreen(
              quotesService: QuotesService(),
              favoritesService: widget.favoritesService,
              streakService: widget.streakService,
            ),
    );
  }
}
