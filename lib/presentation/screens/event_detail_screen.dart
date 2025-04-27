import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/config/app_router.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/mock_event_repository.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../../data/repositories/mock_registration_repository.dart';
import '../widgets/common_widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../widgets/event_card.dart';

class EventDetailScreen extends StatefulWidget {
  final int? eventId;
  final String? eventSlug;

  const EventDetailScreen({Key? key, this.eventId, this.eventSlug})
    : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _eventRepository = MockEventRepository();
  final MockUserRepository _userRepository = MockUserRepository();
  final MockRegistrationRepository _registrationRepository =
      MockRegistrationRepository();

  bool _isLoading = true;
  String? _error;
  EventModel? _event;
  bool _isBookmarked = false;
  bool _isRegistering = false;
  bool _isLoggedIn = false;
  bool _isRegistered = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      EventModel? event;
      if (widget.eventId != null) {
        event = await _eventRepository.getEventById(widget.eventId!);
      } else if (widget.eventSlug != null) {
        event = await _eventRepository.getEventBySlug(widget.eventSlug!);
      }

      if (event != null) {
        setState(() {
          _event = event;
          _isBookmarked = event!.isBookmarked;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Event not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load event: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (_event == null) return;

    try {
      final updatedEvent = await _eventRepository.toggleBookmark(_event!.id);
      setState(() {
        _event = updatedEvent;
        _isBookmarked = updatedEvent.isBookmarked;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update bookmark: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleEventStatus() async {
    if (_event == null) return;

    try {
      final updatedEvent = _event!.copyWith(
        isPublished: !_event!.isPublished,
        updatedAt: DateTime.now(),
      );
      await _eventRepository.updateEvent(updatedEvent);
      setState(() {
        _event = updatedEvent;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Event ${_event!.isPublished ? 'published' : 'unpublished'} successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update event status: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent() async {
    if (_event == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Event'),
            content: const Text('Are you sure you want to delete this event?'),
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
        await _eventRepository.deleteEvent(_event!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete event: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _registerForEvent() async {
    if (_event == null || _isRegistering) return;

    // If user is not logged in, prompt them to login
    if (!_isLoggedIn) {
      final result = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Login Required'),
              content: const Text(
                'You need to be logged in to register for this event',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Login'),
                ),
              ],
            ),
      );

      if (result == true) {
        if (mounted) {
          Navigator.pushNamed(context, AppRouter.login);
        }
      }
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) throw Exception('User not found');

      // Create registration
      final registration = await _registrationRepository.registerForEvent(
        _event!.id,
        currentUser.id,
        amount: _event!.isFree ? null : _event!.price,
      );

      if (mounted) {
        setState(() {
          _isRegistering = false;
          _isRegistered = true;
        });

        // If it's a paid event, navigate to payment screen
        if (!_event!.isFree) {
          Navigator.pushNamed(
            context,
            AppRouter.payment,
            arguments: {'event': _event, 'registration': registration},
          );
        } else {
          // For free events, show confirmation directly
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Registration Successful'),
                  content: const Text(
                    'You have successfully registered for this event.',
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to register for event')),
        );
      }
    }
  }

  Future<void> _launchMap() async {
    if (_event == null || _event!.latitude == null || _event!.longitude == null)
      return;

    final url =
        'https://www.google.com/maps/search/?api=1&query=${_event!.latitude},${_event!.longitude}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open map')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isPromoter = authProvider.hasRole('promotor');
    final isAdmin = authProvider.hasRole('admin');
    final isEventOwner =
        _event != null &&
        (isAdmin ||
            (isPromoter && _event!.promotorId == authProvider.currentUser?.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (authProvider.isLoggedIn && !isEventOwner)
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              onPressed: _toggleBookmark,
            ),
          if (isEventOwner)
            PopupMenuButton<String>(
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit Event'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'status',
                      child: Row(
                        children: [
                          Icon(
                            _event?.isPublished ?? false
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _event?.isPublished ?? false
                                ? 'Unpublish Event'
                                : 'Publish Event',
                          ),
                        ],
                      ),
                    ),
                    if (isAdmin)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete Event'),
                          ],
                        ),
                      ),
                  ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Navigator.pushNamed(
                      context,
                      AppRouter.eventEdit,
                      arguments: _event?.id,
                    ).then((_) => _loadEvent());
                    break;
                  case 'status':
                    _toggleEventStatus();
                    break;
                  case 'delete':
                    _deleteEvent();
                    break;
                }
              },
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _loadEvent)
              : _event == null
              ? const EmptyStateWidget(
                message: 'Event not found',
                icon: Icons.event_busy,
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EventCard(event: _event!),
                    const SizedBox(height: 24),
                    if (isEventOwner) ...[
                      const Text(
                        'Event Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.people),
                            label: const Text('Manage Attendees'),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.attendeeManagement,
                                arguments: _event!.id,
                              );
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.analytics),
                            label: const Text('View Analytics'),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.analytics,
                                arguments: _event!.id,
                              );
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.attach_money),
                            label: const Text('Earnings Report'),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.earningsReport,
                                arguments: _event!.id,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Event Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Date',
                      DateFormat('EEEE, MMMM d, y').format(_event!.startDate),
                    ),
                    _buildDetailRow(
                      'Time',
                      '${DateFormat('h:mm a').format(_event!.startDate)} - ${DateFormat('h:mm a').format(_event!.endDate)}',
                    ),
                    _buildDetailRow('Location', _event!.locationName),
                    _buildDetailRow('Address', _event!.address),
                    _buildDetailRow('Category', _event!.categoryName),
                    _buildDetailRow(
                      'Price',
                      _event!.isFree
                          ? 'Free'
                          : '\$${_event!.price?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                    _buildDetailRow(
                      'Available Tickets',
                      '${(_event!.maxAttendees ?? 0) - (_event!.totalAttendees ?? 0)} of ${_event!.maxAttendees ?? 0}',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_event!.description),
                  ],
                ),
              ),
      bottomNavigationBar:
          _event != null && !isEventOwner
              ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.eventRegistration,
                        arguments: _event,
                      );
                    },
                    child: const Text('Register for Event'),
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
