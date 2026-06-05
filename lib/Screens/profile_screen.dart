import 'package:e_commerce/Screens/Auth/login_screen.dart';
import 'package:e_commerce/Screens/home_screen.dart';
import 'package:e_commerce/Screens/refer_code.dart';
import 'package:e_commerce/Screens/whichlist/screen/whichlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../Services/Providers/profile_provider.dart';
import '../UI/Widgets/Organisms/profile/menu_section.dart';
import '../UI/Widgets/Organisms/profile/profile_header.dart';
import '../app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrangeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileHeader(),
            MenuSection(
              items: [
                MenuItemData(
                  icon: Icons.home_outlined,
                  iconColor: AppColors.primaryOrangeColor.shade400,
                  title: 'Home',
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
                MenuItemData(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: AppColors.primaryOrangeColor.shade600,
                  title: 'My Orders',
                  onTap: () {
                    Navigator.pushNamed(context, '/orders');
                  },
                ),
                MenuItemData(
                  icon: Icons.favorite_border_rounded,
                  iconColor: Colors.red,
                  title: 'My Wishlist',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WishlistScreen())),
                ),
              ],
            ),
            MenuSection(
              items: [
                MenuItemData(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.primaryOrangeColor.shade700,
                  title: 'My Address',
                  onTap: () {
                    Navigator.pushNamed(context, '/AddAddress');
                  },
                ),
                MenuItemData(
                  icon: Icons.card_giftcard_rounded,
                  iconColor: AppColors.primaryOrangeColor,
                  title: 'Refer & Earn',
                  onTap: () {
                    showReferBottomSheet(context);
                  },
                ),
                MenuItemData(
                  icon: Icons.logout,
                  iconColor: AppColors.redAccentColor,
                  title: 'Log out',
                  onTap: () => _logout(context),
                ),
              ],
            ),
            MenuSection(
              items: [
                MenuItemData(
                  icon: Icons.info_outline,
                  iconColor: AppColors.primaryOrangeColor.shade600,
                  title: 'About Us',
                  onTap: () {
                    Navigator.pushNamed(context, '/app/about');
                  },
                ),
                MenuItemData(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.primaryOrangeColor.shade300,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.pushNamed(context, '/app/tearms');
                  },
                ),
                MenuItemData(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.grey.shade600,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.pushNamed(context, '/app/privacy');
                  },
                ),
                MenuItemData(
                  icon: Icons.share_outlined,
                  iconColor: AppColors.primaryOrangeColor.shade400,
                  title: 'Share App',
                  onTap: () => _shareApp(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                if (profileProvider.isLoggedIn) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.redAccentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.redAccentColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.my_location,
                color: AppColors.primaryOrangeColor,
              ),
              title: const Text('Use Current Location'),
              onTap: () {
                context
                    .read<ProfileProvider>()
                    .updateLocation('Current Location');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Location updated'),
                    backgroundColor: AppColors.primaryOrangeColor,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.search,
                color: AppColors.primaryOrangeColor,
              ),
              title: const Text('Search Location'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: AppColors.primaryOrangeColor,
              ),
              title: const Text('Call Us'),
              subtitle: const Text('+91 1800 XXX XXXX'),
              onTap: () => _makePhoneCall('+911800XXXXXX'),
            ),
            ListTile(
              leading: Icon(
                Icons.email,
                color: AppColors.primaryOrangeColor,
              ),
              title: const Text('Email Us'),
              subtitle: const Text('support@yourapp.com'),
              onTap: () => _sendEmail('support@yourapp.com'),
            ),
            ListTile(
              leading: Icon(
                Icons.chat,
                color: AppColors.primaryOrangeColor,
              ),
              title: const Text('Chat Support'),
              subtitle: const Text('Available 24/7'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareApp() {
    Share.share(
      'Check out this amazing app! Download now: https://yourapp.com',
      subject: 'Share App',
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileProvider>().logout();
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAccentColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');

              context.read<ProfileProvider>().logout();

              Navigator.pop(context);

              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAccentColor,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
