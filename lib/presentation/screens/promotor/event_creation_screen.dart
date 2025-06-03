import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/event_service.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({Key? key}) : super(key: key);

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final EventService _eventService = EventService();
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
  bool _isSaving = false;
  List<CategoryModel> _categories = [];
  bool _isFree = true;
  bool _isUsingAI = false;
  bool _isGeneratingDescription = false;
  final List<dynamic> _eventImages = [];

  // Map controller
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  Set<Marker> _markers = {};
  LatLng? _selectedLocation;

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
    if (_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.future.then((controller) => controller.dispose());
    }
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

  Future<void> _generateAIDescription() async {
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
      _descriptionController.text = '';
    });

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

    // IMPORTANT: Replace with your actual Gemini API key
    const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY',
        defaultValue: 'MISSING_GEMINI_API_KEY'); // Changed variable name
    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey'; // Updated API URL and key placement

    final prompt =
        "Tolong buatkan deskripsi yang unik dan menarik untuk event \"$eventTitle\" dengan kategori event \"$category\". Nantinya deskripsi event ini akan dipakai untuk di posting di aplikasi event spotter, dimana orang orang bisa melihat event ini dan registrasi serta menghadiri event ini. Text nya jangan terlalu Panjang karna akan dimuat di aplikasi mobile juga. Respon tidak usah menggunakan pembuka seperti Tentu, berikut xxx ataupun penutup seperti Semoga deskripsi ini membantu! langsung saja ke deskripsinya. Kurang lebih 50 kata";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // Gemini API key is in the URL, so no Authorization header needed here
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
          // Gemini API specific parameters might be added here if needed, e.g., generationConfig
          // 'generationConfig': {
          //   'temperature': 0.7,
          //   'maxOutputTokens': 256,
          // }
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          // Adjusted response parsing for Gemini API
          final aiDescription = responseBody['candidates'][0]['content']
                  ['parts'][0]['text']
              .toString()
              .trim();
          setState(() {
            _descriptionController.text = aiDescription;
            _isUsingAI = true;
          });
        } else {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['error']?['message'] ??
              'Failed to generate description. Status code: ${response.statusCode}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI Error: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to AI service: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingDescription = false;
        });
      }
    }
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location_name': _locationNameController.text,
        'address': _addressController.text,
        'start_date': _startDate.toIso8601String(),
        'end_date': _endDate.toIso8601String(),
        'registration_start': _registrationStart.toIso8601String(),
        'registration_end': _registrationEnd.toIso8601String(),
        'is_free': _isFree,
        'price': _isFree ? null : double.parse(_priceController.text),
        'max_attendees': _maxAttendeesController.text.isEmpty
            ? null
            : int.parse(_maxAttendeesController.text),
        'category_id': _selectedCategoryId,
        'latitude': _selectedLocation?.latitude,
        'longitude': _selectedLocation?.longitude,
      };

      // Upload images if any
      if (_eventImages.isNotEmpty) {
        // TODO: Implement image upload logic
        // For now, we'll just use the first image as poster
        eventData['poster_image'] = _eventImages[0];
      }

      await _eventService.createPromotorEvent(eventData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
          const Text(
            'Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
          RepaintBoundary(
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target:
                        _selectedLocation ?? const LatLng(-6.2088, 106.8456),
                    zoom: 15,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    if (!_mapControllerCompleter.isCompleted) {
                      _mapControllerCompleter.complete(controller);
                    }
                  },
                  onTap: (location) {
                    setState(() {
                      _selectedLocation = location;
                      _markers = {
                        Marker(
                          markerId: const MarkerId('event_location'),
                          position: location,
                          infoWindow: InfoWindow(
                            title: _locationNameController.text,
                            snippet: _addressController.text,
                          ),
                        ),
                      };
                    });
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: true,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Tap on the map to select the exact location',
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
