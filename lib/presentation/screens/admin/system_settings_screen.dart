import 'package:flutter/material.dart';
import 'package:event_spot/core/theme/app_theme.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controller for text fields
  final TextEditingController _maxEventsPerUserController =
      TextEditingController(text: '10');
  final TextEditingController _maxRegistrationsPerEventController =
      TextEditingController(text: '500');
  final TextEditingController _maxImagesPerEventController =
      TextEditingController(text: '5');
  final TextEditingController _maxFileSizeController =
      TextEditingController(text: '5');
  final TextEditingController _platformFeeController =
      TextEditingController(text: '2.5');

  // Toggle switches
  bool _allowUserRegistration = true;
  bool _allowEventCreation = true;
  bool _moderateEvents = false;
  bool _moderateComments = true;
  bool _enableNotifications = true;
  bool _enableAiFeatures = true;
  bool _maintenanceMode = false;

  @override
  void dispose() {
    _maxEventsPerUserController.dispose();
    _maxRegistrationsPerEventController.dispose();
    _maxImagesPerEventController.dispose();
    _maxFileSizeController.dispose();
    _platformFeeController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('General Settings'),
                    const SizedBox(height: 16),
                    _buildSwitchSetting(
                      'Allow User Registration',
                      'Enable or disable new user registrations',
                      _allowUserRegistration,
                      (value) {
                        setState(() {
                          _allowUserRegistration = value;
                        });
                      },
                    ),
                    _buildSwitchSetting(
                      'Allow Event Creation',
                      'Enable or disable event creation by promoters',
                      _allowEventCreation,
                      (value) {
                        setState(() {
                          _allowEventCreation = value;
                        });
                      },
                    ),
                    _buildSwitchSetting(
                      'Maintenance Mode',
                      'Put the site in maintenance mode - only admins can access',
                      _maintenanceMode,
                      (value) {
                        setState(() {
                          _maintenanceMode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Content Moderation'),
                    const SizedBox(height: 16),
                    _buildSwitchSetting(
                      'Moderate Events',
                      'Require admin approval for new events',
                      _moderateEvents,
                      (value) {
                        setState(() {
                          _moderateEvents = value;
                        });
                      },
                    ),
                    _buildSwitchSetting(
                      'Moderate Comments',
                      'Enable comment moderation on event pages',
                      _moderateComments,
                      (value) {
                        setState(() {
                          _moderateComments = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Platform Limits'),
                    const SizedBox(height: 16),
                    _buildNumberField(
                      'Max Events per User',
                      'Maximum number of events a promoter can create',
                      _maxEventsPerUserController,
                    ),
                    const SizedBox(height: 16),
                    _buildNumberField(
                      'Max Registrations per Event',
                      'Maximum number of registrations allowed per event',
                      _maxRegistrationsPerEventController,
                    ),
                    const SizedBox(height: 16),
                    _buildNumberField(
                      'Max Images per Event',
                      'Maximum number of images allowed per event',
                      _maxImagesPerEventController,
                    ),
                    const SizedBox(height: 16),
                    _buildNumberField(
                      'Max File Size (MB)',
                      'Maximum file size for image uploads in MB',
                      _maxFileSizeController,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Payments & Fees'),
                    const SizedBox(height: 16),
                    _buildNumberField(
                      'Platform Fee (%)',
                      'Platform fee percentage for paid events',
                      _platformFeeController,
                      isDecimal: true,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Features'),
                    const SizedBox(height: 16),
                    _buildSwitchSetting(
                      'Notifications',
                      'Enable system notifications',
                      _enableNotifications,
                      (value) {
                        setState(() {
                          _enableNotifications = value;
                        });
                      },
                    ),
                    _buildSwitchSetting(
                      'AI Features',
                      'Enable AI-powered features like description generation',
                      _enableAiFeatures,
                      (value) {
                        setState(() {
                          _enableAiFeatures = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Save Settings',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Show reset confirmation dialog
                          _showResetConfirmationDialog();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text(
                          'Reset to Defaults',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (isDecimal) {
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
        } else {
          if (int.tryParse(value) == null) {
            return 'Please enter a valid integer';
          }
        }
        return null;
      },
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetToDefaults();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _maxEventsPerUserController.text = '10';
      _maxRegistrationsPerEventController.text = '500';
      _maxImagesPerEventController.text = '5';
      _maxFileSizeController.text = '5';
      _platformFeeController.text = '2.5';

      _allowUserRegistration = true;
      _allowEventCreation = true;
      _moderateEvents = false;
      _moderateComments = true;
      _enableNotifications = true;
      _enableAiFeatures = true;
      _maintenanceMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset to defaults'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
