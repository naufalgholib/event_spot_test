import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_router.dart';
import '../../core/config/app_constants.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/mock_event_repository.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../widgets/common_widgets.dart';
import '../widgets/event_card.dart';
import '../widgets/stat_card.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final MockEventRepository _eventRepository = MockEventRepository();
  final MockUserRepository _userRepository = MockUserRepository();

  bool _isLoading = true;
  List<EventModel>? _upcomingEvents;
  List<EventModel>? _bookmarkedEvents;
  int _totalEventsAttended = 0;
  int _totalBookmarks = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final registeredEvents = await _eventRepository.getRegisteredEvents();
      final bookmarkedEvents = await _eventRepository.getBookmarkedEvents();
      final userStats = await _userRepository.getUserStats();

      final now = DateTime.now();
      final upcoming =
          registeredEvents
              .where((e) => e.startDate.isAfter(now))
              .take(3)
              .toList();
      final bookmarks = bookmarkedEvents.take(3).toList();

      if (mounted) {
        setState(() {
          _upcomingEvents = upcoming;
          _bookmarkedEvents = bookmarks;
          _totalEventsAttended = userStats['totalEventsAttended'] ?? 0;
          _totalBookmarks = userStats['totalBookmarks'] ?? 0;
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
    Navigator.pushNamed(
      context,
      AppRouter.eventDetail,
      arguments: event.id,
    ).then((_) => _loadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _loadDashboardData)
              : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsSection(),
                      const SizedBox(height: 24),
                      _buildUpcomingEventsSection(),
                      const SizedBox(height: 24),
                      _buildBookmarkedEventsSection(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Events Attended',
            value: _totalEventsAttended.toString(),
            icon: Icons.event,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Bookmarks',
            value: _totalBookmarks.toString(),
            icon: Icons.bookmark,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.userEvents);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_upcomingEvents == null || _upcomingEvents!.isEmpty)
          const EmptyStateWidget(
            message: 'No upcoming events',
            icon: Icons.event_busy,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upcomingEvents!.length,
            itemBuilder: (context, index) {
              final event = _upcomingEvents![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(
                  event: event,
                  onTap: () => _onEventTapped(event),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBookmarkedEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bookmarked Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.bookmarkedEvents);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_bookmarkedEvents == null || _bookmarkedEvents!.isEmpty)
          const EmptyStateWidget(
            message: 'No bookmarked events',
            icon: Icons.bookmark_border,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bookmarkedEvents!.length,
            itemBuilder: (context, index) {
              final event = _bookmarkedEvents![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(
                  event: event,
                  onTap: () => _onEventTapped(event),
                ),
              );
            },
          ),
      ],
    );
  }
}
