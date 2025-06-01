import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/event_service.dart';
import '../../../data/models/event_model.dart';

class EventEditScreen extends StatefulWidget {
  final int eventId;

  const EventEditScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  final EventService _eventService = EventService();
  final CategoryService _categoryService = CategoryService();
  Completer<GoogleMapController> _mapControllerCompleter = Completer();

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _maxAttendeesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Date and time controllers
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 2));
  DateTime _registrationStart =
      DateTime.now().subtract(const Duration(days: 1));
  DateTime _registrationEnd = DateTime.now().subtract(const Duration(hours: 1));

  // Form values
  int? _selectedCategoryId;
  bool _isLoadingData = true;
  bool _isLoadingCategories = true;
  bool _isSaving = false;
  List<CategoryModel> _categories = [];
  bool _isFree = true;
  final List<dynamic> _eventImages = [];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Map controller
  Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  bool _isMapCreated = false;
  bool _isMapLoading = true;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadEventData();
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
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadEventData() async {
    try {
      final event = await _eventService.getPromotorEventDetail(widget.eventId);

      setState(() {
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _locationNameController.text = event.locationName;
        _addressController.text = event.address;
        _maxAttendeesController.text = event.maxAttendees?.toString() ?? '';
        _priceController.text = event.price?.toString() ?? '';

        _startDate = event.startDate;
        _endDate = event.endDate;
        _registrationStart = event.registrationStart;
        _registrationEnd = event.registrationEnd;

        _selectedCategoryId = event.categoryId;
        _isFree = event.isFree;

        // Set map location if coordinates exist
        if (event.latitude != null && event.longitude != null) {
          _selectedLocation = LatLng(
            event.latitude!,
            event.longitude!,
          );
          _markers = {
            Marker(
              markerId: const MarkerId('event_location'),
              position: _selectedLocation!,
              infoWindow: InfoWindow(
                title: event.locationName,
                snippet: event.address,
              ),
            ),
          };
        }

        // Load images with proper URL handling
        if (event.posterImage != null) {
          if (event.posterImage!.startsWith('http')) {
            _eventImages.add(event.posterImage!);
          } else {
            // Handle local file path
            _eventImages.add(File(event.posterImage!));
          }
        }

        if (event.images != null) {
          for (var image in event.images!) {
            if (image.imagePath.startsWith('http')) {
              if (!_eventImages.contains(image.imagePath)) {
                _eventImages.add(image.imagePath);
              }
            } else {
              // Handle local file path
              final file = File(image.imagePath);
              if (!_eventImages.contains(file)) {
                _eventImages.add(file);
              }
            }
          }
        }

        _isLoadingData = false;
      });

      // Move camera to event location after map is created
      if (_isMapCreated && _selectedLocation != null) {
        final controller = await _mapControllerCompleter.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedLocation!,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load event data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      setState(() {
        _categories = categories;
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

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (!_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.complete(controller);
      setState(() {
        _isMapCreated = true;
        _isMapLoading = false;
      });

      // Move camera to event location if exists
      if (_selectedLocation != null) {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedLocation!,
              zoom: 15,
            ),
          ),
        );
      }
    }
  }

  void _onMapTap(LatLng location) {
    if (!_isMapLoading) {
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
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _selectedLocation = newPosition;
                _markers = {
                  Marker(
                    markerId: const MarkerId('event_location'),
                    position: newPosition,
                    infoWindow: InfoWindow(
                      title: _locationNameController.text,
                      snippet: _addressController.text,
                    ),
                    draggable: true,
                  ),
                };
              });
            },
          ),
        };
      });
    }
  }

  Future<void> _saveEvent() async {
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

      await _eventService.updatePromotorEvent(widget.eventId, eventData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update event: ${e.toString()}'),
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
      appBar: AppBar(
        title: const Text('Edit Event'),
        centerTitle: true,
      ),
      body: _isLoadingData || _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildDateTimeSection(),
                    const SizedBox(height: 24),
                    _buildPricingSection(),
                    const SizedBox(height: 24),
                    _buildImagesSection(),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: _isSaving
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Saving...'),
                                ],
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        const Text('Event Description *'),
        const SizedBox(height: 8),
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
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
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
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          _selectedLocation ?? const LatLng(-6.2088, 106.8456),
                      zoom: 15,
                    ),
                    markers: _markers,
                    onMapCreated: _onMapCreated,
                    onTap: _onMapTap,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: true,
                    compassEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    mapType: MapType.normal,
                  ),
                  if (_isMapLoading)
                    Container(
                      color: Colors.white.withOpacity(0.7),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Tap on the map to select the exact location. You can drag the marker to adjust the position.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Event Duration',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 16),
        const Text(
          'Registration Period',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
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

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pricing & Capacity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
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
              prefixText: 'Rp. ',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (!_isFree && (value == null || value.isEmpty)) {
                return 'Please enter a ticket price';
              }
              return null;
            },
          ),
        const SizedBox(height: 16),
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
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Images',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_eventImages.isEmpty)
          InkWell(
            onTap: _addImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
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
                  final image = _eventImages[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: image is String
                            ? Image.network(
                                image,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                image as File,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
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
      ],
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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • h:mm a').format(dateTime);
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
}
