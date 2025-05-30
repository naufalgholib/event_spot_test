import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_router.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/category_service.dart';
import '../../../data/services/event_service.dart';
import '../../widgets/common_widgets.dart';
import 'event_search_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  final EventService _eventService = EventService();

  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  List<CategoryModel>? _categories;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _eventService.getEvents();
      final categories = await _categoryService.getCategories();

      if (mounted) {
        setState(() {
          _events = events;
          _filteredEvents = events;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _filterEvents(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredEvents = _events;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered = _events.where((event) {
      return event.title.toLowerCase().contains(lowercaseQuery) ||
          event.description.toLowerCase().contains(lowercaseQuery) ||
          event.locationName.toLowerCase().contains(lowercaseQuery) ||
          event.categoryName.toLowerCase().contains(lowercaseQuery);
    }).toList();

    setState(() {
      _filteredEvents = filtered;
    });
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredEvents = _events;
      });
    } else {
      _filterEvents(query);
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onEventTapped(EventModel event) {
    Navigator.pushNamed(context, AppRouter.eventDetail, arguments: event.id);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        categories: _categories ?? [],
        onApplyFilters: (filters) {
          // TODO: Apply filters
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      drawer: _buildDrawer(currentUser),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDrawer(UserModel? currentUser) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: currentUser?.profilePicture != null
                      ? NetworkImage(currentUser!.profilePicture!)
                      : null,
                  child: currentUser?.profilePicture == null
                      ? const Icon(Icons.person, size: 30, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser?.name ?? 'Guest User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (currentUser?.email != null)
                  Text(
                    currentUser!.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (currentUser != null) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.userProfile);
              },
            ),
            if (currentUser.userType == 'promotor')
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Promoter Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.promoterDashboard);
                },
              ),
            if (currentUser.userType == 'admin')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.adminDashboard);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('My Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.userEvents);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarked Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.bookmarkedEvents);
              },
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: const Text('My Subscriptions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.subscriptionManagement);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.userSettings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.aboutFAQ);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.contact);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.login);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Register'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.register);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.aboutFAQ);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.contact);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildExploreTab();
      case 2:
        return _buildSavedTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${currentUser?.name.split(' ').first ?? 'User'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Discover Events',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.notifications);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: EventSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              onFilterTap: _showFilterDialog,
            ),
          ),
          const SizedBox(height: 16),
          // Categories
          if (_categories != null)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                itemCount: _categories!.length,
                itemBuilder: (context, index) {
                  final category = _categories![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.searchResults,
                          arguments: {'categoryId': category.id},
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ErrorStateWidget(message: _error!, onRetry: _loadData);
    }

    if (_filteredEvents.isEmpty) {
      return const EmptyStateWidget(
        message: 'No events found',
        icon: Icons.event_busy,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SimpleEventCard(
            title: event.title,
            imageUrl: event.posterImage,
            location: event.locationName,
            date: DateFormat('E, MMM d, y').format(event.startDate),
            category: event.categoryName,
            isFree: event.isFree,
            onTap: () => _onEventTapped(event),
          ),
        );
      },
    );
  }

  Widget _buildExploreTab() {
    return const EventSearchScreen();
  }

  Widget _buildSavedTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Save Your Favorite Events',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Login to bookmark events and access them anytime',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.login);
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.register);
                },
                child: const Text('Create New Account'),
              ),
            ],
          ),
        ),
      );
    }

    if (currentUser.userType != 'user') {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Access Restricted',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This feature is only available for regular users. Please use a regular user account to access bookmarks.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<EventModel>>(
      future: _eventService.getBookmarkedEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorStateWidget(
            message: 'Failed to load bookmarked events: ${snapshot.error}',
            onRetry: () => setState(() {}),
          );
        }

        final bookmarkedEvents = snapshot.data ?? [];

        if (bookmarkedEvents.isEmpty) {
          return const EmptyStateWidget(
            message: 'No bookmarked events yet',
            icon: Icons.bookmark_border,
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bookmark,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'My Bookmarks',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have ${bookmarkedEvents.length} bookmarked events',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: bookmarkedEvents.length,
                itemBuilder: (context, index) {
                  final event = bookmarkedEvents[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SimpleEventCard(
                      title: event.title,
                      imageUrl: event.posterImage,
                      location: event.locationName,
                      date: DateFormat('E, MMM d, y').format(event.startDate),
                      category: event.categoryName,
                      isFree: event.isFree,
                      onTap: () => _onEventTapped(event),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Please login to view your profile',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.login);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return const UserProfileScreen();
  }
}

class FilterBottomSheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    required this.categories,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCategory;
  double _priceRange = 100;
  bool _freeEventsOnly = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Categories',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.categories.map((category) {
              return ChoiceChip(
                label: Text(category.name),
                selected: _selectedCategory == category.name,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category.name : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Price Range',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _freeEventsOnly,
                onChanged: (value) {
                  setState(() {
                    _freeEventsOnly = value ?? false;
                  });
                },
              ),
              const Text('Show only free events'),
            ],
          ),
          Slider(
            value: _priceRange,
            min: 0,
            max: 500,
            divisions: 10,
            label: '\$${_priceRange.round()}',
            onChanged: !_freeEventsOnly
                ? (value) {
                    setState(() {
                      _priceRange = value;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _priceRange = 100;
                    _freeEventsOnly = false;
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: const Text('Reset'),
              ),
              AppButton(
                text: 'Apply Filters',
                onPressed: () {
                  widget.onApplyFilters({
                    'category': _selectedCategory,
                    'priceRange': _priceRange,
                    'freeEventsOnly': _freeEventsOnly,
                    'startDate': _startDate,
                    'endDate': _endDate,
                  });
                },
                width: 150,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
