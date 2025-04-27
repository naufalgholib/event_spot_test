import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';

class PromotorSettingsScreen extends StatefulWidget {
  const PromotorSettingsScreen({super.key});

  @override
  State<PromotorSettingsScreen> createState() => _PromotorSettingsScreenState();
}

class _PromotorSettingsScreenState extends State<PromotorSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildUserHeader(user),
          const Divider(height: 32),
          _buildSettingsSection('Account Settings', [
            _buildSettingsTile(
              title: 'Edit Profile',
              icon: Icons.person_outline,
              onTap: () {
                Navigator.pushNamed(context, AppRouter.promotorProfile);
              },
            ),
            _buildSettingsTile(
              title: 'Change Password',
              icon: Icons.lock_outline,
              onTap: () {
                // Navigate to change password screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Password change functionality will be implemented'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            _buildSettingsTile(
              title: 'Payment Information',
              icon: Icons.payment_outlined,
              onTap: () {
                // Navigate to payment information screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Payment information functionality will be implemented'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ]),
          const Divider(height: 32),
          _buildSettingsSection('Notification Settings', [
            _buildSwitchTile(
              title: 'Push Notifications',
              icon: Icons.notifications_outlined,
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              title: 'Email Updates',
              icon: Icons.email_outlined,
              value: _emailUpdatesEnabled,
              onChanged: (value) {
                setState(() {
                  _emailUpdatesEnabled = value;
                });
              },
            ),
          ]),
          const Divider(height: 32),
          _buildSettingsSection('App Settings', [
            _buildSwitchTile(
              title: 'Dark Mode',
              icon: Icons.dark_mode_outlined,
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                // TODO: Implement theme switching
              },
            ),
            _buildSettingsTile(
              title: 'Language',
              icon: Icons.language_outlined,
              subtitle: 'English',
              onTap: () {
                // Show language selection dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language selection will be implemented'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ]),
          const Divider(height: 32),
          _buildSettingsSection('Support & About', [
            _buildSettingsTile(
              title: 'Help & Support',
              icon: Icons.help_outline,
              onTap: () {
                Navigator.pushNamed(context, AppRouter.contact);
              },
            ),
            _buildSettingsTile(
              title: 'About',
              icon: Icons.info_outline,
              onTap: () {
                Navigator.pushNamed(context, AppRouter.aboutFAQ);
              },
            ),
            _buildSettingsTile(
              title: 'Terms & Privacy Policy',
              icon: Icons.description_outlined,
              onTap: () {
                // Navigate to terms and privacy policy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Terms and privacy policy will be implemented'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ]),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRouter.login);
              }
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'App Version: 1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserHeader(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          backgroundImage: user.profilePicture != null
              ? NetworkImage(user.profilePicture!) as ImageProvider
              : null,
          child: user.profilePicture == null
              ? const Icon(Icons.business,
                  color: AppTheme.primaryColor, size: 30)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              if (user.promoterDetail?.companyName != null)
                Text(
                  user.promoterDetail!.companyName!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}
