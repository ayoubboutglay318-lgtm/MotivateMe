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
          Text('Last updated: November 2026',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 24),
          _Section(
            title: 'No Account Needed',
            body: 'Motivate Me does not ask you to create an account and does not collect your name, '
                'email address, or any other contact details.',
          ),
          _Section(
            title: 'Data Stored on Your Device',
            body: 'Your streak, favorite quotes, goals, wins, challenge progress, and settings are stored '
                'only on your device. They are never uploaded to us. Uninstalling the app deletes all of it.',
          ),
          _Section(
            title: 'AI Coach',
            body: 'When you chat with the AI Coach, the messages in that conversation are sent to our AI '
                'provider (Anthropic) to generate a reply. They are not linked to your identity, and we do '
                'not use them for advertising. Do not share sensitive personal information in the chat. '
                'If the AI Coach is offline, replies are generated on your device and nothing is sent.',
          ),
          _Section(
            title: 'Content Downloads',
            body: 'The app downloads quotes from ZenQuotes and background photos from Unsplash. These '
                'requests contain no personal data, but like any web request they reveal your IP address '
                'to those services.',
          ),
          _Section(
            title: 'Notifications',
            body: 'If you enable reminders, the app schedules local notifications on your device. '
                'No notification data is sent to any server.',
          ),
          _Section(
            title: 'No Tracking',
            body: 'The app contains no analytics, advertising, or tracking libraries, and we do not sell '
                'or share your data with anyone.',
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
