import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/config/app_router.dart';
import '../../../data/models/user_model.dart';

class VerificationDocumentUploadScreen extends StatefulWidget {
  const VerificationDocumentUploadScreen({Key? key}) : super(key: key);

  @override
  State<VerificationDocumentUploadScreen> createState() =>
      _VerificationDocumentUploadScreenState();
}

class _VerificationDocumentUploadScreenState
    extends State<VerificationDocumentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isUploading = false;
  File? _documentFile;
  File? _companyLogoFile;

  final _socialMediaControllers = {
    'facebook': TextEditingController(),
    'twitter': TextEditingController(),
    'instagram': TextEditingController(),
  };

  @override
  void dispose() {
    _companyNameController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _socialMediaControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _documentFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _companyLogoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate() || _documentFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill all required fields and upload verification document')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // In a real app, this would upload the files to a server
      await Future.delayed(
          const Duration(seconds: 2)); // Simulate network delay

      // Update the user's promotor details
      final socialMedia = {
        'facebook': _socialMediaControllers['facebook']!.text,
        'twitter': _socialMediaControllers['twitter']!.text,
        'instagram': _socialMediaControllers['instagram']!.text,
      };

      // In a real app, these values would be saved to the database
      final verificationData = {
        'companyName': _companyNameController.text,
        'website': _websiteController.text,
        'description': _descriptionController.text,
        'socialMedia': socialMedia,
        'verificationDocument':
            'documents/verification/user_document.pdf', // Mock path
        'companyLogo': _companyLogoFile != null
            ? 'logos/company_logo.png'
            : null, // Mock path
      };

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Verification documents submitted successfully. Please wait for approval.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to a waiting screen or back to login
        Navigator.pushReplacementNamed(context, AppRouter.verificationWaiting);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting verification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotor Verification'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete Your Promotor Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide your company details and upload verification documents to get started as a promotor.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Company Logo Upload
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickLogo,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          image: _companyLogoFile != null
                              ? DecorationImage(
                                  image: FileImage(_companyLogoFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _companyLogoFile == null
                            ? const Icon(
                                Icons.business,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Company Logo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Company Name
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your company name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Company Description *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description of your company';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Social Media Section
              const Text(
                'Social Media Links',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Facebook
              TextFormField(
                controller: _socialMediaControllers['facebook'],
                decoration: const InputDecoration(
                  labelText: 'Facebook Page URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.facebook),
                ),
              ),

              const SizedBox(height: 16),

              // Twitter
              TextFormField(
                controller: _socialMediaControllers['twitter'],
                decoration: const InputDecoration(
                  labelText: 'Twitter Profile URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),

              const SizedBox(height: 16),

              // Instagram
              TextFormField(
                controller: _socialMediaControllers['instagram'],
                decoration: const InputDecoration(
                  labelText: 'Instagram Profile URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.camera_alt),
                ),
              ),

              const SizedBox(height: 24),

              // Verification Documents
              const Text(
                'Verification Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please upload official documents that verify your business identity (business license, tax registration, etc.)',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Document Upload
              GestureDetector(
                onTap: _pickDocument,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _documentFile != null
                            ? Icons.check_circle
                            : Icons.upload_file,
                        size: 48,
                        color:
                            _documentFile != null ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _documentFile != null
                            ? 'Document uploaded successfully'
                            : 'Tap to upload verification document',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _documentFile != null
                              ? Colors.green
                              : Colors.grey[700],
                        ),
                      ),
                      if (_documentFile != null) const SizedBox(height: 8),
                      if (_documentFile != null)
                        Text(
                          _documentFile!.path.split('/').last,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Verification',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
