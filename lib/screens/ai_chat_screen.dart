import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_service.dart';

class _Msg {
  const _Msg({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[
    const _Msg(
      text: "Hey! Tell me how you're feeling or what you're going through. I'll give you the motivation you need. 🔥",
      isUser: false,
    ),
  ];

  /// True while a reply is streaming in. Blocks a second send, because the
  /// coach keeps conversation history and interleaved turns would corrupt it.
  bool _streaming = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send([String? preset]) async {
    if (_streaming) return;
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    setState(() {
      _msgs.add(_Msg(text: text, isUser: true));
      _msgs.add(const _Msg(text: '', isUser: false)); // Filled in as it streams.
      _streaming = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());

    final buffer = StringBuffer();
    try {
      await for (final chunk in AiService.instance.streamReply(text)) {
        if (!mounted) return;
        buffer.write(chunk);
        setState(() => _msgs[_msgs.length - 1] =
            _Msg(text: buffer.toString(), isUser: false));
        _scrollToEnd();
      }
    } finally {
      if (mounted) setState(() => _streaming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2C42),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
            ),
            child: const Center(child: Text('🔥', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Motivation Coach', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14)),
            Text(
              _streaming ? 'Typing...' : 'Always here for you',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
            ),
          ]),
        ]),
      ),
      body: Column(
        children: [
          // Quick prompts
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                'I feel tired', 'I want success', 'I failed today',
                'I\'m scared', 'Give me fire', 'I want to quit',
              ].map((p) => GestureDetector(
                onTap: _streaming ? null : () => _send(p),
                child: Opacity(
                  opacity: _streaming ? 0.4 : 1,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2C42),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2A3D5A)),
                    ),
                    child: Text(p,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                ),
              )).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A3D5A)),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length,
              itemBuilder: (_, i) => _MsgBubble(msg: _msgs[i]),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E2C42),
              border: Border(top: BorderSide(color: Color(0xFF2A3D5A))),
            ),
            child: SafeArea(
              top: false,
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    enabled: !_streaming,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Tell me how you feel...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF2A3D5A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _streaming ? null : _send,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _streaming
                          ? const Color(0xFFFFD700).withValues(alpha: 0.35)
                          : const Color(0xFFFFD700),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MsgBubble extends StatelessWidget {
  const _MsgBubble({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    // An empty assistant bubble means the reply is on its way but no text has
    // arrived yet — show a pulsing dot rather than an empty box.
    final isPending = !msg.isUser && msg.text.isEmpty;

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFFFFD700) : const Color(0xFF1E2C42),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
          border: msg.isUser ? null : Border.all(color: const Color(0xFF2A3D5A)),
        ),
        child: isPending
            ? const _TypingDots()
            : Text(msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.black : Colors.white,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: msg.isUser ? FontWeight.w600 : FontWeight.w400,
                )),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          // Stagger each dot a third of a cycle apart.
          final t = (_c.value + i / 3) % 1.0;
          final opacity = 0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white70,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
