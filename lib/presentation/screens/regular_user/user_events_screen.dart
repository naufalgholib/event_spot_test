import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_router.dart';
import '../../../core/config/app_constants.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/mock_event_repository.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/event_card.dart';

class UserEventsScreen extends StatefulWidget {
  const UserEventsScreen({Key? key}) : super(key: key);

  @override
  State<UserEventsScreen> createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen>
    with SingleTickerProviderStateMixin {
  final MockEventRepository _eventRepository = MockEventRepository();
  late TabController _tabController;

  bool _isLoading = true;
  List<EventModel>? _upcomingEvents;
  List<EventModel>? _pastEvents;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRegisteredEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRegisteredEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final registeredEvents = await _eventRepository.getRegisteredEvents();

      final now = DateTime.now();
      final upcoming =
          registeredEvents.where((e) => e.startDate.isAfter(now)).toList();
      final past =
          registeredEvents.where((e) => e.startDate.isBefore(now)).toList();

      if (mounted) {
        setState(() {
          _upcomingEvents = upcoming;
          _pastEvents = past;
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
    ).then((_) => _loadRegisteredEvents()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorStateWidget(
                  message: _error!,
                  onRetry: _loadRegisteredEvents,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventList(_upcomingEvents, 'No upcoming events'),
                    _buildEventList(_pastEvents, 'No past events'),
                  ],
                ),
    );
  }

  Widget _buildEventList(List<EventModel>? events, String emptyMessage) {
    if (events == null || events.isEmpty) {
      return EmptyStateWidget(message: emptyMessage, icon: Icons.event_busy);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EventCard(event: event, onTap: () => _onEventTapped(event)),
        );
      },
    );
  }
}
