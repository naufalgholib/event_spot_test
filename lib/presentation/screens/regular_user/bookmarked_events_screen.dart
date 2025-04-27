import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_router.dart';
import '../../../core/config/app_constants.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/mock_event_repository.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/event_card.dart';

class BookmarkedEventsScreen extends StatefulWidget {
  const BookmarkedEventsScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkedEventsScreen> createState() => _BookmarkedEventsScreenState();
}

class _BookmarkedEventsScreenState extends State<BookmarkedEventsScreen> {
  final MockEventRepository _eventRepository = MockEventRepository();
  bool _isLoading = true;
  List<EventModel>? _bookmarkedEvents;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedEvents();
  }

  Future<void> _loadBookmarkedEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookmarked = await _eventRepository.getBookmarkedEvents();

      if (mounted) {
        setState(() {
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
    Navigator.pushNamed(
      context,
      AppRouter.eventDetail,
      arguments: event.id,
    ).then((_) => _loadBookmarkedEvents()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Events'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorStateWidget(
                  message: _error!,
                  onRetry: _loadBookmarkedEvents,
                )
              : _buildEventList(),
    );
  }

  Widget _buildEventList() {
    if (_bookmarkedEvents == null || _bookmarkedEvents!.isEmpty) {
      return EmptyStateWidget(
        message: 'You have no bookmarked events',
        icon: Icons.bookmark_border,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _bookmarkedEvents!.length,
      itemBuilder: (context, index) {
        final event = _bookmarkedEvents![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EventCard(
            event: event,
            onTap: () => _onEventTapped(event),
            showBookmarkButton: true,
          ),
        );
      },
    );
  }
}
