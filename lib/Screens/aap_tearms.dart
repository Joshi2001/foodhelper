import 'package:flutter/material.dart';

class Tearms extends StatelessWidget {
  const Tearms({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            _SectionTitle('Welcome'),
            _SectionText(
              'Welcome to our grocery app. By accessing or using this app, '
              'you agree to comply with and be bound by the following terms and conditions.',
            ),

            SizedBox(height: 16),

            _SectionTitle('1. Account Registration'),
            _SectionText(
              'You must provide accurate and complete information while creating an account. '
              'You are responsible for maintaining the confidentiality of your login credentials.',
            ),

            SizedBox(height: 16),

            _SectionTitle('2. Orders & Payments'),
            _SectionText(
              'All orders placed through the app are subject to availability. '
              'Prices may change without prior notice. Payments must be completed '
              'before the order is processed.',
            ),

            SizedBox(height: 16),

            _SectionTitle('3. Delivery'),
            _SectionText(
              'We aim to deliver your groceries within the estimated time. '
              'However, delays may occur due to traffic, weather, or unforeseen circumstances.',
            ),

            SizedBox(height: 16),

            _SectionTitle('4. Returns & Refunds'),
            _SectionText(
              'Returns or refunds are applicable only for damaged, expired, or incorrect items. '
              'Please report issues within the specified time after delivery.',
            ),

            SizedBox(height: 16),

            _SectionTitle('5. User Conduct'),
            _SectionText(
              'You agree not to misuse the app, attempt unauthorized access, '
              'or engage in activities that disrupt app services.',
            ),

            SizedBox(height: 16),

            _SectionTitle('6. Privacy Policy'),
            _SectionText(
              'Your personal information is handled according to our Privacy Policy. '
              'We do not sell your data to third parties.',
            ),

            SizedBox(height: 16),

            _SectionTitle('7. Changes to Terms'),
            _SectionText(
              'We may update these Terms & Conditions from time to time. '
              'Continued use of the app means you accept the revised terms.',
            ),

            SizedBox(height: 24),

            Center(
              child: Text(
                'Thank you for choosing our app!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Section Title Widget
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 🔹 Section Text Widget
class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }
}
