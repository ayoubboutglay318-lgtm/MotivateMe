import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const _features = [
    (Icons.psychology_outlined,        'AI Personal Motivation',     'Custom advice based on how you feel'),
    (Icons.play_circle_outline,        'Premium Video Feed',          'Gym edits, speeches, anime motivation'),
    (Icons.emoji_events_outlined,      '30-Day Discipline Challenge', 'Daily tasks, XP points & badges'),
    (Icons.lock_open_outlined,         'Lock Screen Motivation',      'Inspire every time you unlock'),
    (Icons.music_note_outlined,        'Motivational Music',          'Gym, focus, deep work & study'),
    (Icons.wallpaper_outlined,         'Premium Wallpapers',          '4K black & gold luxury wallpapers'),
    (Icons.record_voice_over_outlined, 'Voice Motivation',            'AI voice wake-up & daily push'),
    (Icons.track_changes_outlined,     'Goal Tracker',                'Money, gym, study & business goals'),
    (Icons.groups_outlined,            'Private Community',           'Share wins, leaderboard & support'),
    (Icons.notifications_active_outlined, 'Smart Notifications',      'Morning & night personalized messages'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182035),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.white54),
                ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text('Premium Features',
                        style: GoogleFonts.playfairDisplay(
                            color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                      ),
                      child: Text('Coming Soon',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                    const SizedBox(height: 8),
                    Text('We are building something powerful.\nStay tuned for the premium launch.',
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 13, height: 1.6),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    ..._features.map((f) => _FeatureTile(icon: f.$1, title: f.$2, subtitle: f.$3)),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2C42),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                      ),
                      child: Column(children: [
                        const Text('🔥', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 10),
                        Text('Premium is coming.',
                            style: GoogleFonts.playfairDisplay(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('All features above will be available\nin the next update. Keep grinding.',
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 13, height: 1.5),
                            textAlign: TextAlign.center),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Go back',
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD700).withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: const Color(0xFFFFD700), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            Text(subtitle,
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
          ]),
        ),
        const Icon(Icons.access_time_outlined, color: Colors.white24, size: 16),
      ]),
    );
  }
}
