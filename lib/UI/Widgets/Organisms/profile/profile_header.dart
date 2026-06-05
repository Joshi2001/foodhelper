import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Services/Providers/profile_provider.dart';
import '../../../../app_colors.dart';


class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryOrangeColor, // ✅ UPDATED
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: profileProvider.profileImage.isEmpty
                      ? Container(
                    color: AppColors.primaryOrangeColor.shade50, // ✅ UPDATED
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primaryOrangeColor, // ✅ UPDATED
                    ),
                  )
                      : Image.network(
                    profileProvider.profileImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primaryOrangeColor.shade50, // ✅ UPDATED
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primaryOrangeColor, // ✅ UPDATED
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profileProvider.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profileProvider.userEmail.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        profileProvider.userEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Edit button
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit-profile');
                },
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primaryOrangeColor, // ✅ UPDATED
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
