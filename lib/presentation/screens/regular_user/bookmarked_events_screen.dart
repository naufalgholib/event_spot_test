import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/event_card.dart';

class BookmarkedEventsScreen extends StatefulWidget {
  const BookmarkedEventsScreen({super.key});

  @override
  State<BookmarkedEventsScreen> createState() => _BookmarkedEventsScreenState();
}

class _BookmarkedEventsScreenState extends State<BookmarkedEventsScreen> {
  final EventService _eventService = EventService();
  List<EventModel>? _bookmarkedEvents;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        throw Exception('Please log in to view your bookmarked events');
      }

      try {
        final bookmarked = await _eventService.getBookmarkedEvents();
        setState(() {
          _bookmarkedEvents = bookmarked;
        });
      } catch (e) {
        // If error is about no events, just set empty list
        if (e.toString().contains('Failed to load bookmarked events')) {
          setState(() {
            _bookmarkedEvents = [];
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
        title: const Text('Bookmarked Events'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _loadData)
              : _buildEventList(),
    );
  }

  Widget _buildEventList() {
    if (_bookmarkedEvents == null || _bookmarkedEvents!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarked events yet.\nFind and bookmark events to see them here!',
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
      itemCount: _bookmarkedEvents!.length,
      itemBuilder: (context, index) {
        final event = _bookmarkedEvents![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EventCard(
            event: event,
            onTap: () => _onEventTapped(event),
            onBookmarkChanged: (isBookmarked) {
              setState(() {
                if (!isBookmarked) {
                  _bookmarkedEvents!.removeAt(index);
                }
              });
            },
          ),
        );
      },
    );
  }
}
