import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_router.dart';
import '../../core/config/app_constants.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/mock_event_repository.dart';
import '../widgets/common_widgets.dart';
import '../widgets/event_card.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({Key? key}) : super(key: key);

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final _eventRepository = MockEventRepository();
  bool _isLoading = true;
  String? _error;
  List<EventModel>? _events;
  String _selectedFilter = 'all'; // all, upcoming, past
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _eventRepository.getPromoterEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<EventModel> _getFilteredEvents() {
    if (_events == null) return [];

    final now = DateTime.now();
    var filteredEvents = List<EventModel>.from(_events!);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredEvents =
          filteredEvents.where((event) {
            return event.title.toLowerCase().contains(query) ||
                event.description.toLowerCase().contains(query) ||
                event.locationName.toLowerCase().contains(query);
          }).toList();
    }

    // Apply date filter
    switch (_selectedFilter) {
      case 'upcoming':
        return filteredEvents
            .where((event) => event.startDate.isAfter(now))
            .toList();
      case 'past':
        return filteredEvents
            .where((event) => event.startDate.isBefore(now))
            .toList();
      default:
        return filteredEvents;
    }
  }

  void _onEventTapped(EventModel event) {
    Navigator.pushNamed(
      context,
      AppRouter.eventEdit,
      arguments: event.id,
    ).then((_) => _loadEvents());
  }

  Future<void> _toggleEventStatus(EventModel event) async {
    try {
      final updatedEvent = event.copyWith(
        isPublished: !event.isPublished,
        updatedAt: DateTime.now(),
      );
      await _eventRepository.updateEvent(updatedEvent);
      _loadEvents();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _loadEvents)
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Events',
                            hintText:
                                'Search by title, description, or location',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                    : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'all',
                              label: Text('All'),
                            ),
                            ButtonSegment<String>(
                              value: 'upcoming',
                              label: Text('Upcoming'),
                            ),
                            ButtonSegment<String>(
                              value: 'past',
                              label: Text('Past'),
                            ),
                          ],
                          selected: {_selectedFilter},
                          onSelectionChanged: (value) {
                            setState(() {
                              _selectedFilter = value.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadEvents,
                      child:
                          _getFilteredEvents().isEmpty
                              ? const EmptyStateWidget(
                                message: 'No events found',
                                icon: Icons.event_busy,
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.defaultPadding,
                                ),
                                itemCount: _getFilteredEvents().length,
                                itemBuilder: (context, index) {
                                  final event = _getFilteredEvents()[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      children: [
                                        EventCard(
                                          event: event,
                                          onTap: () => _onEventTapped(event),
                                        ),
                                        const Divider(height: 1),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton.icon(
                                                icon: Icon(
                                                  event.isPublished
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                label: Text(
                                                  event.isPublished
                                                      ? 'Unpublish'
                                                      : 'Publish',
                                                ),
                                                onPressed:
                                                    () => _toggleEventStatus(
                                                      event,
                                                    ),
                                              ),
                                              TextButton.icon(
                                                icon: const Icon(Icons.edit),
                                                label: const Text('Edit'),
                                                onPressed:
                                                    () => _onEventTapped(event),
                                              ),
                                              TextButton.icon(
                                                icon: const Icon(Icons.people),
                                                label: const Text('Attendees'),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    AppRouter
                                                        .attendeeManagement,
                                                    arguments: event.id,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                  ),
                ],
              ),
    );
  }
}
