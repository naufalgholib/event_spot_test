import 'package:flutter/material.dart';
import '../../core/config/app_router.dart';
import '../widgets/common_widgets.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _eventReminders = true;
  bool _promotionalEmails = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';
  bool _locationServices = true;

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  final List<String> _themes = ['System', 'Light', 'Dark'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection('Account', [
            _buildListTile(
              'Edit Profile',
              Icons.person,
              onTap: () {
                // TODO: Navigate to profile edit screen
              },
            ),
            _buildListTile(
              'Change Password',
              Icons.lock,
              onTap: () {
                // TODO: Navigate to change password screen
              },
            ),
            _buildListTile(
              'Privacy Settings',
              Icons.privacy_tip,
              onTap: () {
                // TODO: Navigate to privacy settings screen
              },
            ),
          ]),
          _buildSection('Notifications', [
            _buildSwitchTile(
              'Email Notifications',
              'Receive notifications via email',
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
            ),
            _buildSwitchTile(
              'Push Notifications',
              'Receive push notifications',
              _pushNotifications,
              (value) => setState(() => _pushNotifications = value),
            ),
            _buildSwitchTile(
              'Event Reminders',
              'Get reminded about upcoming events',
              _eventReminders,
              (value) => setState(() => _eventReminders = value),
            ),
            _buildSwitchTile(
              'Promotional Emails',
              'Receive offers and promotions',
              _promotionalEmails,
              (value) => setState(() => _promotionalEmails = value),
            ),
          ]),
          _buildSection('Preferences', [
            _buildDropdownTile(
              'Language',
              _selectedLanguage,
              _languages,
              (value) => setState(() => _selectedLanguage = value!),
            ),
            _buildDropdownTile(
              'Theme',
              _selectedTheme,
              _themes,
              (value) => setState(() => _selectedTheme = value!),
            ),
            _buildSwitchTile(
              'Location Services',
              'Allow app to access your location',
              _locationServices,
              (value) => setState(() => _locationServices = value),
            ),
          ]),
          _buildSection('Support', [
            _buildListTile(
              'Help Center',
              Icons.help,
              onTap: () {
                // TODO: Navigate to help center
              },
            ),
            _buildListTile(
              'Contact Support',
              Icons.support_agent,
              onTap: () {
                // TODO: Navigate to contact support
              },
            ),
            _buildListTile(
              'Terms of Service',
              Icons.description,
              onTap: () {
                // TODO: Navigate to terms of service
              },
            ),
            _buildListTile(
              'Privacy Policy',
              Icons.policy,
              onTap: () {
                // TODO: Navigate to privacy policy
              },
            ),
          ]),
          _buildSection('Danger Zone', [
            _buildListTile(
              'Delete Account',
              Icons.delete_forever,
              textColor: Colors.red,
              onTap: () {
                // TODO: Show delete account confirmation
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon, {
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
