import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';

class StoreSettingScreen extends StatelessWidget {
  const StoreSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryIndigoColor.shade700,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryIndigoColor.shade700,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'Store Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Store Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingItem(
                    context,
                    label: 'Store Name',
                    value: 'SuperMart',
                    onTap: () {}, // Add edit/store logic here
                  ),
                  _buildSettingItem(
                    context,
                    label: 'Store Address',
                    value: '123 Market Rd',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    context,
                    label: 'Contact Number',
                    value: '+91 98765 43210',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Store Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    onChanged: (val) {},
                    title: Text(
                      'Online Ordering',
                      style: TextStyle(
                        color: AppColors.primaryIndigoColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: false,
                    onChanged: (val) {},
                    title: Text(
                      'Store Open',
                      style: TextStyle(
                        color: AppColors.primaryIndigoColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context, {
        required String label,
        required String value,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryIndigoColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, color: AppColors.primaryIndigoColor),
          ],
        ),
      ),
    );
  }
}
