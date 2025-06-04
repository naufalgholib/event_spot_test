import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/user_service.dart';
import '../../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _userService = UserService();

  File? _selectedImage;
  String? _profilePicture;
  bool _isLoading = false;
  String? _error;

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
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _bioController.text = user.bio ?? '';
      
      // Handle profile picture with validation
      if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
        if (_isValidImageUrl(user.profilePicture!)) {
          _profilePicture = user.profilePicture;
        } else {
          print('Invalid profile picture URL from user data: ${user.profilePicture}');
          _profilePicture = null;
        }
      } else {
        _profilePicture = null;
      }
      
      // Debug info
      print('Loaded user data:');
      print('- Name: ${user.name}');
      print('- Email: ${user.email}');
      print('- Phone: ${user.phoneNumber}');
      print('- Bio: ${user.bio}');
      print('- Profile Picture: ${user.profilePicture}');
      print('- Is valid URL: ${user.profilePicture != null ? _isValidImageUrl(user.profilePicture!) : false}');
    }
  }

  bool _isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Check if it's a valid URI
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return false;
      }
      
      // Check if it looks like an image URL
      final path = uri.path.toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      
      // Either has image extension or is from our trusted domain
      return validExtensions.any((ext) => path.endsWith(ext)) || 
             url.contains('eventspot.naufalg.online');
    } catch (e) {
      print('Error validating URL: $e');
      return false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        print('Image picked: ${pickedFile.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.blue),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteProfilePicture() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Profile Picture'),
        content: const Text('Are you sure you want to remove your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _userService.deleteProfilePicture();
      
      if (success) {
        setState(() {
          _profilePicture = null;
          _selectedImage = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove profile picture'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^\+?[\d\s-()]{10,}$').hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

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

      // Update profile picture if selected
      String? newProfilePicture = _profilePicture;
      if (_selectedImage != null) {
        print('Uploading new profile picture...');
        final uploadedUrl = await _userService.updateProfilePicture(_selectedImage!);
        if (uploadedUrl != null) {
          newProfilePicture = uploadedUrl;
          print('Profile picture uploaded successfully: $uploadedUrl');
        } else {
          print('Failed to upload profile picture');
        }
      }

      // Create updated user model
      final updatedUser = UserModel(
        id: currentUser.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        profilePicture: newProfilePicture,
        userType: currentUser.userType,
        isVerified: currentUser.isVerified,
        isActive: currentUser.isActive,
        createdAt: currentUser.createdAt,
        updatedAt: DateTime.now(),
      );

      print('Updating profile with data: ${updatedUser.toJson()}');

      // Update profile via API
      final success = await _userService.updateProfile(updatedUser);
      
      if (success) {
        // Update local state
        authProvider.updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving profile: $e');
      setState(() {
        _error = 'Failed to update profile: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileImage() {
    // 1. Jika ada gambar yang baru dipilih
    if (_selectedImage != null) {
      return ClipOval(
        child: Image.file(
          _selectedImage!,
          width: 114,
          height: 114,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading selected image: $error');
            return const Icon(Icons.person, size: 60);
          },
        ),
      );
    }
    
    // 2. Jika ada profile picture dari server
    if (_profilePicture != null && _profilePicture!.isNotEmpty) {
      // Validasi URL terlebih dahulu
      if (_isValidImageUrl(_profilePicture!)) {
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: _profilePicture!,
            width: 114,
            height: 114,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 114,
              height: 114,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) {
              print('Error loading network image: $error');
              print('Failed URL: $url');
              return Container(
                width: 114,
                height: 114,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 60),
              );
            },
            httpHeaders: const {
              'User-Agent': 'Mozilla/5.0 (compatible; EventSpot App)',
            },
          ),
        );
      } else {
        print('Invalid image URL: $_profilePicture');
      }
    }
    
    // 3. Default icon
    return Container(
      width: 114,
      height: 114,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }

  Widget _buildProfilePictureSection(ThemeData theme) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.primary, width: 3),
                  ),
                  child: _buildProfileImage(),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: _showImageOptions,
                    iconSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _showImageOptions,
              icon: Icon(Icons.photo_camera, color: theme.colorScheme.primary),
              label: Text(
                'Change Photo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            if (_profilePicture != null || _selectedImage != null)
              TextButton.icon(
                onPressed: _deleteProfilePicture,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        counterText: maxLength != null ? null : '',
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please log in to edit your profile'))
          : _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Updating profile...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Picture Section
                        _buildProfilePictureSection(theme),
                        const SizedBox(height: 32),

                        // Name field
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hintText: 'Enter your full name',
                          icon: Icons.person_outline,
                          validator: _validateName,
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Phone field
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hintText: 'Enter your phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 16),

                        // Bio field
                        _buildTextField(
                          controller: _bioController,
                          label: 'Bio',
                          hintText: 'Tell us about yourself',
                          icon: Icons.info_outline,
                          maxLines: 3,
                          maxLength: 500,
                        ),
                        const SizedBox(height: 24),

                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[300]!),
                              ),
                              child: Text(
                                _error!,
                                style: TextStyle(color: Colors.red[800]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        // Save button
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveProfile,
                          icon: _isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}