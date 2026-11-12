import 'dart:math';

import 'claude_client.dart';

class AiResponse {
  const AiResponse({required this.text, required this.emoji});
  final String text;
  final String emoji;
}

/// The chat coach.
///
/// Talks to Claude when the app is configured with a proxy or key (see
/// [ClaudeConfig]), and falls back to the built-in responses below when it
/// isn't — no network, no key, or a failed request. The offline path is what
/// shipped before live replies existed, and it stays as the safety net so the
/// screen is never dead.
class AiService {
  static final AiService instance = AiService._();
  AiService._();

  final _rng = Random();
  final _client = ClaudeClient();

  /// Prior turns, oldest first, in Messages API shape.
  final _history = <Map<String, String>>[];

  /// Turns kept before the oldest are dropped. Each turn is a user message and
  /// a reply, so this is 10 exchanges — enough for the coach to follow a
  /// conversation without the request growing without bound.
  static const _maxHistory = 20;

  bool get isLive => ClaudeConfig.isConfigured;

  void reset() => _history.clear();

  void dispose() => _client.close();

  static const _systemPrompt = '''
You are the coach inside MotivateMe, a motivational app. Someone opened it
because they want to be pushed, encouraged, or steadied.

Voice: direct, warm, fired up. Talk like a coach who believes in them, not like
a self-help book. Two to four sentences unless they clearly want more. At most
one emoji, and only where it lands. No bullet points or headings — this is a
chat, not a handout.

Answer what they actually wrote. If they name something specific — an exam, a
breakup, a training plateau, a boss — respond to that, not to motivation in the
abstract. Ask a question back when you genuinely need to know more.

Intensity is a tool, not a default. Someone grinding toward a goal wants fire.
Someone who sounds exhausted, defeated or hurt needs you steady before they need
you loud. Work out which one you are talking to before you pick a gear.

If someone describes self-harm, suicidal thoughts, abuse, or any crisis, drop
the hype completely. Take them seriously, say plainly that this deserves real
support, and encourage them to reach a local crisis line or somebody they trust.
Never aim a "no excuses" line at someone in that state. You are a motivational
coach, not a therapist, and you should not act like one.
''';

  /// Streams a reply, yielding text as it arrives.
  ///
  /// Appends both sides of the exchange to [_history] so the next message has
  /// context. On any failure this yields one of the offline responses instead,
  /// so the user always gets something back.
  Stream<String> streamReply(String input) async* {
    if (!isLive) {
      yield respond(input).text;
      return;
    }

    _history.add({'role': 'user', 'content': input});
    _trimHistory();

    final reply = StringBuffer();
    try {
      await for (final chunk in _client.streamReply(
        system: _systemPrompt,
        history: List.of(_history),
      )) {
        reply.write(chunk);
        yield chunk;
      }
    } on ClaudeException {
      // Drop the unanswered user turn so a failed request doesn't poison the
      // next one, then fall back to the built-in responses.
      _history.removeLast();
      yield respond(input).text;
      return;
    }

    _history.add({'role': 'assistant', 'content': reply.toString()});
    _trimHistory();
  }

  void _trimHistory() {
    if (_history.length <= _maxHistory) return;
    _history.removeRange(0, _history.length - _maxHistory);
    // A history that starts on an assistant turn is rejected by the API.
    if (_history.first['role'] == 'assistant') _history.removeAt(0);
  }

  static const _responses = {
    'tired': [
      AiResponse(emoji: '🔥', text: "Rest if you must — but don't you quit. Champions aren't built on comfort. Every champion was once a contender who refused to give up."),
      AiResponse(emoji: '💪', text: "Your body is tired, but your soul knows what you're capable of. Sleep, recover, then come back stronger. That's not weakness — that's strategy."),
      AiResponse(emoji: '⚡', text: "Even the sun sets to rise again. Your fatigue is proof you've been pushing hard. Rest is part of the grind. Tomorrow, you go again."),
    ],
    'sad': [
      AiResponse(emoji: '🌅', text: "It's okay to feel broken — diamonds are formed under pressure. The pain you feel today is the strength you'll carry tomorrow. Keep going."),
      AiResponse(emoji: '🔥', text: "Sadness is just fuel you haven't ignited yet. Every person who changed the world had moments they wanted to quit. You're not alone in this fight."),
      AiResponse(emoji: '💎', text: "The greatest chapters of your story haven't been written yet. Today's tears water tomorrow's garden. This feeling is temporary — your greatness is permanent."),
    ],
    'fail': [
      AiResponse(emoji: '🏆', text: "You didn't fail — you learned. Edison failed 10,000 times before the lightbulb. Every failure is a lesson getting you closer to your breakthrough."),
      AiResponse(emoji: '🔥', text: "Failure is not the opposite of success — it's part of it. The only real failure is giving up. Get up, dust off, go again."),
      AiResponse(emoji: '💪', text: "Every master was once a disaster. Every champion lost before they won. Your failure today is the foundation of your success tomorrow. Rise."),
    ],
    'motivation': [
      AiResponse(emoji: '🔥', text: "Motivation is a lie. Discipline is the truth. Don't wait to feel motivated — act, and motivation will follow. Start now, start ugly, just start."),
      AiResponse(emoji: '⚡', text: "You don't need motivation. You need to remember your WHY. What are you fighting for? Lock in on that, and nothing can stop you."),
      AiResponse(emoji: '🏆', text: "Stop waiting for the perfect moment. The perfect moment is now. Every second you wait, someone else is putting in the work. Move."),
    ],
    'success': [
      AiResponse(emoji: '💰', text: "Success is not luck — it's the compound interest of daily discipline. Every small action you take today pays dividends tomorrow. Stay consistent."),
      AiResponse(emoji: '🚀', text: "The difference between where you are and where you want to be is the work you put in when nobody's watching. That's where champions are made."),
      AiResponse(emoji: '👑', text: "Rich isn't a number — it's a mindset. Program your mind for abundance, work like your life depends on it, and never stop learning. Success is yours."),
    ],
    'fear': [
      AiResponse(emoji: '⚡', text: "Fear means you're about to do something brave. Feel it, acknowledge it, then walk through it anyway. Everything you want is on the other side of fear."),
      AiResponse(emoji: '🔥', text: "The lions of doubt roar loudest right before your breakthrough. Don't let fear write your story. You are stronger than anything that tries to stop you."),
      AiResponse(emoji: '💎', text: "Courage isn't the absence of fear — it's acting despite it. Every great person in history was terrified. They acted anyway. Now it's your turn."),
    ],
    'gym': [
      AiResponse(emoji: '💪', text: "Your body can do it. It's your mind you have to convince. When your legs say stop, tell them to shut up. Champions are built in the moments you want to quit."),
      AiResponse(emoji: '🔥', text: "Every rep you don't want to do is the most important rep you'll ever do. That's where the real gains live — in the reps you almost didn't finish."),
      AiResponse(emoji: '⚡', text: "Pain is temporary. Quitting lasts forever. When that bar gets heavy and your mind tells you to stop — that's exactly when you don't. One more rep. Always one more."),
    ],
    'give up': [
      AiResponse(emoji: '🔥', text: "You didn't come this far to only come this far. The moment you want to quit is the moment you need to push harder. Don't give up now."),
      AiResponse(emoji: '💪', text: "Quitting is permanent. Pain is temporary. Ten years from now, you'll wish you had kept going today. Don't let future-you down."),
      AiResponse(emoji: '👑', text: "The only way to guarantee failure is to quit. Every obstacle is a test of how badly you want it. How badly do you want it? Prove it."),
    ],
    'money': [
      AiResponse(emoji: '💰', text: "Money follows value. Create so much value that the universe has no choice but to reward you. Sharpen your skills, serve people, and the money comes."),
      AiResponse(emoji: '🚀', text: "Stop trading time for money — start building systems. The wealthy build machines that work while they sleep. Start building, not just earning."),
      AiResponse(emoji: '👑', text: "Financial freedom isn't about luck — it's about daily decisions. Every dollar you save, every skill you learn, every network you build gets you closer. Work smarter."),
    ],
    'lonely': [
      AiResponse(emoji: '🌅', text: "Loneliness is the universe pushing you inward — to discover who you really are. The greatest self-discoveries happen in solitude. Use this time."),
      AiResponse(emoji: '🔥', text: "You are never truly alone. Billions of people have walked your exact path and made it through. Your tribe is out there — keep building yourself and you'll find them."),
      AiResponse(emoji: '💎', text: "Being alone and being lonely are different things. Use your solitude to level up. Read, learn, grow. When you become who you're meant to be, connection finds you."),
    ],
    'default': [
      AiResponse(emoji: '🔥', text: "Every single day is a new chance to become the person you've always wanted to be. Don't waste today being who you were yesterday. Level up."),
      AiResponse(emoji: '💪', text: "The version of you that's reading this right now is not the final version. Keep going. Keep growing. The best is yet to come."),
      AiResponse(emoji: '⚡', text: "Stop waiting for permission. Stop waiting for the right time. The right time is now. You have everything you need to start. Begin."),
      AiResponse(emoji: '👑', text: "Discipline is choosing between what you want now and what you want most. Choose wisely. Your future self is watching every decision you make today."),
      AiResponse(emoji: '🌅', text: "You are one decision away from a completely different life. Make that decision. Take that step. Your entire trajectory can change today."),
      AiResponse(emoji: '🏆', text: "Hard work beats talent when talent doesn't work hard. Whatever you lack in gifts, make up for in relentless effort. Nobody outworks the obsessed."),
    ],
  };

  /// Phrases that mean the person may be in crisis. Checked before the keyword
  /// match so "I want to give up on life" never gets a "don't quit, prove it"
  /// reply — the offline path has no model to read the room, so it has to be
  /// told. Mirrors the crisis paragraph in [_systemPrompt].
  static const _crisisPhrases = [
    'suicide', 'suicidal', 'kill myself', 'killing myself', 'end my life',
    'end it all', 'want to die', 'wanna die', 'better off dead',
    'no reason to live', 'self harm', 'self-harm', 'hurt myself',
    'hurting myself', 'cut myself', 'cutting myself', 'abuse', 'abusing me',
    'hits me', 'beats me', 'raped',
  ];

  static const _crisisResponse = AiResponse(
    emoji: '💙',
    text: "I'm really glad you told me, and I'm taking this seriously. What you're "
        "going through deserves real support, more than an app can give. Please "
        "reach out to someone you trust, or contact a local crisis line now — you "
        "can find one for your country at findahelpline.com. If you're in danger, "
        "call your local emergency number. You don't have to carry this alone.",
  );

  /// Offline reply: keyword match over the canned responses above.
  ///
  /// Used when the app has no proxy or key configured, and as the fallback
  /// whenever a live request fails.
  AiResponse respond(String input) {
    final lower = input.toLowerCase();
    if (_crisisPhrases.any(lower.contains)) return _crisisResponse;
    for (final key in _responses.keys) {
      if (key == 'default') continue;
      if (lower.contains(key)) {
        final list = _responses[key]!;
        return list[_rng.nextInt(list.length)];
      }
    }
    final list = _responses['default']!;
    return list[_rng.nextInt(list.length)];
  }
}
