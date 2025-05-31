import 'package:flutter/material.dart';
import 'package:event_spot/data/models/event_model.dart';
import 'package:event_spot/data/repositories/mock_event_repository.dart';
import '../../../core/theme/app_theme.dart';

class EventModerationScreen extends StatefulWidget {
  const EventModerationScreen({Key? key}) : super(key: key);

  @override
  State<EventModerationScreen> createState() => _EventModerationScreenState();
}

class _EventModerationScreenState extends State<EventModerationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockEventRepository _eventRepository = MockEventRepository();
  bool _isLoading = true;

  // Lists to hold events
  List<EventModel> _reportedEvents = [];
  List<EventModel> _featuredEvents = [];
  List<EventModel> _allEvents = [];

  // Event report mock data
  final List<Map<String, dynamic>> _reportData = [
    {
      'eventId': 1,
      'reporterId': 5,
      'reporterName': 'John Smith',
      'reason': 'Inappropriate content',
      'details': 'The event description contains offensive language.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      'eventId': 3,
      'reporterId': 8,
      'reporterName': 'Emily Johnson',
      'reason': 'Misleading information',
      'details': 'The event location doesn\'t match the description.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 12)),
    },
    {
      'eventId': 5,
      'reporterId': 12,
      'reporterName': 'Michael Brown',
      'reason': 'Scam/fraud',
      'details':
          'This event appears to be collecting payment without intention to deliver.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    // In a real app, we would fetch these from the API
    _allEvents = await _eventRepository.getAllEvents();

    // Mock the reported events by using the report data
    _reportedEvents = _allEvents
        .where((event) =>
            _reportData.any((report) => report['eventId'] == event.id))
        .toList();

    // Mock the featured events
    _featuredEvents = _allEvents.where((event) => event.isFeatured).toList();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Moderation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Reported'),
            Tab(text: 'Featured'),
            Tab(text: 'All Events'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReportedEventsTab(),
                _buildFeaturedEventsTab(),
                _buildAllEventsTab(),
              ],
            ),
    );
  }

  Widget _buildEventListItem(EventModel event) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: event.posterImage != null
                ? Image.network(
                    event.posterImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.image, color: Colors.grey, size: 32),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.locationName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'By: ${event.promotorId}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
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

  Widget _buildReportedEventsTab() {
    if (_reportedEvents.isEmpty) {
      return const Center(
        child: Text('No reported events'),
      );
    }

    return ListView.builder(
      itemCount: _reportedEvents.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final event = _reportedEvents[index];
        final report = _reportData.firstWhere(
          (r) => r['eventId'] == event.id,
          orElse: () => {'reason': 'Unknown', 'details': 'No details provided'},
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildEventListItem(event),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.report_problem,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reported for: ${report['reason']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Details: ${report['details']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reported by: ${report['reporterName']} - ${_formatDateTime(report['timestamp'])}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => _dismissReport(event, report),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: const Text('Dismiss Report'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _showRemoveEventDialog(event),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: const Text('Remove Event'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedEventsTab() {
    if (_featuredEvents.isEmpty) {
      return const Center(
        child: Text('No featured events'),
      );
    }

    return ListView.builder(
      itemCount: _featuredEvents.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final event = _featuredEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildEventListItem(event),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Featured since: ${_formatDate(event.startDate.subtract(const Duration(days: 7)))}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _unfeatureEvent(event),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Remove from Featured'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllEventsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              // Implement search functionality
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _allEvents.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final event = _allEvents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildEventListItem(event),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!event.isFeatured)
                            OutlinedButton(
                              onPressed: () => _featureEvent(event),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.amber[700],
                                side: BorderSide(color: Colors.amber[700]!),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              child: const Text('Feature'),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => _unfeatureEvent(event),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey,
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              child: const Text('Unfeature'),
                            ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _showRemoveEventDialog(event),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Remove'),
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
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _featureEvent(EventModel event) {
    setState(() {
      // In a real app, this would make an API call
      final index = _allEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        final updatedEvent = event.copyWith(isFeatured: true);
        _allEvents[index] = updatedEvent;

        // Add to featured events
        if (!_featuredEvents.any((e) => e.id == event.id)) {
          _featuredEvents.add(updatedEvent);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${event.title} has been featured'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _unfeatureEvent(EventModel event) {
    setState(() {
      // In a real app, this would make an API call
      final index = _allEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        final updatedEvent = event.copyWith(isFeatured: false);
        _allEvents[index] = updatedEvent;

        // Remove from featured events
        _featuredEvents.removeWhere((e) => e.id == event.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${event.title} has been removed from featured'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _dismissReport(EventModel event, Map<String, dynamic> report) {
    setState(() {
      // In a real app, this would make an API call to dismiss the report
      // For now, we'll just remove the report from our local data
      _reportData.removeWhere((r) =>
          r['eventId'] == event.id && r['reporterId'] == report['reporterId']);

      // Also remove the event from reported events if there are no more reports
      if (!_reportData.any((r) => r['eventId'] == event.id)) {
        _reportedEvents.removeWhere((e) => e.id == event.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report for ${event.title} has been dismissed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showRemoveEventDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to remove "${event.title}"?'),
            const SizedBox(height: 16),
            const Text('Please provide a reason:'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Reason for removal',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _removeEvent(EventModel event) {
    setState(() {
      // In a real app, this would make an API call
      _allEvents.removeWhere((e) => e.id == event.id);
      _featuredEvents.removeWhere((e) => e.id == event.id);
      _reportedEvents.removeWhere((e) => e.id == event.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${event.title} has been removed'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
