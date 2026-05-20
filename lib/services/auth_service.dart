import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase auth is wired up — enable after registering com.ayoub.motivate_me in Firebase console
// import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  const AuthUser({required this.email, required this.displayName});
  final String email;
  final String displayName;
}

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();
  AuthService._();

  AuthUser? _user;

  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;
  String get displayName => _user?.displayName ?? '';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('auth_email');
    final name  = prefs.getString('auth_name');
    if (email != null && name != null) {
      _user = AuthUser(email: email, displayName: name);
      notifyListeners();
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) return 'Please fill in all fields.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_email', email.trim());
    await prefs.setString('auth_name', name.trim());
    _user = AuthUser(email: email.trim(), displayName: name.trim());
    notifyListeners();
    return null;
  }

  Future<String?> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return 'Please fill in all fields.';
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auth_email');
    if (saved != email.trim()) return 'No account found with this email.';
    final name = prefs.getString('auth_name') ?? email.split('@').first;
    _user = AuthUser(email: email.trim(), displayName: name);
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_email');
    await prefs.remove('auth_name');
    _user = null;
    notifyListeners();
  }
}
