import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';
import '../../../data/services/user_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/event_card.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final EventService _eventService = EventService();
  final UserService _userService = UserService();

  late TabController _tabController;
  List<EventModel>? _upcomingEvents;
  List<EventModel>? _pastEvents;
  List<EventModel>? _bookmarkedEvents;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('User not found. Please log in.');
      }

      // Load upcoming events
      try {
        final upcoming = await _eventService.getUpcomingEvents();
        setState(() {
          _upcomingEvents = upcoming;
        });
      } catch (e) {
        // If error is about no events, just set empty list
        if (e.toString().contains('Failed to load upcoming events')) {
          setState(() {
            _upcomingEvents = [];
          });
        } else {
          rethrow;
        }
      }

      // Load event history
      try {
        final past = await _eventService.getEventHistory();
        setState(() {
          _pastEvents = past;
        });
      } catch (e) {
        // If error is about no events, just set empty list
        if (e.toString().contains('Failed to load event history')) {
          setState(() {
            _pastEvents = [];
          });
        } else {
          rethrow;
        }
      }

      // Load bookmarked events
      try {
        final bookmarked = await _eventService.getBookmarkedEvents();
        setState(() {
          _bookmarkedEvents = bookmarked;
        });
      } catch (e) {
        // If error is about no events, just set empty list
        if (e.toString().contains('Failed to load bookmarked events')) {
          setState(() {
            _bookmarkedEvents = [];
          });
        } else {
          rethrow;
        }
      }

      if (mounted) {
        setState(() {
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

  void _onEventTapped(EventModel event) {
    Navigator.pushNamed(context, AppRouter.eventDetail, arguments: event.id);
  }

  void _editProfile() {
    Navigator.pushNamed(context, AppRouter.editProfile);
  }

  void _openSettings() {
    Navigator.pushNamed(context, AppRouter.userSettings);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _loadData)
              : _buildContent(user),
    );
  }

  Widget _buildContent(UserModel? user) {
    if (user == null) {
      return const Center(child: Text('Please log in to view your profile'));
    }

    return Column(
      children: [
        // User Info Section
        _buildUserInfo(user),

        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
            Tab(text: 'Bookmarked'),
          ],
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(_upcomingEvents, 'No upcoming events'),
              _buildEventList(_pastEvents, 'No history events'),
              _buildEventList(_bookmarkedEvents, 'No bookmarked events'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(UserModel user) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: user.profilePicture != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.profilePicture!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person, size: 40),
                        ),
                      )
                    : const Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since ${DateFormat('MMM yyyy').format(user.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.event,
                value:
                    (_upcomingEvents?.length ?? 0) + (_pastEvents?.length ?? 0),
                label: 'Events',
              ),
              _buildStatItem(
                icon: Icons.bookmark,
                value: _bookmarkedEvents?.length ?? 0,
                label: 'Bookmarks',
              ),
              _buildStatItem(
                icon: Icons.reviews,
                value: 0, // TODO: Implement reviews
                label: 'Reviews',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEventList(List<EventModel>? events, String emptyMessage) {
    if (events == null || events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.home);
              },
              label: const Text('Browse Events'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EventCard(
            event: event,
            onTap: () => _onEventTapped(event),
            onBookmarkChanged: (isBookmarked) {
              setState(() {
                final updatedEvent = event.copyWith(isBookmarked: isBookmarked);
                final eventIndex = events.indexWhere((e) => e.id == event.id);
                if (eventIndex != -1) {
                  events[eventIndex] = updatedEvent;
                }
              });
            },
            showStatus: false,
          ),
        );
      },
    );
  }
}
