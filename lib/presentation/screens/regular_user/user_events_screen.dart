import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/event_card.dart';

class UserEventsScreen extends StatefulWidget {
  const UserEventsScreen({super.key});

  @override
  State<UserEventsScreen> createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen>
    with SingleTickerProviderStateMixin {
  final EventService _eventService = EventService();
  late TabController _tabController;
  List<EventModel>? _upcomingEvents;
  List<EventModel>? _pastEvents;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      if (!authProvider.isLoggedIn) {
        throw Exception('Please log in to view your events');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _loadData)
              : Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Past'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildEventList(
                            _upcomingEvents,
                            'No upcoming events registered.\nFind and register for events to see them here!',
                          ),
                          _buildEventList(
                            _pastEvents,
                            'No past events found.\nYour event history will appear here.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text(
                'Browse Events',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          ),
        );
      },
    );
  }
}
