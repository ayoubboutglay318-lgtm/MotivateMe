import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _ctrl = PageController();
  int _page = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  static const _pages = [
    _OBData(
      emoji: '🔥',
      title: "Don't Give Up.",
      subtitle: 'Daily motivation that keeps you going when everything tries to stop you.',
      top: Color(0xFF2C0A0A),
      bottom: Color(0xFF080C15),
      accent: Color(0xFFFF4444),
    ),
    _OBData(
      emoji: '💪',
      title: 'Build Discipline.',
      subtitle: 'Complete daily challenges, track your goals. Become the best version of yourself.',
      top: Color(0xFF0A1A2C),
      bottom: Color(0xFF080C15),
      accent: Color(0xFF4FC3F7),
    ),
    _OBData(
      emoji: '🏆',
      title: 'Win Every Day.',
      subtitle: 'Swipe through quotes, track goals, build habits. Your best life starts now.',
      top: Color(0xFF1A140A),
      bottom: Color(0xFF080C15),
      accent: Color(0xFFFFD700),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _fadeCtrl.reverse().then((_) {
        _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
        _fadeCtrl.forward();
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [page.top, page.bottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: Text('Skip',
                      style: TextStyle(color: page.accent.withValues(alpha: 0.6), fontSize: 14)),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => FadeTransition(
                  opacity: _fade,
                  child: _PageView(page: _pages[i]),
                ),
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? page.accent : Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [page.accent, page.accent.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: page.accent.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      _page < _pages.length - 1 ? 'Continue  →' : "Let's Go 🔥",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: _page == 2 ? Colors.black : Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ]),
        ),
      ),
    );
  }
}

class _OBData {
  const _OBData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.top,
    required this.bottom,
    required this.accent,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final Color top;
  final Color bottom;
  final Color accent;
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page});
  final _OBData page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.accent.withValues(alpha: 0.1),
              border: Border.all(color: page.accent.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: page.accent.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 52)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            width: 50, height: 3,
            decoration: BoxDecoration(
              color: page.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.subtitle,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
