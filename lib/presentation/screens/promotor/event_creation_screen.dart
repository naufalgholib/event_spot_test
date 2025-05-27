import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/mock_event_repository.dart';
import '../../../data/services/category_service.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({Key? key}) : super(key: key);

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final MockEventRepository _repository = MockEventRepository();
  final CategoryService _categoryService = CategoryService();

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _maxAttendeesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Date and time controllers
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7, hours: 2));
  DateTime _registrationStart = DateTime.now();
  DateTime _registrationEnd = DateTime.now().add(const Duration(days: 6));

  // Form values
  int? _selectedCategoryId;
  bool _isLoadingCategories = true;
  List<CategoryModel> _categories = [];
  bool _isFree = true;
  bool _isUsingAI = false;
  bool _isGeneratingDescription = false;
  final List<dynamic> _eventImages = [];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Current form step
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    _addressController.dispose();
    _maxAttendeesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
        if (categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        onDateSelected(selectedDateTime);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • h:mm a').format(dateTime);
  }

  void _generateAIDescription() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an event title first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingDescription = true;
    });

    // Simulate AI generation with a delay
    Future.delayed(const Duration(seconds: 2), () {
      final eventTitle = _titleController.text;
      final category = _categories
          .firstWhere(
            (cat) => cat.id == _selectedCategoryId,
            orElse: () => CategoryModel(
              id: 0,
              name: 'Unknown',
              description: '',
              icon: '',
            ),
          )
          .name;

      final aiDescription = '''
Join us for an amazing $eventTitle event! This ${category.toLowerCase()} event will be an unforgettable experience for all attendees.

Our carefully curated program includes top-notch activities and experiences designed to engage and inspire participants. Whether you're a seasoned enthusiast or new to the world of ${category.toLowerCase()}, this event offers something for everyone.

Don't miss this opportunity to connect with like-minded individuals, learn from experts, and create lasting memories. Secure your spot today!
''';

      setState(() {
        _descriptionController.text = aiDescription;
        _isGeneratingDescription = false;
        _isUsingAI = true;
      });
    });
  }

  Future<void> _addImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _eventImages.add(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _eventImages.removeAt(index);
    });
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _titleController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty &&
          _selectedCategoryId != null;
    } else if (_currentStep == 1) {
      return _locationNameController.text.isNotEmpty &&
          _addressController.text.isNotEmpty;
    } else if (_currentStep == 2) {
      return true; // Date/time validation
    } else if (_currentStep == 3) {
      if (!_isFree) {
        return _priceController.text.isNotEmpty;
      }
      return true;
    }
    return true;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // In a real app, this would send data to the API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event'), centerTitle: true),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_validateCurrentStep()) {
                    if (_currentStep < 4) {
                      setState(() {
                        _currentStep += 1;
                      });
                    } else {
                      _submitForm();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                onStepTapped: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                steps: [
                  _buildBasicInfoStep(),
                  _buildLocationStep(),
                  _buildDateTimeStep(),
                  _buildPricingStep(),
                  _buildImagesStep(),
                ],
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            _currentStep == 4 ? 'Submit' : 'Continue',
                          ),
                        ),
                        if (_currentStep > 0) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Step _buildBasicInfoStep() {
    return Step(
      title: const Text('Basic Information'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Event Title *',
              hintText: 'Enter a catchy title for your event',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an event title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildCategoryDropdown(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Event Description *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  const Text('Use AI'),
                  Switch(
                    value: _isUsingAI,
                    onChanged: (value) {
                      setState(() {
                        _isUsingAI = value;
                      });
                      if (value) {
                        _generateAIDescription();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isGeneratingDescription)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating description with AI...'),
                  ],
                ),
              ),
            )
          else
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Describe your event in detail',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an event description';
                }
                return null;
              },
            ),
          if (!_isGeneratingDescription && !_isUsingAI)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                onPressed: _generateAIDescription,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate with AI'),
              ),
            ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Step _buildLocationStep() {
    return Step(
      title: const Text('Location'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _locationNameController,
            decoration: const InputDecoration(
              labelText: 'Venue Name *',
              hintText: 'E.g., Convention Center, Concert Hall',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a venue name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address *',
              hintText: 'Full address of the venue',
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a venue address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // In a real app, you would have a map widget here
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.map, size: 64, color: Colors.grey),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Map integration will allow you to set exact location',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildDateTimeStep() {
    return Step(
      title: const Text('Date & Time'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Duration',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildDateTimeSelector(
            label: 'Start Date & Time *',
            value: _formatDateTime(_startDate),
            onTap: () {
              _selectDate(context, _startDate, (date) {
                setState(() {
                  _startDate = date;
                  if (_endDate.isBefore(_startDate)) {
                    _endDate = _startDate.add(const Duration(hours: 2));
                  }
                });
              });
            },
          ),
          const SizedBox(height: 12),
          _buildDateTimeSelector(
            label: 'End Date & Time *',
            value: _formatDateTime(_endDate),
            onTap: () {
              _selectDate(context, _endDate, (date) {
                if (date.isAfter(_startDate)) {
                  setState(() {
                    _endDate = date;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End time must be after start time'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Registration Period',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildDateTimeSelector(
            label: 'Registration Opens *',
            value: _formatDateTime(_registrationStart),
            onTap: () {
              _selectDate(context, _registrationStart, (date) {
                setState(() {
                  _registrationStart = date;
                });
              });
            },
          ),
          const SizedBox(height: 12),
          _buildDateTimeSelector(
            label: 'Registration Closes *',
            value: _formatDateTime(_registrationEnd),
            onTap: () {
              _selectDate(context, _registrationEnd, (date) {
                if (date.isBefore(_startDate)) {
                  setState(() {
                    _registrationEnd = date;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Registration must close before event starts',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Step _buildPricingStep() {
    return Step(
      title: const Text('Pricing & Capacity'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('This is a free event'),
              const SizedBox(width: 8),
              Switch(
                value: _isFree,
                onChanged: (value) {
                  setState(() {
                    _isFree = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isFree)
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Ticket Price *',
                hintText: 'Enter amount',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (!_isFree && (value == null || value.isEmpty)) {
                  return 'Please enter a ticket price';
                }
                return null;
              },
            ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _maxAttendeesController,
            decoration: const InputDecoration(
              labelText: 'Maximum Attendees',
              hintText: 'Leave blank for unlimited',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Text(
            'Leave blank if there is no limit to the number of attendees.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildImagesStep() {
    return Step(
      title: const Text('Images'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Event Images',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add images that showcase your event. The first image will be used as the cover image.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_eventImages.isEmpty)
            InkWell(
              onTap: _addImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text('Add Event Image'),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _eventImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _eventImages[index] is String &&
                                  _eventImages[index].startsWith('http')
                              ? Image.network(
                                  _eventImages[index],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_eventImages[index]),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        if (index == 0)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Cover',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addImage,
                  icon: const Icon(Icons.add),
                  label: const Text('Add More Images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Your event is almost ready to publish!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Once submitted, your event will be available on the platform for users to discover and register.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      isActive: _currentStep >= 4,
      state: StepState.indexed,
    );
  }
}
