import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';
import '../../../core/config/app_router.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({Key? key}) : super(key: key);

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen>
    with SingleTickerProviderStateMixin {
  final EventService _eventService = EventService();
  bool _isLoading = true;
  List<EventModel> _promotorEvents = [];
  List<EventModel> _filteredEvents = [];
  String _searchQuery = '';

  // Tab controller for different event statuses
  late TabController _tabController;

  // Filter options
  String _selectedSortOption = 'Newest First';
  final List<String> _sortOptions = [
    'Newest First',
    'Oldest First',
    'Alphabetical',
    'Most Attendees',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadPromotorEvents();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _filterEvents();
    }
  }

  Future<void> _loadPromotorEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _eventService.getPromotorEvents();
      setState(() {
        _promotorEvents = events;
        _filterEvents();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterEvents() {
    List<EventModel> filtered = [];
    final now = DateTime.now().toUtc();

    // Filter by tab (status)
    if (_tabController.index == 0) {
      // Upcoming events
      filtered = _promotorEvents.where((event) {
        // Event is upcoming if it hasn't started yet
        final isUpcoming = event.startDate.isAfter(now);
        return isUpcoming;
      }).toList();
    } else if (_tabController.index == 1) {
      // Ongoing events
      filtered = _promotorEvents.where(
        (event) {
          // Convert dates to UTC for comparison
          final startDate = event.startDate.toUtc();
          final endDate = event.endDate.toUtc();

          // Check if event is on the same day
          final isSameDay = startDate.year == now.year &&
              startDate.month == now.month &&
              startDate.day == now.day;

          // Event has started if:
          // 1. Start date is before now, OR
          // 2. It's the same day and start time has passed
          final hasStarted = startDate.isBefore(now) ||
              (isSameDay && startDate.hour <= now.hour);

          // Event hasn't ended
          final hasNotEnded = endDate.isAfter(now);

          return hasStarted && hasNotEnded;
        },
      ).toList();
    } else {
      // Past events
      filtered = _promotorEvents.where((event) {
        final isPast = event.endDate.toUtc().isBefore(now);
        return isPast;
      }).toList();
    }

    // Apply search filter if there's a query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((event) {
        return event.title.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query) ||
            event.locationName.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    _sortEvents(filtered);

    setState(() {
      _filteredEvents = filtered;
    });
  }

  void _sortEvents(List<EventModel> events) {
    switch (_selectedSortOption) {
      case 'Newest First':
        events.sort((a, b) => b.startDate.compareTo(a.startDate));
        break;
      case 'Oldest First':
        events.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
      case 'Alphabetical':
        events.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Most Attendees':
        events.sort(
          (a, b) => (b.totalAttendees ?? 0).compareTo(a.totalAttendees ?? 0),
        );
        break;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterEvents();
  }

  String _formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('EEEE, MMMM d yyyy • h:mm a');
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Past'),
          ],
          labelColor: AppTheme.backgroundColor,
          indicatorColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFiltersSection(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Upcoming events tab
                      _buildEventsList(),
                      // Ongoing events tab
                      _buildEventsList(),
                      // Past events tab
                      _buildEventsList(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          // Navigate to event creation screen
          Navigator.pushNamed(context, AppRouter.eventCreation);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 8),
          // Sort options
          Row(
            children: [
              const Text('Sort by: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedSortOption,
                underline: Container(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSortOption = value;
                    });
                    _filterEvents();
                  }
                },
                items: _sortOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_filteredEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy, color: Colors.grey, size: 64),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No events found matching "$_searchQuery"'
                    : 'No events in this category yet',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (_searchQuery.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                    _filterEvents();
                  },
                  child: const Text('Clear Search'),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPromotorEvents,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final isUpcoming = event.startDate.isAfter(DateTime.now());
    final isOngoing = event.isOngoing;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage(
                  event.posterImage ?? 'https://via.placeholder.com/400x200',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? AppTheme.primaryColor
                          : isOngoing
                              ? AppTheme.secondaryColor
                              : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isUpcoming
                          ? 'Upcoming'
                          : isOngoing
                              ? 'Ongoing'
                              : 'Past',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(event.startDate),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.locationName,
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${event.totalAttendees ?? 0}${event.maxAttendees != null ? '/${event.maxAttendees}' : ''} attendees',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Edit button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.eventEdit,
                            arguments: {'eventId': event.id},
                          );
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // View Attendees button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to attendee list
                        },
                        icon: const Icon(Icons.people, size: 16),
                        label: const Text('Attendees'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View Stats button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to event statistics
                        },
                        icon: const Icon(Icons.bar_chart, size: 16),
                        label: const Text('Statistics'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Manage Comments button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to comment management
                        },
                        icon: const Icon(Icons.comment, size: 16),
                        label: const Text('Comments'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
