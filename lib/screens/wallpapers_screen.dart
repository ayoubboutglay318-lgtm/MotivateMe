import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _wallpapers = [
  _Wallpaper(emoji: '👑', title: 'King Mindset', bg: Color(0xFF0D0D0D), accent: Color(0xFFFFD700)),
  _Wallpaper(emoji: '🔥', title: "Don't Give Up", bg: Color(0xFF1A0A00), accent: Color(0xFFFF6B00)),
  _Wallpaper(emoji: '⚡', title: 'Stay Dangerous', bg: Color(0xFF0A0A1A), accent: Color(0xFF7B6FFF)),
  _Wallpaper(emoji: '🐺', title: 'Lone Wolf', bg: Color(0xFF050510), accent: Color(0xFF4FC3F7)),
  _Wallpaper(emoji: '💎', title: 'Diamond Grind', bg: Color(0xFF001020), accent: Color(0xFF64B5F6)),
  _Wallpaper(emoji: '🏆', title: 'Champion', bg: Color(0xFF0D0D0D), accent: Color(0xFFFFD700)),
  _Wallpaper(emoji: '🌑', title: 'Dark Sigma', bg: Color(0xFF050505), accent: Color(0xFF888888)),
  _Wallpaper(emoji: '🚀', title: 'To The Top', bg: Color(0xFF000820), accent: Color(0xFF4FC3F7)),
];

class WallpapersScreen extends StatelessWidget {
  const WallpapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182035),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(children: [
              const Text('Wallpapers',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(8)),
                child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ]),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _wallpapers.length,
              itemBuilder: (_, i) => _WallpaperCard(w: _wallpapers[i]),
            ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _Wallpaper {
  const _Wallpaper({required this.emoji, required this.title, required this.bg, required this.accent});
  final String emoji;
  final String title;
  final Color bg;
  final Color accent;
}

class _WallpaperCard extends StatelessWidget {
  const _WallpaperCard({required this.w});
  final _Wallpaper w;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _WallpaperPreview(w: w),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: w.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: w.accent.withValues(alpha: 0.3)),
        ),
        child: Stack(children: [
          Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(w.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(w.title,
                  style: GoogleFonts.playfairDisplay(
                      color: w.accent, fontSize: 14, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Container(width: 30, height: 1, color: w.accent.withValues(alpha: 0.5)),
            ]),
          ),
          Positioned(
            bottom: 10, right: 10,
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: w.accent.withValues(alpha: 0.15),
                border: Border.all(color: w.accent.withValues(alpha: 0.4)),
              ),
              child: Icon(Icons.download_outlined, color: w.accent, size: 16),
            ),
          ),
        ]),
      ),
    );
  }
}

class _WallpaperPreview extends StatelessWidget {
  const _WallpaperPreview({required this.w});
  final _Wallpaper w;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 500,
          decoration: BoxDecoration(
            color: w.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: w.accent.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(w.emoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              Text(w.title,
                  style: GoogleFonts.playfairDisplay(
                      color: w.accent, fontSize: 28, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Container(width: 60, height: 2, color: w.accent.withValues(alpha: 0.5)),
              const SizedBox(height: 20),
              Text('motivateme', style: TextStyle(color: w.accent.withValues(alpha: 0.4), fontSize: 12, letterSpacing: 3)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wallpaper downloads available in Premium ⭐'), behavior: SnackBarBehavior.floating),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}
