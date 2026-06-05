import 'package:flutter/material.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            _HeaderSection(),

            SizedBox(height: 20),

            _SectionTitle('Your Privacy Matters'),
            _SectionText(
              'We value your trust and are committed to protecting your personal information. '
              'This Privacy Policy explains how we collect, use, and safeguard your data '
              'when you use our grocery app.',
            ),

            SizedBox(height: 16),

            _SectionTitle('1. Information We Collect'),
            _SectionText(
              'We collect information such as your name, email address, phone number, '
              'delivery address, and payment-related details to provide seamless service.',
            ),

            SizedBox(height: 16),

            _SectionTitle('2. How We Use Your Information'),
            _SectionText(
              'Your information helps us process orders, deliver groceries, '
              'improve app functionality, and communicate important updates.',
            ),

            SizedBox(height: 16),

            _SectionTitle('3. Data Security'),
            _SectionText(
              'We implement industry-standard security measures to protect your data '
              'against unauthorized access, alteration, or disclosure.',
            ),

            SizedBox(height: 16),

            _SectionTitle('4. Sharing of Information'),
            _SectionText(
              'We do not sell or rent your personal information. '
              'Data may be shared only with trusted partners for delivery and payment processing.',
            ),

            SizedBox(height: 16),

            _SectionTitle('5. Cookies & Analytics'),
            _SectionText(
              'We may use cookies and analytics tools to understand usage patterns '
              'and enhance user experience.',
            ),

            SizedBox(height: 16),

            _SectionTitle('6. Your Rights'),
            _SectionText(
              'You can access, update, or request deletion of your personal information '
              'by contacting our support team.',
            ),

            SizedBox(height: 24),

            Center(
              child: Text(
                'Last updated: January 2026',
                style: TextStyle(
                  fontSize: 13,
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

/// 🔹 Top Highlight Section
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.privacy_tip_outlined,
            size: 36,
            color: Colors.green,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your data is safe with us. We only collect what is necessary '
              'to provide fast and reliable grocery delivery.',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Section Title
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

/// 🔹 Section Content Text
class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }
}
