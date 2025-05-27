import '../../data/models/event_model.dart';
import '../../data/models/category_model.dart';
import 'package:intl/intl.dart';

class MockEventRepository {
  // Mock list of categories
  final List<CategoryModel> _categories = [
    CategoryModel(
      id: 1,
      name: 'Music',
      description: 'Music concerts and festivals',
      icon: 'music-note',
    ),
    CategoryModel(
      id: 2,
      name: 'Business',
      description: 'Business conferences and networking',
      icon: 'briefcase',
    ),
    CategoryModel(
      id: 3,
      name: 'Technology',
      description: 'Tech meetups and conferences',
      icon: 'laptop',
    ),
    CategoryModel(
      id: 4,
      name: 'Art',
      description: 'Art exhibitions and workshops',
      icon: 'palette',
    ),
    CategoryModel(
      id: 5,
      name: 'Sports',
      description: 'Sports events and tournaments',
      icon: 'football',
    ),
    CategoryModel(
      id: 6,
      name: 'Food',
      description: 'Food festivals and culinary events',
      icon: 'utensils',
    ),
    CategoryModel(
      id: 7,
      name: 'Education',
      description: 'Educational workshops and seminars',
      icon: 'graduation-cap',
    ),
    CategoryModel(
      id: 8,
      name: 'Health',
      description: 'Health and wellness events',
      icon: 'heart-pulse',
    ),
  ];

  // Mock list of events
  final List<EventModel> _events = [
    EventModel(
      id: 1,
      title: 'Music Festival 2023',
      slug: 'music-festival-2023',
      description:
          'A three-day music festival featuring top artists from around the world. Join us for an unforgettable experience with great music, food, and fun activities.',
      posterImage:
          'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      promotorId: 2,
      promotorName: 'Live Nation',
      categoryId: 1,
      categoryName: 'Music',
      locationName: 'Central Park',
      address: '14 E 60th St, New York, NY 10022',
      latitude: 40.767778,
      longitude: -73.9718,
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 13)),
      registrationStart: DateTime.now().subtract(const Duration(days: 30)),
      registrationEnd: DateTime.now().add(const Duration(days: 5)),
      isFree: false,
      price: 149.99,
      maxAttendees: 500,
      isPublished: true,
      isFeatured: true,
      isApproved: true,
      viewsCount: 1250,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      totalAttendees: 250,
      images: [
        EventImage(
          id: 1,
          eventId: 1,
          imagePath:
              'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
          isPrimary: true,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        EventImage(
          id: 2,
          eventId: 1,
          imagePath:
              'https://images.unsplash.com/photo-1506157786151-b8491531f063?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
          isPrimary: false,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
      ],
      tags: [
        EventTag(
          id: 1,
          name: 'Festival',
          slug: 'festival',
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
        EventTag(
          id: 2,
          name: 'Concert',
          slug: 'concert',
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
      ],
    ),
    EventModel(
      id: 2,
      title: 'Tech Conference 2023',
      slug: 'tech-conference-2023',
      description:
          'Join us for the biggest tech conference of the year. Learn from industry experts, network with professionals, and discover the latest innovations.',
      posterImage:
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      promotorId: 4,
      promotorName: 'TechEvents Co',
      categoryId: 3,
      categoryName: 'Technology',
      locationName: 'Convention Center',
      address: '747 Howard St, San Francisco, CA 94103',
      latitude: 37.784172,
      longitude: -122.401558,
      startDate: DateTime.now().add(const Duration(days: 20)),
      endDate: DateTime.now().add(const Duration(days: 22)),
      registrationStart: DateTime.now().subtract(const Duration(days: 60)),
      registrationEnd: DateTime.now().add(const Duration(days: 15)),
      isFree: false,
      price: 299.99,
      maxAttendees: 1000,
      isPublished: true,
      isFeatured: true,
      isApproved: true,
      viewsCount: 3450,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      totalAttendees: 420,
      images: [
        EventImage(
          id: 3,
          eventId: 2,
          imagePath:
              'https://images.unsplash.com/photo-1540575467063-178a50c2df87?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
          isPrimary: true,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
      ],
      tags: [
        EventTag(
          id: 3,
          name: 'Technology',
          slug: 'technology',
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
        EventTag(
          id: 4,
          name: 'Conference',
          slug: 'conference',
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
      ],
    ),
    EventModel(
      id: 3,
      title: 'Charity Run',
      slug: 'charity-run',
      description:
          'Run for a cause! Join our annual charity run to raise funds for children in need. All proceeds go directly to helping children access education and healthcare.',
      posterImage:
          'https://images.unsplash.com/photo-1609710228159-0fa9bd7c0827?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      promotorId: 3,
      promotorName: 'HelpingHands Charity',
      categoryId: 5,
      categoryName: 'Sports',
      locationName: 'Riverfront Park',
      address: '300 N Wabash Ave, Chicago, IL 60611',
      latitude: 41.886833,
      longitude: -87.626805,
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 5, hours: 6)),
      registrationStart: DateTime.now().subtract(const Duration(days: 60)),
      registrationEnd: DateTime.now().add(const Duration(days: 3)),
      isFree: true,
      maxAttendees: 300,
      isPublished: true,
      isFeatured: false,
      isApproved: true,
      viewsCount: 950,
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      totalAttendees: 150,
    ),
    EventModel(
      id: 4,
      title: 'Cooking Workshop',
      slug: 'cooking-workshop',
      description:
          'Learn to cook authentic Italian cuisine with our expert chef. This hands-on workshop will teach you the secrets of making perfect pasta, delicious sauces, and classic Italian desserts.',
      posterImage:
          'https://images.unsplash.com/photo-1556911220-bff31c812dba?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      promotorId: 4,
      promotorName: 'Gourmet Events',
      categoryId: 6,
      categoryName: 'Food',
      locationName: 'Culinary Institute',
      address: '521 W 26th St, Los Angeles, CA 90007',
      latitude: 34.051976,
      longitude: -118.275545,
      startDate: DateTime.now().add(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 15, hours: 4)),
      registrationStart: DateTime.now().subtract(const Duration(days: 30)),
      registrationEnd: DateTime.now().add(const Duration(days: 14)),
      isFree: false,
      price: 79.99,
      maxAttendees: 20,
      isPublished: true,
      isFeatured: false,
      isApproved: true,
      viewsCount: 320,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      totalAttendees: 18,
    ),
    EventModel(
      id: 5,
      title: 'Art Exhibition: Modern Masters',
      slug: 'art-exhibition-modern-masters',
      description:
          'Explore the works of contemporary artists pushing the boundaries of modern art. This exhibition features paintings, sculptures, and digital art from around the world.',
      posterImage:
          'https://images.unsplash.com/photo-1531058020387-3be344556be6?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      promotorId: 5,
      promotorName: 'ArtSpace Gallery',
      categoryId: 4,
      categoryName: 'Art',
      locationName: 'Metropolitan Museum',
      address: '1000 Fifth Avenue, New York, NY 10028',
      latitude: 40.779437,
      longitude: -73.963244,
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 17)),
      registrationStart: DateTime.now().subtract(const Duration(days: 45)),
      registrationEnd: DateTime.now().add(const Duration(days: 16)),
      isFree: true,
      maxAttendees: 200,
      isPublished: true,
      isFeatured: false,
      isApproved: true,
      viewsCount: 870,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      totalAttendees: 85,
    ),
    EventModel(
      id: 6,
      title: 'Business Networking Mixer',
      slug: 'business-networking-mixer',
      description:
          'Connect with professionals from various industries at our monthly networking event. Perfect opportunity to expand your professional network and discover new business opportunities.',
      posterImage:
          'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      promotorId: 6,
      promotorName: 'Business Connect',
      categoryId: 2,
      categoryName: 'Business',
      locationName: 'Grand Hotel',
      address: '350 Washington St, Boston, MA 02108',
      latitude: 42.358431,
      longitude: -71.058083,
      startDate: DateTime.now().add(const Duration(days: 12)),
      endDate: DateTime.now().add(const Duration(days: 12, hours: 3)),
      registrationStart: DateTime.now().subtract(const Duration(days: 30)),
      registrationEnd: DateTime.now().add(const Duration(days: 11)),
      isFree: false,
      price: 25.99,
      maxAttendees: 100,
      isPublished: true,
      isFeatured: false,
      isApproved: true,
      viewsCount: 520,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      totalAttendees: 45,
    ),
    EventModel(
      id: 7,
      title: 'Science Fair 2023',
      slug: 'science-fair-2023',
      description:
          'A family-friendly event showcasing exciting science projects and experiments. Great for children and adults alike to learn about science in a fun, interactive way.',
      posterImage:
          'https://images.unsplash.com/photo-1580894742597-87bc8789db3d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      promotorId: 7,
      promotorName: 'Science Educators Association',
      categoryId: 7,
      categoryName: 'Education',
      locationName: 'Science Center',
      address: '200 2nd Ave N, Seattle, WA 98109',
      latitude: 47.619884,
      longitude: -122.3514387,
      startDate: DateTime.now().add(const Duration(days: 8)),
      endDate: DateTime.now().add(const Duration(days: 9)),
      registrationStart: DateTime.now().subtract(const Duration(days: 45)),
      registrationEnd: DateTime.now().add(const Duration(days: 7)),
      isFree: true,
      maxAttendees: 300,
      isPublished: true,
      isFeatured: false,
      isApproved: true,
      viewsCount: 780,
      createdAt: DateTime.now().subtract(const Duration(days: 70)),
      updatedAt: DateTime.now().subtract(const Duration(days: 35)),
      totalAttendees: 120,
    ),
    EventModel(
      id: 8,
      title: 'Yoga Retreat Weekend',
      slug: 'yoga-retreat-weekend',
      description:
          'A rejuvenating weekend of yoga, meditation, and wellness activities. Escape the city and connect with nature while improving your physical and mental wellbeing.',
      posterImage:
          'https://images.unsplash.com/photo-1545205597-3d9d02c29597?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      promotorId: 8,
      promotorName: 'Mindful Living',
      categoryId: 8,
      categoryName: 'Health',
      locationName: 'Mountain Retreat Center',
      address: '2250 Panorama Dr, Boulder, CO 80304',
      latitude: 40.022202,
      longitude: -105.302414,
      startDate: DateTime.now().add(const Duration(days: 18)),
      endDate: DateTime.now().add(const Duration(days: 20)),
      registrationStart: DateTime.now().subtract(const Duration(days: 60)),
      registrationEnd: DateTime.now().add(const Duration(days: 14)),
      isFree: false,
      price: 349.99,
      maxAttendees: 30,
      isPublished: true,
      isFeatured: false,
      isApproved: true,
      viewsCount: 430,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      totalAttendees: 25,
    ),
  ];

  // Get all events
  Future<List<EventModel>> getAllEvents() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _events;
  }

  // Get upcoming events
  Future<List<EventModel>> getUpcomingEvents() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final now = DateTime.now();
    return _events.where((event) => event.startDate.isAfter(now)).toList();
  }

  // Get event by id
  Future<EventModel?> getEventById(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get event by slug
  Future<EventModel?> getEventBySlug(String slug) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _events.firstWhere((event) => event.slug == slug);
    } catch (e) {
      return null;
    }
  }

  // Get events by category
  Future<List<EventModel>> getEventsByCategory(int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _events.where((event) => event.categoryId == categoryId).toList();
  }

  // Search events with filters
  Future<List<EventModel>> searchEvents({
    String? query,
    int? categoryId,
    String? dateRange,
    String? priceRange,
    String? sortBy = 'date_asc',
    bool onlyAvailable = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    var filteredEvents = List.of(_events);

    // Apply text search
    if (query != null && query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      filteredEvents = filteredEvents.where((event) {
        return event.title.toLowerCase().contains(lowercaseQuery) ||
            event.description.toLowerCase().contains(lowercaseQuery) ||
            event.locationName.toLowerCase().contains(lowercaseQuery) ||
            event.promotorName.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    // Filter by category
    if (categoryId != null) {
      filteredEvents = filteredEvents.where((event) {
        return event.categoryId == categoryId;
      }).toList();
    }

    // Filter by date range
    if (dateRange != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (dateRange) {
        case 'today':
          filteredEvents = filteredEvents.where((event) {
            final eventDate = DateTime(
              event.startDate.year,
              event.startDate.month,
              event.startDate.day,
            );
            return eventDate.isAtSameMomentAs(today);
          }).toList();
          break;

        case 'this_week':
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));

          filteredEvents = filteredEvents.where((event) {
            return event.startDate.isAfter(
                  weekStart.subtract(const Duration(days: 1)),
                ) &&
                event.startDate.isBefore(
                  weekEnd.add(const Duration(days: 1)),
                );
          }).toList();
          break;

        case 'this_month':
          final monthStart = DateTime(now.year, now.month, 1);
          final monthEnd = (now.month < 12)
              ? DateTime(now.year, now.month + 1, 0)
              : DateTime(now.year + 1, 1, 0);

          filteredEvents = filteredEvents.where((event) {
            return event.startDate.isAfter(
                  monthStart.subtract(const Duration(days: 1)),
                ) &&
                event.startDate.isBefore(
                  monthEnd.add(const Duration(days: 1)),
                );
          }).toList();
          break;
      }
    }

    // Filter by price range
    if (priceRange != null) {
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
    if (onlyAvailable) {
      filteredEvents = filteredEvents.where((event) {
        return !event.isFullCapacity &&
            event.registrationEnd.isAfter(DateTime.now()) &&
            event.isRegistrationOpen;
      }).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'date_asc':
        filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;

      case 'date_desc':
        filteredEvents.sort((a, b) => b.startDate.compareTo(a.startDate));
        break;

      case 'price_asc':
        filteredEvents.sort((a, b) {
          if (a.isFree && b.isFree) return 0;
          if (a.isFree) return -1;
          if (b.isFree) return 1;
          return (a.price ?? 0).compareTo(b.price ?? 0);
        });
        break;

      case 'price_desc':
        filteredEvents.sort((a, b) {
          if (a.isFree && b.isFree) return 0;
          if (a.isFree) return 1;
          if (b.isFree) return -1;
          return (b.price ?? 0).compareTo(a.price ?? 0);
        });
        break;

      case 'popular':
        filteredEvents.sort((a, b) {
          return (b.totalAttendees ?? 0).compareTo(a.totalAttendees ?? 0);
        });
        break;
    }

    return filteredEvents;
  }

  // Get events by promoter
  Future<List<EventModel>> getEventsByPromoter(int promoterId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _events.where((event) => event.promotorId == promoterId).toList();
  }

  // Toggle bookmark
  Future<EventModel> toggleBookmark(int eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      final event = _events[index];
      final updatedEvent = event.copyWith(isBookmarked: !event.isBookmarked);
      _events[index] = updatedEvent;
      return updatedEvent;
    }
    throw Exception('Event not found');
  }

  // Get all categories
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _categories;
  }

  // Get category by id
  Future<CategoryModel?> getCategoryById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category names
  Future<List<String>> getCategoryNames() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _categories.map((e) => e.name).toList();
  }

  // Format date for display
  String formatDate(DateTime date) {
    return DateFormat('E, MMM d, y').format(date);
  }

  // Format time for display
  String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  // Format date and time for display
  String formatDateTime(DateTime date) {
    return DateFormat('E, MMM d, y • h:mm a').format(date);
  }

  // Get registered events (events that the user has registered for)
  Future<List<EventModel>> getRegisteredEvents() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate fetching registered events
    // In a real app, this would query the backend for the current user's registrations
    return _events.where((event) => event.id % 3 == 0).toList();
  }

  // Get bookmarked events
  Future<List<EventModel>> getBookmarkedEvents() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate fetching bookmarked events
    // In a real app, this would query the backend for the current user's bookmarks
    return _events.where((event) => event.id % 4 == 0).toList();
  }
}
