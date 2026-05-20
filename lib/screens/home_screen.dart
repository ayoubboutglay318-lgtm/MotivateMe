import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_tts/flutter_tts.dart';
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
                            color: selected
                                ? const Color(0xFFFFD700)
                                : Colors.white30,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].$3,
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? const Color(0xFFFFD700)
                                : Colors.white30,
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
  int _page = 0;

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
    setState(() => _page = page);
    if (page >= _quotes.length - 1) _loadNext();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              const Text(
                'MotivateMe',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FavoritesScreen(favoritesService: widget.favoritesService))),
                child: Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2540),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF243050)),
                  ),
                  child: const Icon(Icons.favorite_outline, color: Color(0xFFFFD700), size: 20),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 4),
          _StreakHeader(streakService: widget.streakService),
          Expanded(
            child: _loading
                ? const _LoadingCard()
                : PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: _onPageChanged,
                    itemCount: _quotes.length + 1,
                    itemBuilder: (_, i) {
                      if (i >= _quotes.length) {
                        return const Center(
                            child: CircularProgressIndicator(color: Color(0xFFFFD700)));
                      }
                      return _QuoteCard(
                        quote: _quotes[i],
                        favoritesService: widget.favoritesService,
                        onRefresh: () {
                          _loadNext();
                          _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Streak Header ─────────────────────────────────────────────────────────────

class _StreakHeader extends StatefulWidget {
  const _StreakHeader({required this.streakService});
  final StreakService streakService;

  @override
  State<_StreakHeader> createState() => _StreakHeaderState();
}

class _StreakHeaderState extends State<_StreakHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flameCtrl;
  late final Animation<double> _flameScale;

  static const _days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  void initState() {
    super.initState();
    _flameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _flameScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _flameCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.streakService,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A2540),
                const Color(0xFF1E2D45),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF243050)),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  ScaleTransition(
                    scale: _flameScale,
                    child: const Text('🔥', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.streakService.streak}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                  Text(
                    'days',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: 1,
                height: 48,
                color: const Color(0xFF243050),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This week',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final done = i < widget.streakService.week.length && widget.streakService.week[i];
                        return Column(children: [
                          Text(_days[i],
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 5),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF243050),
                              boxShadow: done
                                  ? [BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                      blurRadius: 6,
                                    )]
                                  : null,
                            ),
                            child: done
                                ? const Icon(Icons.check, color: Colors.black, size: 13)
                                : null,
                          ),
                        ]);
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Quote Card ────────────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.favoritesService, required this.onRefresh});
  final Quote quote;
  final FavoritesService favoritesService;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C2B50), Color(0xFF0F1A35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '“',
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFFFFD700),
                      fontSize: 110,
                      height: 0.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    quote.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    height: 1,
                    width: 60,
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '— ${quote.author}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFFD700),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _ActionRow(quote: quote, favoritesService: favoritesService, onRefresh: onRefresh),
          const SizedBox(height: 8),
          Text(
            'swipe for next  →',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.15),
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatefulWidget {
  const _ActionRow({required this.quote, required this.favoritesService, required this.onRefresh});
  final Quote quote;
  final FavoritesService favoritesService;
  final VoidCallback onRefresh;

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  final _tts = FlutterTts();
  bool _speaking = false;

  Future<void> _speak() async {
    if (_speaking) {
      await _tts.stop();
      setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(0.95);
    await _tts.speak('${widget.quote.text}. — ${widget.quote.author}');
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.favoritesService,
      builder: (context, _) {
        final isFav = widget.favoritesService.isFavorite(widget.quote);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Btn(
              icon: isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : Colors.white38,
              active: isFav,
              onTap: () {
                widget.favoritesService.toggle(widget.quote);
                if (!isFav) HapticFeedback.mediumImpact();
              },
            ),
            const SizedBox(width: 10),
            _Btn(
              icon: _speaking ? Icons.stop_rounded : Icons.volume_up_outlined,
              color: _speaking ? const Color(0xFFFFD700) : Colors.white38,
              active: _speaking,
              onTap: _speak,
            ),
            const SizedBox(width: 10),
            _Btn(
              icon: Icons.copy_outlined,
              color: Colors.white38,
              active: false,
              onTap: () {
                Clipboard.setData(ClipboardData(
                    text: '"${widget.quote.text}" — ${widget.quote.author}'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF1A2540),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            _Btn(
              icon: Icons.share_outlined,
              color: Colors.white38,
              active: false,
              onTap: () {
                final text = '"${widget.quote.text}"\n— ${widget.quote.author}\n\n🔥 MotivateMe';
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied! Paste into Instagram / TikTok'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF1A2540),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            _Btn(
              icon: Icons.refresh_rounded,
              color: Colors.white38,
              active: false,
              onTap: widget.onRefresh,
            ),
          ],
        );
      },
    );
  }
}

class _Btn extends StatefulWidget {
  const _Btn({
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.active
                ? widget.color.withValues(alpha: 0.15)
                : const Color(0xFF1A2540),
            border: Border.all(
              color: widget.active
                  ? widget.color.withValues(alpha: 0.4)
                  : const Color(0xFF243050),
            ),
            boxShadow: widget.active
                ? [BoxShadow(
                    color: widget.color.withValues(alpha: 0.25),
                    blurRadius: 10, spreadRadius: 1)]
                : null,
          ),
          child: Icon(widget.icon, color: widget.color, size: 21),
        ),
      ),
    );
  }
}

// ── Loading Card ──────────────────────────────────────────────────────────────

class _LoadingCard extends StatefulWidget {
  const _LoadingCard();

  @override
  State<_LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<_LoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final opacity = 0.04 + _anim.value * 0.08;
          return Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C2B50), Color(0xFF0F1A35)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: opacity),
                            borderRadius: BorderRadius.circular(8),
                          )),
                      const SizedBox(height: 28),
                      Container(width: double.infinity, height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: opacity),
                            borderRadius: BorderRadius.circular(9),
                          )),
                      const SizedBox(height: 12),
                      Container(width: 220, height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: opacity),
                            borderRadius: BorderRadius.circular(9),
                          )),
                      const SizedBox(height: 12),
                      Container(width: 160, height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: opacity),
                            borderRadius: BorderRadius.circular(9),
                          )),
                      const SizedBox(height: 32),
                      Container(width: 100, height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: opacity * 1.5),
                            borderRadius: BorderRadius.circular(7),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: opacity),
                  ),
                )),
              ),
            ],
          );
        },
      ),
    );
  }
}
