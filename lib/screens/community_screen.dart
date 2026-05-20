import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _winCtrl = TextEditingController();
  final List<_Win> _wins = [];

  @override
  void dispose() {
    _winCtrl.dispose();
    super.dispose();
  }

  void _shareWin() {
    final text = _winCtrl.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context);
    setState(() {
      _wins.insert(0, _Win(name: 'You', win: text, ago: 'Just now'));
    });
    _winCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182035),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              const Text('My Wins',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const Spacer(),
              GestureDetector(
                onTap: _openShareDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(children: [
                    Icon(Icons.add, color: Colors.black, size: 16),
                    SizedBox(width: 4),
                    Text('Log win', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Track your daily victories. Keep the momentum going.',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12, height: 1.5)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _wins.isEmpty
                ? _EmptyState(onTap: _openShareDialog)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _wins.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _WinCard(win: _wins[i]),
                  ),
          ),
        ]),
      ),
    );
  }

  void _openShareDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E2C42),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log your win 🏆',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: _winCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What did you accomplish today?',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A3D5A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _shareWin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Win', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Win {
  _Win({required this.name, required this.win, required this.ago});
  final String name;
  final String win;
  final String ago;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('Log your first win',
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text('Every small victory counts.\nStart tracking your progress today.',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 13, height: 1.6),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text('Log a win',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WinCard extends StatelessWidget {
  const _WinCard({required this.win});
  final _Win win;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2C42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3D5A)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2A3D5A),
            child: Text(win.name[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(win.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            Text(win.ago, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ])),
        ]),
        const SizedBox(height: 10),
        Text(win.win,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.5)),
      ]),
    );
  }
}
