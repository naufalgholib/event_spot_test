import '../models/event_model.dart';
import '../services/event_service.dart';

class EventRepository {
  final EventService _eventService;

  EventRepository({EventService? eventService})
      : _eventService = eventService ?? EventService();

  Future<List<EventModel>> searchEvents({
    String? query,
    int? categoryId,
    String? dateRange,
    String? priceRange,
    String? sortBy,
    bool? onlyAvailable,
  }) async {
    try {
      // Get all events first
      final events = await _eventService.getEvents();

      // Apply filters
      var filteredEvents = events;

      // Filter by search query
      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        filteredEvents = filteredEvents.where((event) {
          return event.title.toLowerCase().contains(lowercaseQuery) ||
              event.description.toLowerCase().contains(lowercaseQuery) ||
              event.locationName.toLowerCase().contains(lowercaseQuery) ||
              event.categoryName.toLowerCase().contains(lowercaseQuery);
        }).toList();
      }

      // Filter by category
      if (categoryId != null) {
        filteredEvents = filteredEvents
            .where((event) => event.categoryId == categoryId)
            .toList();
      }

      // Filter by date range
      if (dateRange != null && dateRange != 'all') {
        final now = DateTime.now();
        switch (dateRange) {
          case 'today':
            filteredEvents = filteredEvents
                .where((event) =>
                    event.startDate.year == now.year &&
                    event.startDate.month == now.month &&
                    event.startDate.day == now.day)
                .toList();
            break;
          case 'tomorrow':
            final tomorrow = now.add(const Duration(days: 1));
            filteredEvents = filteredEvents
                .where((event) =>
                    event.startDate.year == tomorrow.year &&
                    event.startDate.month == tomorrow.month &&
                    event.startDate.day == tomorrow.day)
                .toList();
            break;
          case 'this_week':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            final weekEnd = weekStart.add(const Duration(days: 7));
            filteredEvents = filteredEvents
                .where((event) =>
                    event.startDate.isAfter(weekStart) &&
                    event.startDate.isBefore(weekEnd))
                .toList();
            break;
          case 'this_month':
            filteredEvents = filteredEvents
                .where((event) =>
                    event.startDate.year == now.year &&
                    event.startDate.month == now.month)
                .toList();
            break;
        }
      }

      // Filter by price range
      if (priceRange != null && priceRange != 'all') {
        switch (priceRange) {
          case 'free':
            filteredEvents =
                filteredEvents.where((event) => event.isFree).toList();
            break;
          case 'paid':
            filteredEvents =
                filteredEvents.where((event) => !event.isFree).toList();
            break;
        }
      }

      // Filter by availability
      if (onlyAvailable == true) {
        filteredEvents = filteredEvents
            .where((event) => !event.isFullCapacity && event.isRegistrationOpen)
            .toList();
      }

      // Sort results
      if (sortBy != null) {
        switch (sortBy) {
          case 'date_asc':
            filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
            break;
          case 'date_desc':
            filteredEvents.sort((a, b) => b.startDate.compareTo(a.startDate));
            break;
          case 'price_asc':
            filteredEvents.sort((a, b) {
              if (a.isFree && !b.isFree) return -1;
              if (!a.isFree && b.isFree) return 1;
              if (a.isFree && b.isFree) return 0;
              return (a.price ?? 0).compareTo(b.price ?? 0);
            });
            break;
          case 'price_desc':
            filteredEvents.sort((a, b) {
              if (a.isFree && !b.isFree) return -1;
              if (!a.isFree && b.isFree) return 1;
              if (a.isFree && b.isFree) return 0;
              return (b.price ?? 0).compareTo(a.price ?? 0);
            });
            break;
        }
      }

      return filteredEvents;
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    return await _eventService.getEvents();
  }

  Future<EventModel> getEventById(int id) async {
    return await _eventService.getEventDetail(id);
  }
}
