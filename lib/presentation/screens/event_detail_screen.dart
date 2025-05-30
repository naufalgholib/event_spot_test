import 'package:flutter/material.dart';
import '../../data/models/event_model.dart';
import '../../data/services/event_service.dart';
import '../../core/config/app_constants.dart';
import '../widgets/event_card.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  EventModel? _event;
  Map<String, dynamic>? _attendanceDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final event = await _eventService.getEventDetail(widget.eventId);
      final attendanceDetails =
          await _eventService.getAttendanceDetails(widget.eventId);

      if (mounted) {
        setState(() {
          _event = event;
          _attendanceDetails = attendanceDetails;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _event == null) {
      return Scaffold(
        body: Center(
          child: Text(_error ?? 'Failed to load event details'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ... other widgets ...
          SliverToBoxAdapter(
            child: EventCard(
              event: _event!,
              status: _attendanceDetails?['status'],
              showStatus: true,
            ),
          ),
          // ... other widgets ...
        ],
      ),
    );
  }
}
