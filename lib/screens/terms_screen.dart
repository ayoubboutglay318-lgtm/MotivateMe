import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C15),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080C15),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Terms of Use',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Terms of Use', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Last updated: May 2025', style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 28),
          ..._sections.map((s) => _Section(title: s.$1, body: s.$2)),
        ],
      ),
    );
  }
}

const _sections = [
  (
    'Acceptance of Terms',
    'By downloading or using MotivateMe, you agree to these Terms of Use. If you do not agree, do not use the app.',
  ),
  (
    'Use of the App',
    'MotivateMe is a personal motivation and habit-tracking application. You may use it for personal, non-commercial purposes only. You agree not to misuse the app or attempt to access it using a method other than the interface and instructions we provide.',
  ),
  (
    'User Content',
    'Any content you create within the app (goals, notes, wins) is stored locally on your device. We do not access, collect, or share your personal content.',
  ),
  (
    'Intellectual Property',
    'All content, design, and code within MotivateMe are the property of the developer. You may not copy, modify, or distribute any part of the app without explicit written permission.',
  ),
  (
    'Disclaimer of Warranties',
    'MotivateMe is provided "as is" without warranties of any kind. We do not guarantee that the app will always be available, error-free, or meet your specific requirements.',
  ),
  (
    'Limitation of Liability',
    'To the maximum extent permitted by law, the developer shall not be liable for any indirect, incidental, or consequential damages arising from your use of MotivateMe.',
  ),
  (
    'Changes to Terms',
    'We may update these terms from time to time. Continued use of the app after changes constitutes your acceptance of the new terms.',
  ),
  (
    'Contact',
    'If you have questions about these terms, contact us at ayoubboutglay318@gmail.com.',
  ),
];

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.inter(
                color: const Color(0xFFFFD700), fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 8),
        Text(body,
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.65)),
      ]),
    );
  }
}
