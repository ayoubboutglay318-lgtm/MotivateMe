import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/favorites_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.favoritesService});
  final FavoritesService favoritesService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF182035),
        foregroundColor: Colors.white,
        title: Text('Favorites',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: favoritesService,
        builder: (context, _) {
          final favs = favoritesService.favorites;
          if (favs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, color: Colors.white24, size: 64),
                  const SizedBox(height: 16),
                  Text('No favorites yet',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Tap the heart on a quote to save it.',
                      style: GoogleFonts.inter(color: Colors.white24, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final q = favs[i];
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2C42),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A3D5A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${q.text}"',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '— ${q.author}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 18, color: Colors.white38),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '"${q.text}" — ${q.author}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied!'), behavior: SnackBarBehavior.floating),
                            );
                          },
                          tooltip: 'Copy',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.favorite, size: 18, color: Colors.redAccent),
                          onPressed: () => favoritesService.toggle(q),
                          tooltip: 'Remove',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
