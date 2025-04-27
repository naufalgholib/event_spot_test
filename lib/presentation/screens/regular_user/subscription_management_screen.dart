import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/mock_user_repository.dart';
import '../../widgets/common_widgets.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  final MockUserRepository _userRepository = MockUserRepository();
  final TextEditingController _promoterSearchController =
      TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();

  List<UserModel> _followedPromoters = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _followedCategories = [
    'Technology',
    'Music',
    'Art',
    'Sports',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    _loadFollowedPromoters();
  }

  @override
  void dispose() {
    _promoterSearchController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowedPromoters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('You must be logged in to view subscriptions');
      }

      final followedPromoters = await _userRepository.getFollowedPromoters(
        currentUser.id,
      );

      if (mounted) {
        setState(() {
          _followedPromoters = followedPromoters;
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

  Future<void> _unfollowPromoter(UserModel promoter) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        return;
      }

      final success = await _userRepository.unfollowPromoter(
        currentUser.id,
        promoter.id,
      );

      if (success && mounted) {
        setState(() {
          _followedPromoters.removeWhere((p) => p.id == promoter.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unfollowed ${promoter.name}'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Subscriptions'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Promoters'), Tab(text: 'Categories')],
          ),
        ),
        body: TabBarView(
          children: [_buildPromotersTab(), _buildCategoriesTab()],
        ),
      ),
    );
  }

  Widget _buildPromotersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ErrorStateWidget(
        message: _error!,
        onRetry: _loadFollowedPromoters,
      );
    }

    if (_followedPromoters.isEmpty) {
      return const EmptyStateWidget(
        message: 'You are not following any promoters yet',
        icon: Icons.people_outline,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _promoterSearchController,
            decoration: InputDecoration(
              hintText: 'Search promoters...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _followedPromoters.length,
            itemBuilder: (context, index) {
              final promoter = _followedPromoters[index];
              final searchQuery = _promoterSearchController.text.toLowerCase();

              if (searchQuery.isNotEmpty &&
                  !promoter.name.toLowerCase().contains(searchQuery) &&
                  !(promoter.promoterDetail?.companyName?.toLowerCase() ?? '')
                      .contains(searchQuery)) {
                return const SizedBox.shrink();
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: promoter.profilePicture != null
                      ? NetworkImage(promoter.profilePicture!)
                      : null,
                  child: promoter.profilePicture == null
                      ? Text(promoter.name[0])
                      : null,
                ),
                title: Text(
                  promoter.promoterDetail?.companyName ?? promoter.name,
                ),
                subtitle: promoter.promoterDetail?.companyName != null
                    ? Text('by ${promoter.name}')
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_active),
                      onPressed: () {
                        // TODO: Toggle notifications for this promoter
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        _showUnsubscribeDialog(promoter);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.promoterProfile,
                    arguments: promoter.id,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _categorySearchController,
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _followedCategories.length,
            itemBuilder: (context, index) {
              final category = _followedCategories[index];
              final searchQuery = _categorySearchController.text.toLowerCase();

              if (searchQuery.isNotEmpty &&
                  !category.toLowerCase().contains(searchQuery)) {
                return const SizedBox.shrink();
              }

              return ListTile(
                leading: Icon(
                  _getCategoryIcon(category),
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(category),
                subtitle: Text('${index + 3} upcoming events'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_active),
                      onPressed: () {
                        // TODO: Toggle notifications for this category
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        _showUnsubscribeDialog(category, isCategory: true);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // TODO: Navigate to category events
                },
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'music':
        return Icons.music_note;
      case 'art':
        return Icons.palette;
      case 'sports':
        return Icons.sports;
      case 'business':
        return Icons.business;
      default:
        return Icons.category;
    }
  }

  void _showUnsubscribeDialog(dynamic item, {bool isCategory = false}) {
    final name =
        isCategory ? item : (item.promoterDetail?.companyName ?? item.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsubscribe from $name?'),
        content: Text(
          isCategory
              ? 'You will no longer receive notifications about events in this category.'
              : 'You will no longer receive notifications from this promoter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isCategory) {
                setState(() {
                  _followedCategories.remove(item);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Unsubscribed from $name'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                _unfollowPromoter(item);
              }
            },
            child: const Text(
              'Unsubscribe',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
