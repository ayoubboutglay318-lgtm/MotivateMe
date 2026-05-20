import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final name     = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final err = _isLogin
        ? await AuthService.instance.signIn(email, password)
        : await AuthService.instance.signUp(email, password, name);

    if (mounted) setState(() { _loading = false; _error = err; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182035),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text('🔥', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 12),
                Text('MotivateMe',
                    style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Your daily dose of inspiration',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
                const SizedBox(height: 40),

                // Tab toggle
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2C42),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2A3D5A)),
                  ),
                  child: Row(
                    children: [
                      _Tab('Sign In',  selected: _isLogin,  onTap: () => setState(() { _isLogin = true;  _error = null; })),
                      _Tab('Sign Up', selected: !_isLogin, onTap: () => setState(() { _isLogin = false; _error = null; })),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Fields
                if (!_isLogin) ...[
                  _Field(controller: _nameCtrl, hint: 'Your name', icon: Icons.person_outline),
                  const SizedBox(height: 14),
                ],
                _Field(controller: _emailCtrl, hint: 'Email', icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _Field(controller: _passwordCtrl, hint: 'Password', icon: Icons.lock_outline,
                    obscure: true),
                const SizedBox(height: 8),

                // Error
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center),
                  ),

                const SizedBox(height: 16),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : Text(_isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 24),

                // Skip
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Continue without account',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.label, {required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFD700) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white38,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              )),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboard = TextInputType.text,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF1E2C42),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A3D5A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A3D5A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFFD700)),
        ),
      ),
    );
  }
}
