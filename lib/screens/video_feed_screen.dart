import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _videos = [
  _VideoItem(emoji: '💪', title: 'No Days Off', category: 'Gym Motivation', duration: '3:24', views: '2.1M'),
  _VideoItem(emoji: '🔥', title: 'Rise & Grind', category: 'Success Mindset', duration: '4:10', views: '1.8M'),
  _VideoItem(emoji: '👊', title: 'Sigma Mindset', category: 'Discipline', duration: '5:02', views: '3.4M'),
  _VideoItem(emoji: '⚡', title: 'Never Stop', category: 'Gym Edits', duration: '2:48', views: '980K'),
  _VideoItem(emoji: '🏆', title: 'Winners Mentality', category: 'Business', duration: '6:15', views: '1.2M'),
  _VideoItem(emoji: '🎯', title: 'Stay Focused', category: 'Deep Work', duration: '3:55', views: '760K'),
  _VideoItem(emoji: '🐺', title: 'Alpha Energy', category: 'Anime Motivation', duration: '2:30', views: '4.2M'),
  _VideoItem(emoji: '💰', title: 'Build Your Empire', category: 'Business Mindset', duration: '7:20', views: '890K'),
];

class VideoFeedScreen extends StatelessWidget {
  const VideoFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182035),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              const Text('Video Feed',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('PREMIUM', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ]),
          ),
          // Categories
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ['All', 'Gym', 'Mindset', 'Business', 'Anime', 'Sigma'].map((c) {
                final selected = c == 'All';
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFFFD700) : const Color(0xFF1E2C42),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? const Color(0xFFFFD700) : const Color(0xFF2A3D5A)),
                  ),
                  child: Text(c,
                      style: TextStyle(
                          color: selected ? Colors.black : Colors.white54,
                          fontWeight: FontWeight.w700, fontSize: 13)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _videos.length,
              itemBuilder: (_, i) => _VideoCard(video: _videos[i]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _VideoItem {
  const _VideoItem({
    required this.emoji,
    required this.title,
    required this.category,
    required this.duration,
    required this.views,
  });
  final String emoji;
  final String title;
  final String category;
  final String duration;
  final String views;
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});
  final _VideoItem video;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Videos available in Premium 🔥'), behavior: SnackBarBehavior.floating),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2C42),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A3D5A)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Thumbnail placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1829),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Stack(children: [
                Center(
                  child: Text(video.emoji, style: const TextStyle(fontSize: 52)),
                ),
                Positioned(
                  bottom: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(video.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFD700),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                  ),
                ),
              ]),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(video.title,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(video.category,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.visibility_outlined, color: Colors.white24, size: 12),
                const SizedBox(width: 4),
                Text(video.views, style: const TextStyle(color: Colors.white24, fontSize: 11)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
