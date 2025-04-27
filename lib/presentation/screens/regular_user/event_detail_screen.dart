import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/config/app_router.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/mock_event_repository.dart';
import '../../../data/repositories/mock_user_repository.dart';
import '../../../data/repositories/mock_registration_repository.dart';
import '../../widgets/common_widgets.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;
  final String? eventSlug;

  const EventDetailScreen({super.key, this.eventId = 0, this.eventSlug})
      : assert(
          eventId != 0 || eventSlug != null,
          'Either eventId or eventSlug must be provided',
        );

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final MockEventRepository _eventRepository = MockEventRepository();
  final MockUserRepository _userRepository = MockUserRepository();
  final MockRegistrationRepository _registrationRepository =
      MockRegistrationRepository();

  EventModel? _event;
  bool _isLoading = true;
  bool _isBookmarking = false;
  bool _isRegistering = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _isRegistered = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if user is logged in
      final currentUser = await _userRepository.getCurrentUser();
      _isLoggedIn = currentUser != null;

      // Fetch event data
      EventModel? event;
      if (widget.eventId != 0) {
        event = await _eventRepository.getEventById(widget.eventId);
      } else if (widget.eventSlug != null) {
        event = await _eventRepository.getEventBySlug(widget.eventSlug!);
      }

      if (event == null) {
        setState(() {
          _error = 'Event not found';
          _isLoading = false;
        });
        return;
      }

      // Check if user is registered for this event
      if (_isLoggedIn && currentUser != null) {
        _isRegistered = await _registrationRepository.isUserRegistered(
          event.id,
          currentUser.id,
        );
      }

      if (mounted) {
        setState(() {
          _event = event;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load event details. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_event == null || _isBookmarking) return;

    setState(() {
      _isBookmarking = true;
    });

    try {
      final updatedEvent = await _eventRepository.toggleBookmark(_event!.id);
      if (mounted) {
        setState(() {
          _event = updatedEvent;
          _isBookmarking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _event!.isBookmarked
                  ? 'Event bookmarked'
                  : 'Event removed from bookmarks',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBookmarking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update bookmark'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _registerForEvent() async {
    if (_event == null || _isRegistering) return;

    // If user is not logged in, prompt them to login
    if (!_isLoggedIn) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
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
            builder: (context) => AlertDialog(
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _loadData)
              : _buildEventDetail(),
      bottomNavigationBar: _event != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildEventDetail() {
    if (_event == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final hasImages = _event!.images != null && _event!.images!.isNotEmpty;
    final displayImage = hasImages
        ? _event!.images![_currentImageIndex].imagePath
        : _event!.posterImage;

    return CustomScrollView(
      slivers: [
        // App Bar with image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Event Image
                displayImage != null && displayImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: displayImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Image.asset(
                          AppConstants.placeholderImagePath,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        AppConstants.placeholderImagePath,
                        fit: BoxFit.cover,
                      ),

                // Gradient overlay for better text visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),

                // Image pagination indicators
                if (hasImages && _event!.images!.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _event!.images!.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _event!.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
              onPressed: _toggleBookmark,
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ],
        ),

        // Event details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _event!.categoryName,
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_event!.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.amber[800],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  _event!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Date and time
                _infoRow(Icons.calendar_today, 'Date', _formatDate()),

                const SizedBox(height: 8),

                // Location
                _infoRow(
                  Icons.location_on,
                  'Location',
                  _event!.locationName,
                  subtitle: _event!.address,
                  onTap: _launchMap,
                ),

                const SizedBox(height: 8),

                // Organizer
                _infoRow(
                  Icons.person,
                  'Organizer',
                  _event!.promotorName,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.promoterProfile,
                    arguments: _event!.promotorId,
                  ),
                ),

                const SizedBox(height: 8),

                // Price
                _infoRow(
                  Icons.attach_money,
                  'Price',
                  _event!.isFree
                      ? 'Free'
                      : '\$${_event!.price?.toStringAsFixed(2)}',
                ),

                const SizedBox(height: 8),

                // Registration period
                _infoRow(
                  Icons.how_to_reg,
                  'Registration',
                  'Until ${DateFormat('MMM d, y').format(_event!.registrationEnd)}',
                  subtitle: _event!.isRegistrationOpen
                      ? 'Registration is open'
                      : _event!.registrationEnd.isBefore(DateTime.now())
                          ? 'Registration has ended'
                          : 'Registration starts on ${DateFormat('MMM d, y').format(_event!.registrationStart)}',
                ),

                const SizedBox(height: 8),

                // Attendees
                _infoRow(
                  Icons.group,
                  'Attendees',
                  '${_event!.totalAttendees ?? 0}${_event!.maxAttendees != null ? ' / ${_event!.maxAttendees}' : ''}',
                  subtitle: _event!.isFullCapacity
                      ? 'This event is at full capacity'
                      : null,
                ),

                const Divider(height: 32),

                // Description header
                const Text(
                  'About this event',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  _event!.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),

                // Map
                if (_event!.latitude != null && _event!.longitude != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            center: LatLng(
                              _event!.latitude!,
                              _event!.longitude!,
                            ),
                            zoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.event_spot',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    _event!.latitude!,
                                    _event!.longitude!,
                                  ),
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: InkWell(
                            onTap: _launchMap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.open_in_new,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Open in Maps',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Tags
                if (_event!.tags != null && _event!.tags!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Tags',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _event!.tags!.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(tag.name),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  String _formatDate() {
    if (_event == null) return '';

    final startDate = DateFormat('E, MMM d, y').format(_event!.startDate);

    // Same day event
    if (_event!.startDate.year == _event!.endDate.year &&
        _event!.startDate.month == _event!.endDate.month &&
        _event!.startDate.day == _event!.endDate.day) {
      final startTime = DateFormat('h:mm a').format(_event!.startDate);
      final endTime = DateFormat('h:mm a').format(_event!.endDate);
      return '$startDate, $startTime - $endTime';
    }

    // Multi-day event
    final endDate = DateFormat('E, MMM d, y').format(_event!.endDate);
    return '$startDate - $endDate';
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bookmark button
            IconButton(
              icon: Icon(
                _event!.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              onPressed: _toggleBookmark,
            ),
            const SizedBox(width: 16),
            // Register/Payment button
            Expanded(
              child: AppButton(
                text: _isRegistered
                    ? 'Registered'
                    : _event!.isFree
                        ? 'Register Now'
                        : 'Pay ${NumberFormat.currency(symbol: '\$').format(_event!.price)}',
                onPressed: _isRegistered
                    ? (() {})
                    : (() {
                        _registerForEvent();
                      }),
                isLoading: _isRegistering,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
