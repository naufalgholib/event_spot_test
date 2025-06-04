import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/mock_user_repository.dart';
import '../../widgets/common_widgets.dart';

class PromotorProfileScreen extends StatefulWidget {
  const PromotorProfileScreen({super.key});

  @override
  State<PromotorProfileScreen> createState() => _PromotorProfileScreenState();
}

class _PromotorProfileScreenState extends State<PromotorProfileScreen> {
  final MockUserRepository _userRepository = MockUserRepository();
  bool _isLoading = false;
  bool _isEditing = false;
  String? _error;

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _bioController.text = user.bio ?? '';

      if (user.promoterDetail != null) {
        _companyNameController.text = user.promoterDetail!.companyName ?? '';
        _companyDescriptionController.text =
            user.promoterDetail!.description ?? '';
        _websiteController.text = user.promoterDetail!.website ?? '';

        final socialMedia = user.promoterDetail!.socialMedia;
        if (socialMedia != null) {
          _facebookController.text = socialMedia['facebook'] ?? '';
          _twitterController.text = socialMedia['twitter'] ?? '';
          _instagramController.text = socialMedia['instagram'] ?? '';
          _linkedinController.text = socialMedia['linkedin'] ?? '';
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Build social media map
      final socialMedia = <String, dynamic>{};
      if (_facebookController.text.isNotEmpty) {
        socialMedia['facebook'] = _facebookController.text;
      }
      if (_twitterController.text.isNotEmpty) {
        socialMedia['twitter'] = _twitterController.text;
      }
      if (_instagramController.text.isNotEmpty) {
        socialMedia['instagram'] = _instagramController.text;
      }
      if (_linkedinController.text.isNotEmpty) {
        socialMedia['linkedin'] = _linkedinController.text;
      }

      // Create promoter detail model
      PromoterDetailModel? promoterDetail;
      if (currentUser.promoterDetail != null) {
        promoterDetail = currentUser.promoterDetail!.copyWith(
          companyName: _companyNameController.text.isNotEmpty
              ? _companyNameController.text
              : null,
          description: _companyDescriptionController.text.isNotEmpty
              ? _companyDescriptionController.text
              : null,
          website: _websiteController.text.isNotEmpty
              ? _websiteController.text
              : null,
          socialMedia: socialMedia.isNotEmpty
              ? socialMedia
              : currentUser.promoterDetail!.socialMedia,
          updatedAt: DateTime.now(),
        );
      }

      // Update user model
      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
        phoneNumber:
            _phoneController.text.isNotEmpty ? _phoneController.text : null,
        bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        updatedAt: DateTime.now(),
        promoterDetail: promoterDetail,
      );

      // Save updated user
      await _userRepository.updateUserProfile(updatedUser);

      // Update local user in auth provider
      await authProvider.updateUser(updatedUser);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to update profile: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reload data if canceling edit
        _loadUserData();
      }
    });
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picking functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image upload functionality will be implemented'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && !_isEditing
              ? ErrorStateWidget(message: _error!, onRetry: _loadUserData)
              : _isEditing
                  ? _buildEditForm(user)
                  : _buildProfileView(user),
    );
  }

  Widget _buildProfileView(UserModel user) {
    final theme = Theme.of(context);
    final promoterDetail = user.promoterDetail;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        backgroundImage: user.profilePicture != null
                            ? NetworkImage(user.profilePicture!)
                                as ImageProvider
                            : null,
                        child: user.profilePicture == null
                            ? Icon(Icons.business,
                                color: theme.colorScheme.primary, size: 60)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.photo_camera,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (promoterDetail?.companyName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    promoterDetail!.companyName!,
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: user.isVerified ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isVerified
                        ? 'Verified Promoter'
                        : 'Verification Pending',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Basic Information Section
          _buildSectionTitle('Contact Information'),
          _buildInfoRow(
            icon: Icons.email,
            title: 'Email',
            value: user.email,
          ),
          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.phone,
              title: 'Phone',
              value: user.phoneNumber!,
            ),

          const SizedBox(height: 24),

          // Bio Section
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            _buildSectionTitle('About'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                user.bio!,
                style: TextStyle(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Company Details Section
          if (promoterDetail != null) ...[
            _buildSectionTitle('Company Information'),
            if (promoterDetail.website != null &&
                promoterDetail.website!.isNotEmpty)
              _buildInfoRow(
                icon: Icons.link,
                title: 'Website',
                value: promoterDetail.website!,
                isLink: true,
              ),
            if (promoterDetail.description != null &&
                promoterDetail.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Company Description:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                promoterDetail.description!,
                style: TextStyle(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],

            // Social Media Links
            if (promoterDetail.socialMedia != null &&
                promoterDetail.socialMedia!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Social Media'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    if (promoterDetail.socialMedia!['facebook'] != null)
                      _buildSocialButton(
                        icon: Icons.facebook,
                        url: promoterDetail.socialMedia!['facebook']!,
                        color: Colors.blue.shade800,
                      ),
                    if (promoterDetail.socialMedia!['twitter'] != null)
                      _buildSocialButton(
                        icon: Icons.flutter_dash,
                        url: promoterDetail.socialMedia!['twitter']!,
                        color: Colors.blue.shade400,
                      ),
                    if (promoterDetail.socialMedia!['instagram'] != null)
                      _buildSocialButton(
                        icon: Icons.camera_alt,
                        url: promoterDetail.socialMedia!['instagram']!,
                        color: Colors.purple.shade400,
                      ),
                    if (promoterDetail.socialMedia!['linkedin'] != null)
                      _buildSocialButton(
                        icon: Icons.workspaces_filled,
                        url: promoterDetail.socialMedia!['linkedin']!,
                        color: Colors.blue.shade900,
                      ),
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: 24),

          // Account Information
          _buildSectionTitle('Account Information'),
          _buildInfoRow(
            icon: Icons.calendar_today,
            title: 'Member Since',
            value: user.createdAt != null
                ? DateFormat('MMMM yyyy').format(user.createdAt!)
                : 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.verified_user,
            title: 'Status',
            value: user.isVerified ? 'Verified' : 'Pending Verification',
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(UserModel user) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.1),
                          backgroundImage: user.profilePicture != null
                              ? NetworkImage(user.profilePicture!)
                                  as ImageProvider
                              : null,
                          child: user.profilePicture == null
                              ? const Icon(Icons.business,
                                  color: AppTheme.primaryColor, size: 60)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.photo_camera,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap to change profile picture',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Basic Information
            _buildSectionTitle('Personal Information'),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.email),
              ),
              enabled: false, // Email should not be editable
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself',
                prefixIcon: Icon(Icons.info_outline),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Company Information
            _buildSectionTitle('Company Information'),
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                hintText: 'Enter your company name',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Company Description',
                hintText: 'Describe your company',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                hintText: 'Enter your website URL',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 24),

            // Social Media Links
            _buildSectionTitle('Social Media Links'),
            TextFormField(
              controller: _facebookController,
              decoration: const InputDecoration(
                labelText: 'Facebook',
                hintText: 'Enter your Facebook profile URL',
                prefixIcon: Icon(Icons.facebook),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _twitterController,
              decoration: const InputDecoration(
                labelText: 'Twitter/X',
                hintText: 'Enter your Twitter/X profile URL',
                prefixIcon: Icon(Icons.flutter_dash),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(
                labelText: 'Instagram',
                hintText: 'Enter your Instagram profile URL',
                prefixIcon: Icon(Icons.camera_alt),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _linkedinController,
              decoration: const InputDecoration(
                labelText: 'LinkedIn',
                hintText: 'Enter your LinkedIn profile URL',
                prefixIcon: Icon(Icons.workspaces_filled),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 32),

            // Save button
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLink ? AppTheme.primaryColor : null,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String url,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Launch URL
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
