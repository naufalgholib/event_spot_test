import 'package:flutter/material.dart';

class AboutFAQScreen extends StatelessWidget {
  const AboutFAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About & FAQ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildFAQSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Event Spot',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Event Spot is your one-stop platform for discovering, booking, and managing events. '
          'Whether you\'re looking for concerts, workshops, conferences, or social gatherings, '
          'we connect you with the best events in your area.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          'Our Mission',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'To make event discovery and management seamless for everyone, '
          'from event-goers to promoters and organizers.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          'Features',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildFeatureItem(Icons.search, 'Easy Event Discovery'),
        _buildFeatureItem(Icons.bookmark, 'Save Favorite Events'),
        _buildFeatureItem(Icons.payment, 'Secure Payments'),
        _buildFeatureItem(Icons.notifications, 'Event Reminders'),
        _buildFeatureItem(Icons.analytics, 'Event Analytics'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'How do I book an event?',
          'Browse events on the home screen, select an event you\'re interested in, '
              'and click the "Register" button. Follow the registration process and complete the payment if required.',
        ),
        _buildFAQItem(
          'How do I become a promoter?',
          'Click on your profile, select "Become a Promoter", and follow the verification process. '
              'You\'ll need to provide business details and verification documents.',
        ),
        _buildFAQItem(
          'What payment methods are accepted?',
          'We accept various payment methods including credit/debit cards, e-wallets, and bank transfers.',
        ),
        _buildFAQItem(
          'How do I get my event tickets?',
          'After successful registration, your tickets will be available in the "My Events" section. '
              'You can view or download them at any time.',
        ),
        _buildFAQItem(
          'What happens if an event is cancelled?',
          'If an event is cancelled, you will be notified and receive a full refund if you\'ve already paid.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      children: [
        Padding(padding: const EdgeInsets.all(16.0), child: Text(answer)),
      ],
    );
  }
}
