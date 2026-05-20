import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/challenge_service.dart';
import '../services/favorites_service.dart';
import '../services/goals_service.dart';
import '../services/streak_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.streakService,
    required this.favoritesService,
  });
  final StreakService streakService;
  final FavoritesService favoritesService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        streakService,
        favoritesService,
        ChallengeService.instance,
        GoalsService.instance,
        AuthService.instance,
      ]),
      builder: (context, _) {
        final auth = AuthService.instance;
        final challenge = ChallengeService.instance;
        final goals = GoalsService.instance;
        final streak = streakService.streak;
        final daysDone = challenge.totalDone;
        final favCount = favoritesService.favorites.length;
        final badge = challenge.badge;
        final goalsCount = goals.goals.length;
        final goalsCompleted = goals.goals.where((g) => g.current >= g.target).length;

        return Scaffold(
          backgroundColor: const Color(0xFF080C15),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 8),

                // Header
                Row(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        auth.isLoggedIn ? auth.displayName[0].toUpperCase() : '?',
                        style: GoogleFonts.playfairDisplay(
                            color: const Color(0xFFFFD700),
                            fontSize: 28,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        auth.isLoggedIn ? auth.displayName : 'Guest',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.isLoggedIn
                            ? (auth.user?.email ?? '')
                            : 'Sign in to track your progress',
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                      ),
                    ]),
                  ),
                  if (!auth.isLoggedIn)
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AuthScreen())),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Sign in',
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 12)),
                      ),
                    ),
                ]),
                const SizedBox(height: 28),

                // Stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(emoji: '🔥', value: '$streak', label: 'Day Streak'),
                    _StatCard(emoji: '💪', value: '$daysDone/30', label: 'Challenge Days'),
                    _StatCard(emoji: '❤️', value: '$favCount', label: 'Saved Quotes'),
                    _StatCard(emoji: '🎯', value: '$goalsCount', label: 'Active Goals'),
                  ],
                ),
                const SizedBox(height: 20),

                // Badge
                if (badge.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2C42),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                    ),
                    child: Row(children: [
                      Text(badge.split(' ')[0],
                          style: const TextStyle(fontSize: 36)),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Badge Earned',
                            style:
                                GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(badge.substring(badge.indexOf(' ') + 1),
                            style: GoogleFonts.inter(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // Weekly streak
                _SectionLabel('THIS WEEK'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2C42),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF2A3D5A)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (i) {
                      const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
                      final done =
                          i < streakService.week.length && streakService.week[i];
                      return Column(children: [
                        Text(days[i],
                            style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? const Color(0xFFFFD700)
                                : const Color(0xFF2A3D5A),
                          ),
                          child: done
                              ? const Icon(Icons.check, color: Colors.black, size: 16)
                              : null,
                        ),
                      ]);
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // Goals summary
                if (goalsCount > 0) ...[
                  _SectionLabel('GOALS ($goalsCompleted/$goalsCount COMPLETED)'),
                  const SizedBox(height: 12),
                  ...goals.goals.map((g) {
                    final progress = (g.current / g.target).clamp(0.0, 1.0);
                    final done = g.current >= g.target;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2C42),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: done
                              ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                              : const Color(0xFF2A3D5A),
                        ),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(g.icon, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(g.title,
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                          Text('${(progress * 100).round()}%',
                              style: GoogleFonts.inter(
                                  color: done
                                      ? const Color(0xFFFFD700)
                                      : Colors.white38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: const Color(0xFF2A3D5A),
                            valueColor: AlwaysStoppedAnimation(
                              done
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFFFD700).withValues(alpha: 0.6),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ]),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // Footer card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2C42),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF2A3D5A)),
                  ),
                  child: Column(children: [
                    const Text('💎', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 10),
                    Text('Keep showing up every day.',
                        style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text(
                        'Consistency is what separates the elite from the rest.',
                        style: GoogleFonts.inter(
                            color: Colors.white38, fontSize: 12, height: 1.5),
                        textAlign: TextAlign.center),
                  ]),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2));
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.emoji, required this.value, required this.label});
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2C42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3D5A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: GoogleFonts.inter(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 20)),
            Text(label,
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
          ]),
        ],
      ),
    );
  }
}
