import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile Picture and Experience Points
              _buildProfileSection(context),
              const SizedBox(height: 40),

              // Achievement Button
              _buildAchievementButton(),
              const SizedBox(height: 40),

              // Menu Options
              _buildMenuOptions(context),
              const SizedBox(height: 40),

              // Logout Option
              _buildLogoutOption(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final ringSize = isTablet ? 160.0 : 140.0;
    final pictureSize = isTablet ? 140.0 : 120.0;
    final badgeSize = isTablet ? 18.0 : 16.0;

    return Column(
      children: [
        // Profile Picture with Golden Ring and Badge
        Stack(
          alignment: Alignment.center,
          children: [
            // Golden Ring
            Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.yellow.shade600, width: 4),
              ),
            ),

            // Profile Picture
            Container(
              width: pictureSize,
              height: pictureSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(pictureSize / 2),
                child: Image.asset(
                  'assets/images/profile_avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow.shade700,
                      ),
                      child: Center(
                        child: Text(
                          user.name?.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: isTablet ? 56 : 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Best Badge
            Positioned(
              bottom: 10,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 14 : 12,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.yellow.shade600, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: badgeSize),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      'BEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Experience Points
        Text(
          '1,200',
          style: TextStyle(
            fontSize: isTablet ? 42 : 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        Text(
          'experience Points',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            // TODO: Navigate to achievements screen
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Go To Achievement',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Personal Details',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personal Details coming soon!')),
          );
        },
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Notification settings',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification settings coming soon!')),
          );
        },
      },
      {
        'icon': Icons.lock_outline,
        'title': 'Change Password',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Change Password coming soon!')),
          );
        },
      },
      {
        'icon': Icons.chat_outlined,
        'title': 'Chat with Admin',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat with Admin coming soon!')),
          );
        },
      },
      {
        'icon': Icons.help_outline,
        'title': 'FAQ',
        'onTap': () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('FAQ coming soon!')));
        },
      },
    ];

    return Column(
      children: menuItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: item['onTap'] as VoidCallback,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: Colors.grey.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogoutOption(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showLogoutDialog(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.power_settings_new,
                  color: Colors.red.shade600,
                  size: 24,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
