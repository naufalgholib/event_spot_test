import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/config/app_router.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';
import '../../../data/services/bookmark_service.dart';
import '../../../data/services/user_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/event_card.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;
  final String? eventSlug;

  const EventDetailScreen({
    Key? key,
    this.eventId = 0,
    this.eventSlug,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  final BookmarkService _bookmarkService = BookmarkService();
  final UserService _userService = UserService();

  EventModel? _event;
  bool _isLoading = true;
  bool _isBookmarked = false;
  bool _isRegistered = false;
  String? _error;
  bool _isLoggedIn = false;
  final int _currentImageIndex = 0;
  Map<String, dynamic>? _attendanceDetails;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final event = await _eventService.getEventDetail(widget.eventId);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _isLoggedIn = authProvider.isLoggedIn;

      if (_isLoggedIn) {
        _isBookmarked = await _bookmarkService.isEventBookmarked(event.id);

        // Load attendance details if user is logged in
        final attendance = await _eventService.getAttendanceDetails(event.id);
        setState(() {
          _attendanceDetails = attendance;
          _isRegistered = attendance['status'] == 'registered';
        });
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
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (!_isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login as a regular user to bookmark events'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final isBookmarked = await _bookmarkService.toggleBookmark(_event!.id);
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBookmarked
                  ? 'Event bookmarked'
                  : 'Event removed from bookmarks',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update bookmark: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _registerForEvent() async {
    if (_event == null) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      final registrationData = await _eventService.registerForEvent(_event!.id);

      // Reload attendance details
      final attendance = await _eventService.getAttendanceDetails(_event!.id);

      if (mounted) {
        setState(() {
          _attendanceDetails = attendance;
          _isRegistered = true;
          _isRegistering = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for event'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelRegistration() async {
    if (_event == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Registration'),
        content: const Text(
            'Are you sure you want to cancel your registration? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      final success = await _eventService.cancelEventRegistration(_event!.id);

      if (success) {
        // Reload attendance details
        final attendance = await _eventService.getAttendanceDetails(_event!.id);

        if (mounted) {
          setState(() {
            _attendanceDetails = attendance;
            _isRegistered = false;
            _isRegistering = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration cancelled successfully'),
              backgroundColor: Colors.green,
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
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareEvent() {
    if (_event == null) return;
    Share.share(
        'Check out this event: ${_event!.title}\n${_event!.description}\nDate: ${DateFormat('EEEE, MMMM d, y').format(_event!.startDate)}');
  }

  Future<void> _launchMap() async {
    if (_event == null ||
        _event!.latitude == null ||
        _event!.longitude == null) {
      return;
    }

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
              ? ErrorStateWidget(message: _error!, onRetry: _loadEventData)
              : _event == null
                  ? const EmptyStateWidget(
                      message: 'Event not found',
                      icon: Icons.event_busy,
                    )
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
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
              onPressed: _toggleBookmark,
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareEvent,
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

                const SizedBox(height: 24),

                // Registration status section
                const Text(
                  'Registration Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                        _attendanceDetails?['status'] ?? 'not_registered'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(
                        _attendanceDetails?['status'] ?? 'not_registered'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_attendanceDetails?['ticket_code'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ticket Code: ${_attendanceDetails?['ticket_code']}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
                if (_attendanceDetails?['registration_date'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Registration Date: ${_formatDateTime(_attendanceDetails?['registration_date'])}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
                if (_attendanceDetails?['check_in_time'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Check-in Time: ${_formatDateTime(_attendanceDetails?['check_in_time'])}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
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

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateStr;
    }
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
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              onPressed: _toggleBookmark,
            ),
            const SizedBox(width: 16),
            // Register/Payment button
            Expanded(
              child: AppButton(
                text: _isRegistered
                    ? 'Cancel'
                    : _event!.isFree
                        ? 'Register Now'
                        : 'Pay ${NumberFormat.currency(symbol: '\$').format(_event!.price)}',
                onPressed:
                    _isRegistered ? _cancelRegistration : _registerForEvent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return Colors.green;
      case 'attended':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending_payment':
        return Colors.orange;
      case 'not_registered':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return 'Registered';
      case 'attended':
        return 'Attended';
      case 'cancelled':
        return 'Cancelled';
      case 'pending_payment':
        return 'Pending Payment';
      case 'not_registered':
        return 'Not Registered';
      default:
        return status;
    }
  }
}
