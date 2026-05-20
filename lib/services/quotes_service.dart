import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<Quote> getTodayQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final saved = prefs.getString(_keyDate);

    if (saved == today) {
      final raw = prefs.getString(_keyToday);
      if (raw != null) {
        try {
          return Quote.fromJson(jsonDecode(raw));
        } catch (_) {}
      }
    }

    final quote = await _fetchFromApi() ?? _randomFallback();
    await prefs.setString(_keyDate, today);
    await prefs.setString(_keyToday, jsonEncode(quote.toJson()));
    return quote;
  }

  Future<Quote> refreshQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final quote = await _fetchFromApi() ?? _randomFallback();
    await prefs.setString(_keyDate, _dateKey(DateTime.now()));
    await prefs.setString(_keyToday, jsonEncode(quote.toJson()));
    return quote;
  }

  Future<Quote?> _fetchFromApi() async {
    try {
      final res = await http
          .get(Uri.parse('https://zenquotes.io/api/random'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        if (data.isNotEmpty) {
          final q = data[0] as Map<String, dynamic>;
          final text = q['q']?.toString() ?? '';
          final author = q['a']?.toString() ?? '';
          if (text.isNotEmpty) return Quote(text: text, author: author);
        }
      }
    } catch (_) {}
    return null;
  }

  Quote _randomFallback({bool sigma = false}) {
    if (sigma) return _sigmaFallback[Random().nextInt(_sigmaFallback.length)];
    return _fallback[Random().nextInt(_fallback.length)];
  }

  static String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
