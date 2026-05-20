import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/challenge_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _svc = ChallengeService.instance;

  @override
  void initState() {
    super.initState();
    _svc.addListener(_rebuild);
  }

  @override
  void dispose() {
    _svc.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C15),
      body: SafeArea(
        child: _svc.isStarted ? _ActiveChallenge(svc: _svc) : _StartScreen(svc: _svc),
      ),
    );
  }
}

// ── Start Screen ──────────────────────────────────────────────────────────────

class _StartScreen extends StatelessWidget {
  const _StartScreen({required this.svc});
  final ChallengeService svc;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    blurRadius: 30, spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(child: Text('🏆', style: TextStyle(fontSize: 48))),
            ),
            const SizedBox(height: 28),
            Text('30-Day Discipline',
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
            Text('Challenge',
                style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFFFFD700), fontSize: 30, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('Complete daily tasks. Earn XP. Level up.\nBecome unstoppable.',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 14, height: 1.6),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),

            // XP preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111927),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1C2D45)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _XpStat('⚡', '60 XP', 'per day'),
                  _VertDivider(),
                  _XpStat('🏅', 'Badges', 'earn milestones'),
                  _VertDivider(),
                  _XpStat('📈', 'Levels', 'track growth'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            ..._preview(),
            const SizedBox(height: 32),
            _PressBtn(
              onTap: () {
                HapticFeedback.heavyImpact();
                svc.start();
              },
              child: Container(
                width: double.infinity, height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFB300)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text('Start the Challenge',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _preview() => kDailyTasks.map((t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2D45),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(t.icon, style: const TextStyle(fontSize: 20))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Text(t.label,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
        ),
        child: Text('+${t.xp} XP',
            style: GoogleFonts.inter(
                color: const Color(0xFFFFD700), fontWeight: FontWeight.w700, fontSize: 11)),
      ),
    ]),
  )).toList();
}

class _XpStat extends StatelessWidget {
  const _XpStat(this.icon, this.value, this.label);
  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(icon, style: const TextStyle(fontSize: 22)),
    const SizedBox(height: 4),
    Text(value,
        style: GoogleFonts.inter(
            color: const Color(0xFFFFD700), fontWeight: FontWeight.w800, fontSize: 13)),
    Text(label,
        style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
  ]);
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: const Color(0xFF1C2D45));
}

// ── Active Challenge ──────────────────────────────────────────────────────────

class _ActiveChallenge extends StatelessWidget {
  const _ActiveChallenge({required this.svc});
  final ChallengeService svc;

  @override
  Widget build(BuildContext context) {
    final done = svc.todayCompleted();
    final pct = (svc.todayCompletionPct * 100).toInt();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Level + XP bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111927),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1C2D45)),
          ),
          child: Column(children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFB300)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Lv. ${svc.level}  ${svc.levelName}',
                    style: GoogleFonts.inter(
                        color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
              const Spacer(),
              Text('${svc.totalXp} XP',
                  style: GoogleFonts.inter(
                      color: const Color(0xFFFFD700), fontWeight: FontWeight.w700, fontSize: 14)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: svc.levelProgress,
                minHeight: 8,
                backgroundColor: const Color(0xFF1C2D45),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${xpForNextLevel(svc.totalXp)} XP to next level',
                  style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // Day header + today %
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Day ${svc.currentDay.clamp(1, 30)} of 30',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              if (svc.badge.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(svc.badge,
                      style: const TextStyle(
                          color: Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w700)),
                ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$pct%',
                style: GoogleFonts.inter(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w900, fontSize: 28)),
            Text('today',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 12),

        // 30-day progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: svc.currentDay / 30,
            minHeight: 8,
            backgroundColor: const Color(0xFF1C2D45),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
          ),
        ),
        const SizedBox(height: 4),
        Text('${svc.totalDone} days fully completed',
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        const SizedBox(height: 24),

        // Today's tasks
        Text("TODAY'S TASKS",
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
        const SizedBox(height: 12),
        ...kDailyTasks.map((t) => _TaskTile(
          task: t,
          checked: done.contains(t.id),
          onTap: () async {
            final wasChecked = done.contains(t.id);
            final completed = await svc.toggleTask(t.id);
            if (completed) {
              HapticFeedback.mediumImpact();
              if (svc.isDayDone(svc.currentDay)) {
                HapticFeedback.heavyImpact();
              }
            } else if (wasChecked) {
              HapticFeedback.lightImpact();
            }
          },
        )),
        const SizedBox(height: 24),

        // 30-day grid
        Text('30-DAY PROGRESS',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8,
          ),
          itemCount: 30,
          itemBuilder: (_, i) {
            final day = i + 1;
            final isToday = day == svc.currentDay;
            final isDone  = svc.isDayDone(day);
            final isPast  = day < svc.currentDay && !isDone;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isDone
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFB300)])
                    : null,
                color: isDone ? null : isToday
                    ? const Color(0xFF1C2D45)
                    : isPast ? const Color(0xFF111927) : const Color(0xFF0D1520),
                borderRadius: BorderRadius.circular(10),
                border: isToday
                    ? Border.all(color: const Color(0xFFFFD700), width: 2)
                    : null,
                boxShadow: isDone
                    ? [BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        blurRadius: 6)]
                    : null,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.black, size: 14)
                    : Text('$day',
                        style: TextStyle(
                          color: isToday
                              ? Colors.white
                              : isPast
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.15),
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        )),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        Center(
          child: TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1E2C42),
                  title: const Text('Reset challenge?', style: TextStyle(color: Colors.white)),
                  content: const Text('All progress and XP will be lost.',
                      style: TextStyle(color: Colors.white54)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
                    TextButton(onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reset', style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              );
              if (ok == true) svc.reset();
            },
            child: Text('Reset challenge',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.checked, required this.onTap});
  final DayTask task;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressBtn(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFFFFD700).withValues(alpha: 0.08) : const Color(0xFF111927),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: checked
                ? const Color(0xFFFFD700).withValues(alpha: 0.4)
                : const Color(0xFF1C2D45),
          ),
          boxShadow: checked
              ? [BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                  blurRadius: 12)]
              : null,
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: checked
                  ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                  : const Color(0xFF1C2D45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(task.icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(task.label,
                style: TextStyle(
                  color: checked ? Colors.white : Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white38,
                )),
          ),
          const SizedBox(width: 8),
          if (!checked)
            Text('+${task.xp} XP',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 26, height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: checked
                  ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFB300)])
                  : null,
              color: checked ? null : const Color(0xFF1C2D45),
              boxShadow: checked
                  ? [BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 8)]
                  : null,
            ),
            child: checked
                ? const Icon(Icons.check, color: Colors.black, size: 14)
                : null,
          ),
        ]),
      ),
    );
  }
}

class _PressBtn extends StatefulWidget {
  const _PressBtn({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressBtn> createState() => _PressBtnState();
}

class _PressBtnState extends State<_PressBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: widget.child,
      ),
    );
  }
}
