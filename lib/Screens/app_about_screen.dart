import 'package:flutter/material.dart';
import '../constants.dart';

class AppAboutScreen extends StatelessWidget {
  const AppAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildAboutCard(),
            const SizedBox(height: 16),
            _buildFeaturesCard(),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.local_grocery_store,
            size: 48,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'GrocerEase',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Version 15.30.2',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ================= ABOUT CARD =================
  Widget _buildAboutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About GrocerEase',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              introParagraph,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FEATURES =================
  Widget _buildFeaturesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why Choose Us?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            _FeatureTile(
              icon: Icons.timer,
              text: '10–15 minute delivery',
            ),
            _FeatureTile(
              icon: Icons.local_offer,
              text: 'Best prices & daily offers',
            ),
            _FeatureTile(
              icon: Icons.verified,
              text: 'Fresh & quality products',
            ),
            _FeatureTile(
              icon: Icons.support_agent,
              text: '24/7 customer support',
            ),
          ],
        ),
      ),
    );
  }

  // ================= FOOTER =================
  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          '© 2026 GrocerEase',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        const Text(
          'Made with ❤️ in India',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// ================= FEATURE TILE =================
class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureTile({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// import '../constants.dart';

// class AppAboutScreen extends StatelessWidget {
//   const AppAboutScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('About Us'),
//       ),
//       body: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 8,
//           vertical: 10,
//         ),
//         child: ListView(
//           // crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text(
//               'About us',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Text(
//               'v15.30.2',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w200,
//               ),
//             ),
//             Text(introParagraph)
//           ],
//         ),
//       ),
//     );
//   }
// }
