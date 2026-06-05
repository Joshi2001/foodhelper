import 'package:flutter/material.dart';
class HomeScreenAppBar extends StatelessWidget {
  const HomeScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 110,
      collapsedHeight: 110,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF9C4),
              Color(0xFFFFFDE7),
              Colors.white,     
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // AKB Logo replacement text
                    const Text(
                      "akb",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A3D7C), // Dark Blue logo color
                          fontStyle: FontStyle.italic
                      ),
                    ),
                    // Profile Icon exactly like image
                    IconButton(
                      icon: const Icon(Icons.person, color: Color(0xFF2C3E50), size: 30),
                      onPressed: () => Navigator.of(context).pushNamed('/profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Location Selection Row (Image details: Not serviceable, address, etc.)
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.red, size: 8),
                    const SizedBox(width: 8),
                    const Text(
                      "Not serviceable",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3D7C)),
                    ),
                  ],
                ),
                const Text(
                  "Our team is working to reach you soon",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: const [
                    Text(
                      "SCO-12, A-Block, 2nd Floor, VIP Rd, Zirakp...",
                      style: TextStyle(fontSize: 14, color: Color(0xFF1A3D7C), fontWeight: FontWeight.w500),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A3D7C)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}