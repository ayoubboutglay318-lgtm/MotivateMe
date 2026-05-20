import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _categories = [
  _MusicCat(emoji: '🏋️', name: 'Gym Mode', desc: 'Heavy beats for heavy lifts', tracks: 24),
  _MusicCat(emoji: '🎯', name: 'Deep Focus', desc: 'Flow state activator', tracks: 18),
  _MusicCat(emoji: '👑', name: 'Alpha Mindset', desc: 'Feel like a king', tracks: 15),
  _MusicCat(emoji: '📖', name: 'Study Mode', desc: 'Low-fi concentration', tracks: 30),
  _MusicCat(emoji: '🌙', name: 'Night Grind', desc: 'Late night hustle', tracks: 12),
  _MusicCat(emoji: '🔥', name: 'No Excuses', desc: 'Maximum intensity', tracks: 20),
];

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  int? _playing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182035),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              const Text('Music',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(8)),
                child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ]),
          ),
          // Now playing banner
          if (_playing != null)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2A3D5A), Color(0xFF1E2C42)]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                Text(_categories[_playing!].emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_categories[_playing!].name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('Now Playing', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
                ])),
                Row(children: [
                  _PlayBtn(icon: Icons.skip_previous_rounded, onTap: () {}),
                  const SizedBox(width: 4),
                  _PlayBtn(icon: Icons.pause_rounded, onTap: () => setState(() => _playing = null), gold: true),
                  const SizedBox(width: 4),
                  _PlayBtn(icon: Icons.skip_next_rounded, onTap: () {}),
                ]),
              ]),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _CatTile(
                cat: _categories[i],
                isPlaying: _playing == i,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Music available in Premium 🎵'), behavior: SnackBarBehavior.floating),
                  );
                  setState(() => _playing = i);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _MusicCat {
  const _MusicCat({required this.emoji, required this.name, required this.desc, required this.tracks});
  final String emoji;
  final String name;
  final String desc;
  final int tracks;
}

class _CatTile extends StatelessWidget {
  const _CatTile({required this.cat, required this.isPlaying, required this.onTap});
  final _MusicCat cat;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPlaying ? const Color(0xFFFFD700).withValues(alpha: 0.08) : const Color(0xFF1E2C42),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying ? const Color(0xFFFFD700).withValues(alpha: 0.5) : const Color(0xFF2A3D5A),
          ),
        ),
        child: Row(children: [
          Text(cat.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cat.name,
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            Text(cat.desc,
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            Text('${cat.tracks} tracks',
                style: const TextStyle(color: Colors.white24, fontSize: 11)),
          ])),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPlaying ? const Color(0xFFFFD700) : const Color(0xFF2A3D5A),
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isPlaying ? Colors.black : Colors.white70,
              size: 22,
            ),
          ),
        ]),
      ),
    );
  }
}

class _PlayBtn extends StatelessWidget {
  const _PlayBtn({required this.icon, required this.onTap, this.gold = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: gold ? const Color(0xFFFFD700) : const Color(0xFF2A3D5A),
        ),
        child: Icon(icon, color: gold ? Colors.black : Colors.white70, size: 18),
      ),
    );
  }
}
