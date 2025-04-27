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

class PromoterDashboardScreen extends StatefulWidget {
  const PromoterDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PromoterDashboardScreen> createState() =>
      _PromoterDashboardScreenState();
}

class _PromoterDashboardScreenState extends State<PromoterDashboardScreen> {
  final MockEventRepository _eventRepository = MockEventRepository();
  final MockUserRepository _userRepository = MockUserRepository();

  bool _isLoading = true;
  List<EventModel>? _upcomingEvents;
  List<EventModel>? _pastEvents;
  int _totalEvents = 0;
  int _totalAttendees = 0;
  double _totalEarnings = 0.0;
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
      final events = await _eventRepository.getPromoterEvents();
      final stats = await _eventRepository.getPromoterStats();

      final now = DateTime.now();
      final upcoming =
          events.where((e) => e.startDate.isAfter(now)).take(3).toList();
      final past =
          events.where((e) => e.startDate.isBefore(now)).take(3).toList();

      if (mounted) {
        setState(() {
          _upcomingEvents = upcoming;
          _pastEvents = past;
          _totalEvents = stats['totalEvents'] ?? 0;
          _totalAttendees = stats['totalAttendees'] ?? 0;
          _totalEarnings = stats['totalEarnings'] ?? 0.0;
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
        title: const Text('Promoter Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.eventCreation);
        },
        child: const Icon(Icons.add),
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
                      _buildPastEventsSection(),
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
            title: 'Total Events',
            value: _totalEvents.toString(),
            icon: Icons.event,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Total Attendees',
            value: _totalAttendees.toString(),
            icon: Icons.people,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Total Earnings',
            value: '\$${_totalEarnings.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.green,
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
                Navigator.pushNamed(context, AppRouter.eventManagement);
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

  Widget _buildPastEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Past Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.eventManagement);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_pastEvents == null || _pastEvents!.isEmpty)
          const EmptyStateWidget(message: 'No past events', icon: Icons.history)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pastEvents!.length,
            itemBuilder: (context, index) {
              final event = _pastEvents![index];
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
