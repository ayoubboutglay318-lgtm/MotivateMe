import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/goals_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _svc = GoalsService.instance;

  @override
  void initState() {
    super.initState();
    _svc.addListener(_rebuild);
    _svc.load();
  }

  @override
  void dispose() {
    _svc.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _addGoal([Goal? preset]) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E2C42),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddGoalSheet(
        onAdd: (g) {
          _svc.addGoal(g);
          HapticFeedback.mediumImpact();
          Navigator.pop(context);
        },
        preset: preset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C15),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(children: [
                Text('Goals',
                    style: GoogleFonts.playfairDisplay(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                const Spacer(),
                _PressableButton(
                  onTap: () => _addGoal(),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFB300)]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                          blurRadius: 12, spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 22),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: _svc.goals.isEmpty
                  ? _EmptyState(onAdd: _addGoal, onPreset: _addGoal)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: _svc.goals.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _GoalCard(
                        goal: _svc.goals[i],
                        onUpdate: (v) {
                          HapticFeedback.selectionClick();
                          _svc.updateProgress(_svc.goals[i].id, v);
                        },
                        onDelete: () {
                          HapticFeedback.mediumImpact();
                          _svc.deleteGoal(_svc.goals[i].id);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

const _suggestedGoals = [
  (icon: '💪', title: 'Work out 30 times', category: 'Fitness', target: 30.0, unit: 'sessions'),
  (icon: '📚', title: 'Read 12 books', category: 'Learning', target: 12.0, unit: 'books'),
  (icon: '💰', title: 'Save money', category: 'Finance', target: 1000.0, unit: '\$'),
  (icon: '🧘', title: 'Meditate daily', category: 'Mindset', target: 30.0, unit: 'days'),
  (icon: '🏃', title: 'Run 100 km', category: 'Fitness', target: 100.0, unit: 'km'),
  (icon: '✍️', title: 'Write every day', category: 'Creativity', target: 30.0, unit: 'days'),
];

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd, required this.onPreset});
  final VoidCallback onAdd;
  final ValueChanged<Goal> onPreset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.15),
                  const Color(0xFFFFD700).withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  blurRadius: 30, spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(child: Text('🎯', style: TextStyle(fontSize: 52))),
          ),
          const SizedBox(height: 28),
          Text(
            'Your future starts\nwith one goal.',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Set a goal and watch yourself grow\ninto who you\'re meant to be.',
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 14, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('POPULAR GOALS',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
          ),
          const SizedBox(height: 14),
          ..._suggestedGoals.map((s) => _SuggestedGoalTile(
            icon: s.icon,
            title: s.title,
            category: s.category,
            onTap: () {
              HapticFeedback.lightImpact();
              onPreset(Goal(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: s.title,
                category: s.category,
                icon: s.icon,
                target: s.target,
                current: 0,
                unit: s.unit,
              ));
            },
          )),
          const SizedBox(height: 28),
          _PressableButton(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFB300)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                    blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text('Create custom goal',
                    style: GoogleFonts.inter(
                        color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedGoalTile extends StatelessWidget {
  const _SuggestedGoalTile({required this.icon, required this.title, required this.category, required this.onTap});
  final String icon;
  final String title;
  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableButton(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF111927),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1C2D45), width: 1),
        ),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              Text(category,
                  style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            ]),
          ),
          Icon(Icons.add_circle_outline,
              color: const Color(0xFFFFD700).withValues(alpha: 0.7), size: 22),
        ]),
      ),
    );
  }
}

// ── Goal Card ─────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.onUpdate, required this.onDelete});
  final Goal goal;
  final ValueChanged<double> onUpdate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final pct = (goal.progress * 100).toInt();
    final done = goal.progress >= 1.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111927),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: done
              ? const Color(0xFFFFD700).withValues(alpha: 0.5)
              : const Color(0xFF1C2D45),
        ),
        boxShadow: done
            ? [BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                blurRadius: 20, spreadRadius: 2)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: done
                    ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                    : const Color(0xFF1C2D45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(goal.icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(goal.title,
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(goal.category,
                    style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
              ]),
            ),
            Text(done ? '✅' : '$pct%',
                style: GoogleFonts.inter(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.delete_outline,
                  color: Colors.white.withValues(alpha: 0.2), size: 20),
            ),
          ]),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF1C2D45),
              valueColor: AlwaysStoppedAnimation<Color>(
                done ? const Color(0xFFFFD700) : const Color(0xFFFFD700).withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Text('${goal.current.toStringAsFixed(0)} ${goal.unit}',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            const Spacer(),
            Text('of ${goal.target.toStringAsFixed(0)} ${goal.unit}',
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
          ]),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              thumbColor: const Color(0xFFFFD700),
              activeTrackColor: const Color(0xFFFFD700),
              inactiveTrackColor: const Color(0xFF1C2D45),
              overlayColor: const Color(0xFFFFD700).withValues(alpha: 0.15),
            ),
            child: Slider(
              value: goal.current,
              min: 0,
              max: goal.target,
              onChanged: onUpdate,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Goal Sheet ─────────────────────────────────────────────────────────────

class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet({required this.onAdd, this.preset});
  final ValueChanged<Goal> onAdd;
  final Goal? preset;

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _unitCtrl;
  String _icon = '🎯';
  String _category = 'Personal';

  @override
  void initState() {
    super.initState();
    final p = widget.preset;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _targetCtrl = TextEditingController(text: p != null ? '${p.target.toInt()}' : '');
    _unitCtrl = TextEditingController(text: p?.unit ?? 'units');
    _icon = p?.icon ?? '🎯';
    _category = p?.category ?? 'Personal';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('New Goal',
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.3), size: 22),
            ),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: kGoalCategories.map((c) {
                final selected = _category == c.$2;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() { _icon = c.$1; _category = c.$2; });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFFD700) : const Color(0xFF1C2D45),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('${c.$1} ${c.$2}',
                        style: GoogleFonts.inter(
                            color: selected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _Input(controller: _titleCtrl, hint: 'Goal title (e.g. Save money)'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _Input(controller: _targetCtrl, hint: 'Target', keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _Input(controller: _unitCtrl, hint: r'Unit (e.g. $, kg, pages)')),
          ]),
          const SizedBox(height: 24),
          _PressableButton(
            onTap: () {
              final title = _titleCtrl.text.trim();
              final target = double.tryParse(_targetCtrl.text) ?? 0;
              if (title.isEmpty || target <= 0) return;
              widget.onAdd(Goal(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                category: _category,
                icon: _icon,
                target: target,
                current: 0,
                unit: _unitCtrl.text.trim().isEmpty ? 'units' : _unitCtrl.text.trim(),
              ));
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFB300)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text('Add Goal',
                    style: GoogleFonts.inter(
                        color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({required this.controller, required this.hint, this.keyboard = TextInputType.text});
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1C2D45),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
        ),
      ),
    );
  }
}

// ── Pressable Button ──────────────────────────────────────────────────────────

class _PressableButton extends StatefulWidget {
  const _PressableButton({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
