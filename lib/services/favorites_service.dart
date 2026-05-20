import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quotes_service.dart';

class FavoritesService extends ChangeNotifier {
  static const _key = 'favorite_quotes';
  final List<Quote> _favorites = [];

  List<Quote> get favorites => List.unmodifiable(_favorites.reversed);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _favorites.clear();
        for (final item in list) {
          _favorites.add(Quote.fromJson(Map<String, dynamic>.from(item as Map)));
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  bool isFavorite(Quote q) => _favorites.any((f) => f.text == q.text);

  Future<void> toggle(Quote q) async {
    if (isFavorite(q)) {
      _favorites.removeWhere((f) => f.text == q.text);
    } else {
      _favorites.add(q);
    }
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_favorites.map((q) => q.toJson()).toList()));
  }
}
