import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/favorites_service.dart';
import '../services/quotes_service.dart';
import '../services/streak_service.dart';
import 'challenge_screen.dart';
import 'favorites_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.quotesService,
    required this.favoritesService,
    required this.streakService,
  });
  final QuotesService quotesService;
  final FavoritesService favoritesService;
  final StreakService streakService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C15),
      body: IndexedStack(
        index: _tab,
        children: [
          _QuoteTab(
            quotesService: widget.quotesService,
            favoritesService: widget.favoritesService,
            streakService: widget.streakService,
          ),
          const ChallengeScreen(),
          const GoalsScreen(),
          ProfileScreen(
            streakService: widget.streakService,
            favoritesService: widget.favoritesService,
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        current: _tab,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _tab = i);
        },
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.current, required this.onTap});
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.format_quote_rounded, Icons.format_quote_rounded, 'Quotes'),
      (Icons.emoji_events_outlined, Icons.emoji_events, 'Challenge'),
      (Icons.track_changes_outlined, Icons.track_changes, 'Goals'),
      (Icons.person_outline, Icons.person, 'Profile'),
      (Icons.settings_outlined, Icons.settings, 'Settings'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1525),
        border: Border(top: BorderSide(color: Color(0xFF1C2D4A), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == current;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFFFD700).withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            selected ? items[i].$2 : items[i].$1,
                            size: 22,
                            color: selected ? const Color(0xFFFFD700) : Colors.white30,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].$3,
                          style: TextStyle(
                            fontSize: 10,
                            color: selected ? const Color(0xFFFFD700) : Colors.white30,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Quote Tab ─────────────────────────────────────────────────────────────────

class _QuoteTab extends StatefulWidget {
  const _QuoteTab({
    required this.quotesService,
    required this.favoritesService,
    required this.streakService,
  });
  final QuotesService quotesService;
  final FavoritesService favoritesService;
  final StreakService streakService;

  @override
  State<_QuoteTab> createState() => _QuoteTabState();
}

class _QuoteTabState extends State<_QuoteTab> {
  final List<Quote> _quotes = [];
  bool _loading = true;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _loadInitial();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final q = await widget.quotesService.getTodayQuote();
    if (mounted) setState(() { _quotes.add(q); _loading = false; });
  }

  Future<void> _loadNext() async {
    final q = await widget.quotesService.refreshQuote();
    if (mounted) setState(() => _quotes.add(q));
  }

  void _onPageChanged(int page) {
    if (page >= _quotes.length - 1) _loadNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _LoadingCard();

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageCtrl,
          onPageChanged: _onPageChanged,
          itemCount: _quotes.length + 1,
          itemBuilder: (_, i) {
            if (i >= _quotes.length) {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            return _QuoteCard(
              quote: _quotes[i],
              index: i,
              favoritesService: widget.favoritesService,
            );
          },
        ),
        // Floating top bar (streak + favorites)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopOverlay(
            streakService: widget.streakService,
            favoritesService: widget.favoritesService,
          ),
        ),
      ],
    );
  }
}

// ── Top Overlay ───────────────────────────────────────────────────────────────

class _TopOverlay extends StatelessWidget {
  const _TopOverlay({required this.streakService, required this.favoritesService});
  final StreakService streakService;
  final FavoritesService favoritesService;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            ListenableBuilder(
              listenable: streakService,
              builder: (context, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '${streakService.streak} days',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FavoritesScreen(favoritesService: favoritesService))),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.4),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.favorite_outline, color: Colors.white, size: 19),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quote Card ────────────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.index,
    required this.favoritesService,
  });
  final Quote quote;
  final int index;
  final FavoritesService favoritesService;

  static const _bgImages = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
    'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?w=800&q=80',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80',
    'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=800&q=80',
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&q=80',
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
    'https://images.unsplash.com/photo-1532274402911-5a369e4c4bb5?w=800&q=80',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80',
    'https://images.unsplash.com/photo-1477322524744-0eece9e79640?w=800&q=80',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=800&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
  ];

  static const _fallbackColors = [
    [Color(0xFF1a1a2e), Color(0xFF16213e)],
    [Color(0xFF0d2137), Color(0xFF1a3a5c)],
    [Color(0xFF1b2838), Color(0xFF2a475e)],
    [Color(0xFF1c1c2e), Color(0xFF2d2d4e)],
  ];

  @override
  Widget build(BuildContext context) {
    final imgUrl = _bgImages[index % _bgImages.length];
    final fallback = _fallbackColors[index % _fallbackColors.length];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background photo
        Image.network(
          imgUrl,
          fit: BoxFit.cover,
          errorBuilder: (context2, err, stack) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: fallback,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Dark gradient for readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.45),
                Colors.black.withValues(alpha: 0.72),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '“',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 96,
                        height: 0.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      quote.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.65,
                        shadows: const [
                          Shadow(
                            color: Color(0xCC000000),
                            blurRadius: 14,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      height: 1,
                      width: 44,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '— ${quote.author}',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              _ActionBar(quote: quote, favoritesService: favoritesService),
              const SizedBox(height: 10),
              Text(
                'swipe for next',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Action Bar (Heart + Share) ────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.quote, required this.favoritesService});
  final Quote quote;
  final FavoritesService favoritesService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: favoritesService,
      builder: (context, _) {
        final isFav = favoritesService.isFavorite(quote);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FloatBtn(
              icon: isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : Colors.white,
              onTap: () {
                favoritesService.toggle(quote);
                if (!isFav) HapticFeedback.mediumImpact();
              },
            ),
            const SizedBox(width: 24),
            _FloatBtn(
              icon: Icons.share_outlined,
              color: Colors.white,
              onTap: () {
                final text = '"${quote.text}"\n— ${quote.author}\n\nMotivateMe';
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied! Paste anywhere to share'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _FloatBtn extends StatefulWidget {
  const _FloatBtn({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_FloatBtn> createState() => _FloatBtnState();
}

class _FloatBtnState extends State<_FloatBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Icon(widget.icon, color: widget.color, size: 26),
        ),
      ),
    );
  }
}

// ── Loading Card ──────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: CircularProgressIndicator(color: Colors.white38, strokeWidth: 2),
      ),
    );
  }
}
