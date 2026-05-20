import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_service.dart';

class _Msg {
  const _Msg({required this.text, required this.isUser, this.emoji = ''});
  final String text;
  final bool isUser;
  final String emoji;
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
      emoji: '🔥',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    setState(() => _msgs.add(_Msg(text: text, isUser: true)));

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final response = AiService.instance.respond(text);
      setState(() => _msgs.add(_Msg(text: response.text, isUser: false, emoji: response.emoji)));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
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
            Text('AI Motivation', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14)),
            Text('Always here for you', style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
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
                onTap: () {
                  _ctrl.text = p;
                  _send();
                },
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
                  onTap: _send,
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFD700),
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
        child: Text(msg.text,
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
