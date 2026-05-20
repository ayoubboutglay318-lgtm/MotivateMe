import 'dart:math';

class AiResponse {
  const AiResponse({required this.text, required this.emoji});
  final String text;
  final String emoji;
}

class AiService {
  static final AiService instance = AiService._();
  AiService._();

  final _rng = Random();

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

  AiResponse respond(String input) {
    final lower = input.toLowerCase();
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
