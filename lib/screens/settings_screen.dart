import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/sigma_service.dart';
import '../services/theme_service.dart';
import 'auth_screen.dart';
import 'community_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  bool _enabled = true;
  bool _loading = true;
  bool _sigma = false;

  @override
  void initState() {
    super.initState();
    _load();
    SigmaService.instance.addListener(_onSigma);
  }

  @override
  void dispose() {
    SigmaService.instance.removeListener(_onSigma);
    super.dispose();
  }

  void _onSigma() => setState(() => _sigma = SigmaService.instance.sigmaMode);

  Future<void> _load() async {
    final t = await NotificationService.instance.getSavedTime();
    final e = await NotificationService.instance.isEnabled();
    if (mounted) setState(() {
      _time = t;
      _enabled = e;
      _sigma = SigmaService.instance.sigmaMode;
      _loading = false;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFFFFD700), onSurface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
      await NotificationService.instance.schedule(picked, enabled: _enabled);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Notification set for ${picked.format(context)}'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _toggleEnabled(bool val) async {
    setState(() => _enabled = val);
    await NotificationService.instance.schedule(_time, enabled: val);
  }

  void _push(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2C42),
        title: const Text('Sign out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign out', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) { await AuthService.instance.signOut(); if (mounted) setState(() {}); }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF080C15),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 8),
                  const Text('Settings',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 20),

                  _SectionLabel('NOTIFICATIONS'),
                  const SizedBox(height: 10),
                  _GroupCard(children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      label: 'Daily motivation',
                      subtitle: 'Get a quote every day',
                      trailing: Switch(
                        value: _enabled,
                        activeThumbColor: const Color(0xFFFFD700),
                        activeTrackColor: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        onChanged: _toggleEnabled,
                      ),
                    ),
                    const _Divider(),
                    _SettingsTile(
                      icon: Icons.access_time_rounded,
                      label: 'Notification time',
                      subtitle: _enabled ? _time.format(context) : 'Off',
                      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      onTap: _enabled ? _pickTime : null,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  _SectionLabel('MOTIVATION MODE'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2C42),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A3D5A)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ListenableBuilder(
                        listenable: SigmaService.instance,
                        builder: (context, _) {
                          final current = SigmaService.instance.currentMode;
                          return Column(children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: current.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: current.accent.withValues(alpha: 0.3)),
                              ),
                              child: Row(children: [
                                Text(current.emoji, style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(current.name,
                                      style: TextStyle(color: current.accent, fontWeight: FontWeight.w800, fontSize: 16)),
                                  Text(current.tagline,
                                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                ]),
                              ]),
                            ),
                            const SizedBox(height: 14),
                            GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.4,
                              children: kModes.map((m) {
                                final selected = SigmaService.instance.mode == m.mode;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    SigmaService.instance.setMode(m.mode);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? m.accent.withValues(alpha: 0.15)
                                          : const Color(0xFF243050),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selected ? m.accent.withValues(alpha: 0.6) : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Text(m.emoji, style: const TextStyle(fontSize: 20)),
                                      const SizedBox(height: 4),
                                      Text(m.name,
                                          style: TextStyle(
                                            color: selected ? m.accent : Colors.white54,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ]),
                                  ),
                                );
                              }).toList(),
                            ),
                          ]);
                        },
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  _SectionLabel('APPEARANCE'),
                  const SizedBox(height: 10),
                  _GroupCard(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Theme Color',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(kThemes.length, (i) {
                            final t = kThemes[i];
                            final selected = ThemeService.instance.themeIndex == i;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ThemeService.instance.setTheme(i);
                              },
                              child: Column(children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: t.accent,
                                    border: Border.all(
                                      color: selected ? Colors.white : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: selected ? [BoxShadow(color: t.accent.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)] : null,
                                  ),
                                  child: selected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                                ),
                                const SizedBox(height: 6),
                                Text(t.emoji, style: const TextStyle(fontSize: 14)),
                              ]),
                            );
                          }),
                        ),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  _SectionLabel('COMMUNITY'),
                  const SizedBox(height: 10),
                  _GroupCard(children: [
                    _SettingsTile(
                      icon: Icons.groups_outlined,
                      label: 'Community',
                      subtitle: 'Share wins, leaderboard',
                      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      onTap: () => _push(const CommunityScreen()),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  _SectionLabel('ACCOUNT'),
                  const SizedBox(height: 10),
                  _GroupCard(children: [
                    if (!auth.isLoggedIn)
                      _SettingsTile(
                        icon: Icons.person_outline,
                        label: 'Sign in',
                        subtitle: 'Save your favorites & streak',
                        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                        onTap: () => _push(const AuthScreen()),
                      )
                    else ...[
                      _SettingsTile(
                        icon: Icons.person_outline,
                        label: auth.displayName,
                        subtitle: auth.user?.email ?? '',
                        trailing: const SizedBox.shrink(),
                      ),
                      const _Divider(),
                      _SettingsTile(
                        icon: Icons.logout,
                        label: 'Sign out',
                        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                        onTap: _signOut,
                      ),
                    ],
                  ]),
                  const SizedBox(height: 20),

                  _SectionLabel('OTHER'),
                  const SizedBox(height: 10),
                  _GroupCard(children: [
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      onTap: () => _push(const PrivacyPolicyScreen()),
                    ),
                    const _Divider(),
                    _SettingsTile(
                      icon: Icons.gavel_outlined,
                      label: 'Terms of Use',
                      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      onTap: () => _push(const TermsScreen()),
                    ),
                  ]),
                  const SizedBox(height: 32),

                  Center(
                    child: Text('MotivateMe v1.0.0',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 12)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2));
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2C42),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A3D5A)),
        ),
        child: Column(children: children),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0xFF2A3D5A), indent: 54);
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFF2A3D5A)),
        child: Icon(icon, color: Colors.white70, size: 18),
      ),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: Colors.white54, fontSize: 12))
          : null,
      trailing: trailing,
    );
  }
}
