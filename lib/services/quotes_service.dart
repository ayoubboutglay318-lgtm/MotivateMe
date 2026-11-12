import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'sigma_service.dart';

class Quote {
  const Quote({required this.text, required this.author});
  final String text;
  final String author;

  Map<String, dynamic> toJson() => {'text': text, 'author': author};
  static Quote fromJson(Map<String, dynamic> j) =>
      Quote(text: j['text'] ?? '', author: j['author'] ?? '');
}

class QuotesService {
  static const _keyToday = 'quote_today';
  static const _keyDate = 'quote_date';

  static const _sigmaFallback = [
    Quote(text: "Stay silent. Let your success make the noise.", author: "Sigma Rule"),
    Quote(text: "A lion doesn't concern himself with the opinions of sheep.", author: "Sigma Mindset"),
    Quote(text: "Work in silence. Let success be your noise.", author: "Sigma Rule"),
    Quote(text: "Discipline is doing it when you don't feel like it.", author: "No Excuses"),
    Quote(text: "The grind never stops. Only weak men take unearned breaks.", author: "Sigma Rule"),
    Quote(text: "Your comfort zone is your prison. Break out.", author: "No Excuses"),
    Quote(text: "Stop making excuses. Start making moves.", author: "Sigma Mindset"),
    Quote(text: "Wake up. Grind. Repeat. No days off.", author: "Discipline Code"),
    Quote(text: "Pain is temporary. Results are permanent.", author: "Sigma Rule"),
    Quote(text: "The wolf doesn't wait. The wolf hunts.", author: "Sigma Mindset"),
    Quote(text: "Nobody is coming to save you. Save yourself.", author: "Sigma Rule"),
    Quote(text: "Your future self is watching your choices right now.", author: "No Excuses"),
    Quote(text: "Average is a choice. You choose it every time you don't give extra.", author: "Discipline Code"),
    Quote(text: "They sleep. You grind. They wonder. You know.", author: "Sigma Mindset"),
    Quote(text: "A real man builds in silence and reveals in results.", author: "Sigma Rule"),
    Quote(text: "You will never always be motivated. Learn to be disciplined.", author: "No Excuses"),
    Quote(text: "Every second you rest, someone else is getting ahead.", author: "Discipline Code"),
    Quote(text: "Be the hardest worker in the room. Every room.", author: "Sigma Rule"),
    Quote(text: "Your doubts are lies. Your potential is truth.", author: "Sigma Mindset"),
    Quote(text: "Iron sharpens iron. Surround yourself with lions.", author: "Sigma Rule"),
  ];

  static const _fallback = [
    Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
    Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
    Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius"),
    Quote(text: "Everything you've ever wanted is on the other side of fear.", author: "George Addair"),
    Quote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill"),
    Quote(text: "Hardships often prepare ordinary people for an extraordinary destiny.", author: "C.S. Lewis"),
    Quote(text: "You are never too old to set another goal or to dream a new dream.", author: "C.S. Lewis"),
    Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
    Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson"),
    Quote(text: "Keep your face always toward the sunshine, and shadows will fall behind you.", author: "Walt Whitman"),
    Quote(text: "In the middle of every difficulty lies opportunity.", author: "Albert Einstein"),
    Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
    Quote(text: "You miss 100% of the shots you don't take.", author: "Wayne Gretzky"),
    Quote(text: "Whether you think you can or you think you can't, you're right.", author: "Henry Ford"),
    Quote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
    Quote(text: "An unexamined life is not worth living.", author: "Socrates"),
    Quote(text: "Spread love everywhere you go. Let no one ever come to you without leaving happier.", author: "Mother Teresa"),
    Quote(text: "When you reach the end of your rope, tie a knot in it and hang on.", author: "Franklin D. Roosevelt"),
    Quote(text: "Always remember that you are absolutely unique. Just like everyone else.", author: "Margaret Mead"),
    Quote(text: "Do not go where the path may lead, go instead where there is no path and leave a trail.", author: "Ralph Waldo Emerson"),
    Quote(text: "I have not failed. I've just found 10,000 ways that won't work.", author: "Thomas Edison"),
    Quote(text: "It always seems impossible until it's done.", author: "Nelson Mandela"),
    Quote(text: "Act as if what you do makes a difference. It does.", author: "William James"),
    Quote(text: "Success is walking from failure to failure with no loss of enthusiasm.", author: "Winston Churchill"),
    Quote(text: "What lies behind us and what lies before us are tiny matters compared to what lies within us.", author: "Ralph Waldo Emerson"),
    Quote(text: "When everything seems to be going against you, remember that the airplane takes off against the wind.", author: "Henry Ford"),
    Quote(text: "Too many of us are not living our dreams because we are living our fears.", author: "Les Brown"),
    Quote(text: "I find that the harder I work, the more luck I seem to have.", author: "Thomas Jefferson"),
    Quote(text: "The only place where success comes before work is in the dictionary.", author: "Vidal Sassoon"),
    Quote(text: "I never dreamed about success. I worked for it.", author: "Estée Lauder"),
    Quote(text: "Don't be pushed around by the fears in your mind. Be led by the dreams in your heart.", author: "Roy T. Bennett"),
    Quote(text: "You don't have to be great to start, but you have to start to be great.", author: "Zig Ziglar"),
    Quote(text: "Tough times never last, but tough people do.", author: "Robert H. Schuller"),
    Quote(text: "Opportunities don't happen. You create them.", author: "Chris Grosser"),
    Quote(text: "Great minds discuss ideas; average minds discuss events; small minds discuss people.", author: "Eleanor Roosevelt"),
    Quote(text: "If you are not willing to risk the usual, you will have to settle for the ordinary.", author: "Jim Rohn"),
    Quote(text: "All our dreams can come true, if we have the courage to pursue them.", author: "Walt Disney"),
    Quote(text: "The road to success and the road to failure are almost exactly the same.", author: "Colin R. Davis"),
    Quote(text: "Perseverance is failing 19 times and succeeding the 20th.", author: "Julie Andrews"),
    Quote(text: "Life is what happens when you're busy making other plans.", author: "John Lennon"),
    Quote(text: "The only limits you have are the limits you believe.", author: "Wayne Dyer"),
    Quote(text: "Push yourself, because no one else is going to do it for you.", author: "Unknown"),
    Quote(text: "Sometimes you win, sometimes you learn.", author: "John Maxwell"),
    Quote(text: "Dream big. Start small. Act now.", author: "Robin Sharma"),
    Quote(text: "A year from now you may wish you had started today.", author: "Karen Lamb"),
    Quote(text: "If you want to achieve greatness, stop asking for permission.", author: "Unknown"),
    Quote(text: "Work hard in silence; let your success be your noise.", author: "Frank Ocean"),
    Quote(text: "The difference between ordinary and extraordinary is that little extra.", author: "Jimmy Johnson"),
    Quote(text: "Success usually comes to those who are too busy to be looking for it.", author: "Henry David Thoreau"),
    Quote(text: "Don't stop when you're tired. Stop when you're done.", author: "Unknown"),
    Quote(text: "The pain you feel today will be the strength you feel tomorrow.", author: "Unknown"),
    Quote(text: "Wake up with determination. Go to bed with satisfaction.", author: "Unknown"),
    Quote(text: "Do something today that your future self will thank you for.", author: "Sean Patrick Flanery"),
    Quote(text: "Little things make big days.", author: "Unknown"),
    Quote(text: "It's going to be hard, but hard does not mean impossible.", author: "Unknown"),
    Quote(text: "Don't wait for opportunity. Create it.", author: "Unknown"),
  ];

  static const _gym = [
    Quote(text: "The last three or four reps is what makes the muscle grow.", author: "Arnold Schwarzenegger"),
    Quote(text: "I hated every minute of training, but I said, don't quit. Suffer now and live the rest of your life as a champion.", author: "Muhammad Ali"),
    Quote(text: "Hard work beats talent when talent doesn't work hard.", author: "Tim Notke"),
    Quote(text: "Take care of your body. It's the only place you have to live.", author: "Jim Rohn"),
    Quote(text: "Champions keep playing until they get it right.", author: "Billie Jean King"),
    Quote(text: "Don't count the days, make the days count.", author: "Muhammad Ali"),
    Quote(text: "Your body can stand almost anything. It's your mind you have to convince.", author: "Unknown"),
    Quote(text: "It never gets easier. You just get stronger.", author: "Unknown"),
    Quote(text: "Excuses don't build muscle.", author: "Unknown"),
    Quote(text: "One more rep. One more set. One more day.", author: "Unknown"),
    Quote(text: "The body achieves what the mind believes.", author: "Unknown"),
    Quote(text: "Show up on the days you don't feel like it. Those are the days that count.", author: "Unknown"),
    Quote(text: "Strong is earned, never given.", author: "Unknown"),
    Quote(text: "You don't find willpower. You build it, one workout at a time.", author: "Unknown"),
  ];

  static const _study = [
    Quote(text: "Education is the most powerful weapon which you can use to change the world.", author: "Nelson Mandela"),
    Quote(text: "An investment in knowledge pays the best interest.", author: "Benjamin Franklin"),
    Quote(text: "Live as if you were to die tomorrow. Learn as if you were to live forever.", author: "Mahatma Gandhi"),
    Quote(text: "The expert in anything was once a beginner.", author: "Helen Hayes"),
    Quote(text: "The beautiful thing about learning is that nobody can take it away from you.", author: "B.B. King"),
    Quote(text: "There are no shortcuts to any place worth going.", author: "Beverly Sills"),
    Quote(text: "Success is the sum of small efforts, repeated day in and day out.", author: "Robert Collier"),
    Quote(text: "Don't let what you cannot do interfere with what you can do.", author: "John Wooden"),
    Quote(text: "Focus on being productive instead of busy.", author: "Tim Ferriss"),
    Quote(text: "The capacity to learn is a gift; the ability to learn is a skill; the willingness to learn is a choice.", author: "Brian Herbert"),
    Quote(text: "One hour of real focus beats a whole day of distraction.", author: "Unknown"),
    Quote(text: "Phone down. Book open. Future loading.", author: "Unknown"),
    Quote(text: "Understand it today and you won't have to cram it tomorrow.", author: "Unknown"),
  ];

  static const _business = [
    Quote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney"),
    Quote(text: "If you really look closely, most overnight successes took a long time.", author: "Steve Jobs"),
    Quote(text: "Your most unhappy customers are your greatest source of learning.", author: "Bill Gates"),
    Quote(text: "Risk comes from not knowing what you're doing.", author: "Warren Buffett"),
    Quote(text: "Price is what you pay. Value is what you get.", author: "Warren Buffett"),
    Quote(text: "Chase the vision, not the money; the money will end up following you.", author: "Tony Hsieh"),
    Quote(text: "Ideas are easy. Implementation is hard.", author: "Guy Kawasaki"),
    Quote(text: "Done is better than perfect.", author: "Sheryl Sandberg"),
    Quote(text: "The biggest risk is not taking any risk.", author: "Mark Zuckerberg"),
    Quote(text: "Don't be afraid to give up the good to go for the great.", author: "John D. Rockefeller"),
    Quote(text: "Formal education will make you a living; self-education will make you a fortune.", author: "Jim Rohn"),
    Quote(text: "Make every detail perfect and limit the number of details to perfect.", author: "Jack Dorsey"),
    Quote(text: "Ship it, learn from it, make it better.", author: "Unknown"),
  ];

  static const _monk = [
    Quote(text: "Nature does not hurry, yet everything is accomplished.", author: "Lao Tzu"),
    Quote(text: "The journey of a thousand miles begins with one step.", author: "Lao Tzu"),
    Quote(text: "Silence is a source of great strength.", author: "Lao Tzu"),
    Quote(text: "You have power over your mind, not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius"),
    Quote(text: "Waste no more time arguing about what a good man should be. Be one.", author: "Marcus Aurelius"),
    Quote(text: "We suffer more often in imagination than in reality.", author: "Seneca"),
    Quote(text: "Luck is what happens when preparation meets opportunity.", author: "Seneca"),
    Quote(text: "Wherever you are, be all there.", author: "Jim Elliot"),
    Quote(text: "The present moment is filled with joy and happiness. If you are attentive, you will see it.", author: "Thich Nhat Hanh"),
    Quote(text: "Simplicity is the ultimate sophistication.", author: "Leonardo da Vinci"),
    Quote(text: "Quiet the mind, and the soul will speak.", author: "Ma Jaya Sati Bhagavati"),
    Quote(text: "Breathe in calm. Breathe out what you can't control.", author: "Unknown"),
    Quote(text: "Small, steady steps. No rush. No stopping.", author: "Unknown"),
  ];

  static const _keyBatch = 'quote_online_batch';
  static const _keyBatchDate = 'quote_online_batch_date';

  final _rng = Random();
  final List<Quote> _deck = [];
  MotivationMode? _deckMode;
  List<Quote> _online = const [];

  MotivationMode get _mode => SigmaService.instance.mode;

  List<Quote> _pack(MotivationMode mode) => switch (mode) {
        MotivationMode.classic => [..._fallback, ..._online],
        MotivationMode.sigma => _sigmaFallback,
        MotivationMode.gym => _gym,
        MotivationMode.study => _study,
        MotivationMode.business => _business,
        MotivationMode.monk => _monk,
      };

  /// Today's quote for the current motivation mode. Stays the same all day.
  Future<Quote> getTodayQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = _mode;
    final today = '${_dateKey(DateTime.now())}#${mode.index}';

    if (prefs.getString(_keyDate) == today) {
      final raw = prefs.getString(_keyToday);
      if (raw != null) {
        try {
          return Quote.fromJson(jsonDecode(raw));
        } catch (_) {}
      }
    }

    if (mode == MotivationMode.classic) await _loadOnlineBatch(prefs);
    final pack = mode == MotivationMode.classic && _online.isNotEmpty ? _online : _pack(mode);
    final quote = pack[_rng.nextInt(pack.length)];
    await prefs.setString(_keyDate, today);
    await prefs.setString(_keyToday, jsonEncode(quote.toJson()));
    return quote;
  }

  /// Next quote for the swipe feed. Drawn from a shuffled deck so nothing
  /// repeats until every quote in the current mode has been shown. Works
  /// offline and never hits the network per swipe.
  Future<Quote> nextQuote() async {
    final mode = _mode;
    if (_deck.isEmpty || _deckMode != mode) {
      if (mode == MotivationMode.classic) {
        await _loadOnlineBatch(await SharedPreferences.getInstance());
      }
      _deck
        ..clear()
        ..addAll(_pack(mode))
        ..shuffle(_rng);
      _deckMode = mode;
    }
    return _deck.removeLast();
  }

  /// Fetches up to 50 quotes in one request, at most once a day. Per-swipe
  /// requests hit ZenQuotes' rate limit (5 per 30s), which then returns a
  /// "Too many requests" message dressed up as a quote.
  Future<void> _loadOnlineBatch(SharedPreferences prefs) async {
    if (_online.isNotEmpty) return;
    final today = _dateKey(DateTime.now());
    final cached = prefs.getString(_keyBatch);
    if (cached != null) {
      try {
        _online = (jsonDecode(cached) as List)
            .map((e) => Quote.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
      if (_online.isNotEmpty && prefs.getString(_keyBatchDate) == today) return;
    }
    try {
      final res = await http
          .get(Uri.parse('https://zenquotes.io/api/quotes'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return;
      final fetched = (jsonDecode(res.body) as List)
          .whereType<Map<String, dynamic>>()
          .map((q) => Quote(text: q['q']?.toString().trim() ?? '', author: q['a']?.toString().trim() ?? ''))
          .where((q) => q.text.isNotEmpty && !q.author.toLowerCase().contains('zenquotes'))
          .toList();
      if (fetched.isEmpty) return;
      _online = fetched;
      await prefs.setString(_keyBatch, jsonEncode(fetched.map((q) => q.toJson()).toList()));
      await prefs.setString(_keyBatchDate, today);
    } catch (_) {}
  }

  static String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
