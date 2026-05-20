import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF182035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2C42),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Privacy Policy',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Privacy Policy', style: GoogleFonts.playfairDisplay(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Last updated: May 2025',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 24),
          _Section(
            title: 'Information We Collect',
            body: 'MotivateMe stores your name and email address locally on your device when you create an account. '
                'This data never leaves your device and is not transmitted to any server.',
          ),
          _Section(
            title: 'How We Use Your Information',
            body: 'Your information is used solely to personalize your in-app experience '
                '(e.g., displaying your name). We do not sell, share, or transmit your data to third parties.',
          ),
          _Section(
            title: 'Data Storage',
            body: 'All data (account info, streak, goals, challenge progress) is stored locally on your device '
                'using standard device storage. Uninstalling the app removes all stored data.',
          ),
          _Section(
            title: 'Notifications',
            body: 'If you enable daily notifications, the app schedules local notifications on your device. '
                'No notification data is sent to external servers.',
          ),
          _Section(
            title: 'Third-Party Services',
            body: 'The app uses Google Fonts for typography. No personal data is shared with Google Fonts. '
                'No analytics, advertising SDKs, or tracking libraries are used.',
          ),
          _Section(
            title: 'Children\'s Privacy',
            body: 'MotivateMe is not directed at children under 13. We do not knowingly collect personal '
                'information from children.',
          ),
          _Section(
            title: 'Changes to This Policy',
            body: 'We may update this Privacy Policy from time to time. '
                'Continued use of the app after changes means you accept the updated policy.',
          ),
          _Section(
            title: 'Contact',
            body: 'If you have questions about this Privacy Policy, contact us at:\n'
                'ayoubboutglay318@gmail.com',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.inter(
                color: const Color(0xFFFFD700), fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 8),
        Text(body,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.65)),
      ]),
    );
  }
}
