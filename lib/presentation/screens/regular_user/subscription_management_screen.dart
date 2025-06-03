import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/subscription_service.dart';
import '../../widgets/common_widgets.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final TextEditingController _promoterSearchController =
      TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();

  List<UserModel> _followedPromoters = [];
  List<CategoryModel> _subscribedCategories = [];
  bool _isLoadingPromoters = true;
  bool _isLoadingCategories = true;
  String? _promotersError;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();
    _loadFollowedPromoters();
    _loadSubscribedCategories();
  }

  @override
  void dispose() {
    _promoterSearchController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowedPromoters() async {
    setState(() {
      _isLoadingPromoters = true;
      _promotersError = null;
    });

    try {
      final followedPromoters =
          await _subscriptionService.getFollowedPromoters();

      if (mounted) {
        setState(() {
          _followedPromoters = followedPromoters;
          _isLoadingPromoters = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _promotersError = e.toString();
          _isLoadingPromoters = false;
        });
      }
    }
  }

  Future<void> _loadSubscribedCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final subscribedCategories =
          await _subscriptionService.getSubscribedCategories();
      if (mounted) {
        setState(() {
          _subscribedCategories = subscribedCategories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesError = e.toString();
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _unfollowPromoter(UserModel promoter) async {
    try {
      await _subscriptionService.unfollowPromoter(promoter.id.toString());

      if (mounted) {
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

  Future<void> _unsubscribeFromCategory(CategoryModel category) async {
    try {
      await _subscriptionService
          .unsubscribeFromCategory(category.id.toString());
      if (mounted) {
        setState(() {
          _subscribedCategories.removeWhere((c) => c.id == category.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unsubscribed from ${category.name}'),
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
    if (_isLoadingPromoters) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_promotersError != null) {
      return ErrorStateWidget(
        message: _promotersError!,
        onRetry: _loadFollowedPromoters,
      );
    }

    if (_followedPromoters.isEmpty) {
      return const EmptyStateWidget(
        message: 'You are not following any promoters yet',
        icon: Icons.people_outline,
      );
    }

    final filteredPromoters = _followedPromoters.where((promoter) {
      final searchQuery = _promoterSearchController.text.toLowerCase();
      if (searchQuery.isEmpty) return true;
      return promoter.name.toLowerCase().contains(searchQuery) ||
          (promoter.promoterDetail?.companyName?.toLowerCase() ?? '')
              .contains(searchQuery);
    }).toList();

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
            onChanged: (value) => setState(() {}),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredPromoters.length,
            itemBuilder: (context, index) {
              final promoter = filteredPromoters[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: promoter.profilePicture != null &&
                          promoter.profilePicture!.isNotEmpty
                      ? NetworkImage(promoter.profilePicture!)
                      : null,
                  child: promoter.profilePicture == null ||
                          promoter.profilePicture!.isEmpty
                      ? Text(promoter.name.isNotEmpty ? promoter.name[0] : 'P')
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
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Notification toggle TBD')));
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
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categoriesError != null) {
      return ErrorStateWidget(
        message: _categoriesError!,
        onRetry: _loadSubscribedCategories,
      );
    }

    if (_subscribedCategories.isEmpty) {
      return const EmptyStateWidget(
        message: 'You are not subscribed to any categories yet',
        icon: Icons.category_outlined,
      );
    }

    final filteredCategories = _subscribedCategories.where((category) {
      final searchQuery = _categorySearchController.text.toLowerCase();
      if (searchQuery.isEmpty) return true;
      return category.name.toLowerCase().contains(searchQuery);
    }).toList();

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
            onChanged: (value) => setState(() {}),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              final category = filteredCategories[index];
              return ListTile(
                leading: Icon(
                  _getCategoryIcon(category.name),
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(category.name),
                subtitle: Text(category.description.isNotEmpty
                    ? category.description
                    : '${index + 3} upcoming events'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_active),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Notification toggle TBD')));
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Navigate to ${category.name} events TBD')));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'music':
        return Icons.music_note;
      case 'art':
        return Icons.palette;
      case 'sports':
        return Icons.sports_soccer;
      case 'business':
        return Icons.business_center;
      default:
        return Icons.category;
    }
  }

  void _showUnsubscribeDialog(dynamic item, {bool isCategory = false}) {
    final name = isCategory
        ? (item as CategoryModel).name
        : ((item as UserModel).promoterDetail?.companyName ?? item.name);

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
                _unsubscribeFromCategory(item as CategoryModel);
              } else {
                _unfollowPromoter(item as UserModel);
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
