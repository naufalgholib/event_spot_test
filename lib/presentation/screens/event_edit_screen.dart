import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_constants.dart';
import '../../data/models/event_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/mock_event_repository.dart';
import '../widgets/common_widgets.dart';

class EventEditScreen extends StatefulWidget {
  final int eventId;

  const EventEditScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventRepository = MockEventRepository();
  bool _isLoading = false;
  String? _error;
  EventModel? _event;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxAttendeesController = TextEditingController();

  // Form values
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationStart;
  DateTime? _registrationEnd;
  bool _isFree = false;
  int? _selectedCategoryId;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadEventAndCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  Future<void> _loadEventAndCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final event = await _eventRepository.getEventById(widget.eventId);
      final categories = await _eventRepository.getCategories();

      if (event == null) {
        throw Exception('Event not found');
      }

      setState(() {
        _event = event;
        _categories = categories;
        _selectedCategoryId = event.categoryId;

        // Initialize form fields
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _locationController.text = event.locationName;
        _addressController.text = event.address;
        _priceController.text = event.price?.toString() ?? '';
        _maxAttendeesController.text = event.maxAttendees.toString();
        _startDate = event.startDate;
        _endDate = event.endDate;
        _registrationStart = event.registrationStart;
        _registrationEnd = event.registrationEnd;
        _isFree = event.isFree;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load event: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate! : _endDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectRegistrationDate(
    BuildContext context,
    bool isStart,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _registrationStart! : _registrationEnd!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _registrationStart = picked;
        } else {
          _registrationEnd = picked;
        }
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final updatedEvent = _event!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategoryId!,
        categoryName:
            _categories.firstWhere((c) => c.id == _selectedCategoryId).name,
        locationName: _locationController.text,
        address: _addressController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        registrationStart: _registrationStart!,
        registrationEnd: _registrationEnd!,
        isFree: _isFree,
        price: _isFree ? null : double.parse(_priceController.text),
        maxAttendees: int.parse(_maxAttendeesController.text),
        updatedAt: DateTime.now(),
      );

      await _eventRepository.updateEvent(updatedEvent);

      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to update event: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Delete Event'),
                      content: const Text(
                        'Are you sure you want to delete this event?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
              );

              if (confirmed == true) {
                try {
                  await _eventRepository.deleteEvent(widget.eventId);
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  setState(() {
                    _error = 'Failed to delete event: ${e.toString()}';
                  });
                }
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? ErrorStateWidget(
                message: _error!,
                onRetry: _loadEventAndCategories,
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                          hintText: 'Enter event title',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter event description',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items:
                            _categories.map((category) {
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
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location Name',
                          hintText: 'Enter venue name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter full address',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text('Start Date'),
                              subtitle: Text(
                                _startDate != null
                                    ? DateFormat('MMM d, y').format(_startDate!)
                                    : 'Select date',
                              ),
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('End Date'),
                              subtitle: Text(
                                _endDate != null
                                    ? DateFormat('MMM d, y').format(_endDate!)
                                    : 'Select date',
                              ),
                              onTap: () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text('Registration Start'),
                              subtitle: Text(
                                _registrationStart != null
                                    ? DateFormat(
                                      'MMM d, y',
                                    ).format(_registrationStart!)
                                    : 'Select date',
                              ),
                              onTap:
                                  () => _selectRegistrationDate(context, true),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Registration End'),
                              subtitle: Text(
                                _registrationEnd != null
                                    ? DateFormat(
                                      'MMM d, y',
                                    ).format(_registrationEnd!)
                                    : 'Select date',
                              ),
                              onTap:
                                  () => _selectRegistrationDate(context, false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Free Event'),
                        value: _isFree,
                        onChanged: (value) {
                          setState(() {
                            _isFree = value;
                          });
                        },
                      ),
                      if (!_isFree) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            hintText: 'Enter ticket price',
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxAttendeesController,
                        decoration: const InputDecoration(
                          labelText: 'Maximum Attendees',
                          hintText: 'Enter maximum number of attendees',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter maximum attendees';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _updateEvent,
                        child: const Text('Update Event'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
