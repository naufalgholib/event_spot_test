import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/mock_user_repository.dart';
import '../../../data/repositories/mock_event_repository.dart';
import '../../widgets/common_widgets.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final MockEventRepository _eventRepository = MockEventRepository();

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

      final registeredEvents = await _eventRepository.getRegisteredEvents();
      final now = DateTime.now();
      final upcoming =
          registeredEvents.where((e) => e.startDate.isAfter(now)).toList();
      final past =
          registeredEvents.where((e) => e.startDate.isBefore(now)).toList();

      final bookmarked = await _eventRepository.getBookmarkedEvents();

      if (mounted) {
        setState(() {
          _upcomingEvents = upcoming;
          _pastEvents = past;
          _bookmarkedEvents = bookmarked;
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
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          },
        ),
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
            Tab(text: 'Past'),
            Tab(text: 'Bookmarked'),
          ],
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(_upcomingEvents, 'No upcoming events'),
              _buildEventList(_pastEvents, 'No past events'),
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
      return EmptyStateWidget(message: emptyMessage, icon: Icons.event_busy);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SimpleEventCard(
            title: event.title,
            imageUrl: event.posterImage,
            location: event.locationName,
            date: DateFormat('E, MMM d, y').format(event.startDate),
            category: event.categoryName,
            isFree: event.isFree,
            onTap: () => _onEventTapped(event),
          ),
        );
      },
    );
  }
}
