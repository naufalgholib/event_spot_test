import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_constants.dart';
import '../../core/config/app_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../../data/repositories/mock_event_repository.dart';
import '../widgets/common_widgets.dart';

class PromoterProfileScreen extends StatefulWidget {
  final int promoterId;

  const PromoterProfileScreen({super.key, required this.promoterId});

  @override
  State<PromoterProfileScreen> createState() => _PromoterProfileScreenState();
}

class _PromoterProfileScreenState extends State<PromoterProfileScreen>
    with SingleTickerProviderStateMixin {
  final MockUserRepository _userRepository = MockUserRepository();
  final MockEventRepository _eventRepository = MockEventRepository();

  late TabController _tabController;
  UserModel? _promoter;
  List<EventModel>? _events;
  bool _isLoading = true;
  String? _error;
  bool _isFollowing = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final promoter = await _userRepository.getUserById(widget.promoterId);
      if (promoter == null || !promoter.isPromoter) {
        throw Exception('Promoter not found');
      }

      final events = await _eventRepository.getEventsByPromoter(
        widget.promoterId,
      );

      // Check if current user is following this promoter
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      bool isFollowing = false;

      if (currentUser != null) {
        isFollowing = await _userRepository.isFollowingPromoter(
          currentUser.id,
          widget.promoterId,
        );
      }

      if (mounted) {
        setState(() {
          _promoter = promoter;
          _events = events;
          _isFollowing = isFollowing;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load promoter profile. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to follow this promoter'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushNamed(context, AppRouter.login);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      bool success;
      if (_isFollowing) {
        success = await _userRepository.unfollowPromoter(
          currentUser.id,
          widget.promoterId,
        );
      } else {
        success = await _userRepository.followPromoter(
          currentUser.id,
          widget.promoterId,
        );
      }

      if (success && mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isFollowing
                    ? 'Now following ${_promoter?.name ?? "promoter"}'
                    : 'Unfollowed ${_promoter?.name ?? "promoter"}',
              ),
              backgroundColor: _isFollowing ? Colors.green : Colors.grey,
            ),
          );
        });
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
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onEventTapped(EventModel event) {
    Navigator.pushNamed(context, AppRouter.eventDetail, arguments: event.id);
  }

  Future<void> _launchUrl(String url) async {
    // TODO: Implement URL launching
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _loadData)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_promoter == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final promoterDetail = _promoter!.promoterDetail!;

    return NestedScrollView(
      headerSliverBuilder:
          (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Company Logo or Profile Picture
                    if (promoterDetail.companyLogo != null)
                      CachedNetworkImage(
                        imageUrl: promoterDetail.companyLogo!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) =>
                                Image.asset(AppConstants.placeholderImagePath),
                      )
                    else if (_promoter!.profilePicture != null)
                      CachedNetworkImage(
                        imageUrl: _promoter!.profilePicture!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) =>
                                Image.asset(AppConstants.placeholderImagePath),
                      )
                    else
                      Image.asset(AppConstants.placeholderImagePath),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Name or Promoter Name and Follow button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promoterDetail.companyName ?? _promoter!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (promoterDetail.companyName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'by ${_promoter!.name}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _toggleFollow,
                      icon: Icon(_isFollowing ? Icons.check : Icons.add),
                      label: Text(_isFollowing ? 'Following' : 'Follow'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isFollowing
                                ? Colors.grey[300]
                                : theme.colorScheme.primary,
                        foregroundColor:
                            _isFollowing
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Verification Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        promoterDetail.verificationStatus == 'verified'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        promoterDetail.verificationStatus == 'verified'
                            ? Icons.verified
                            : Icons.pending,
                        size: 16,
                        color:
                            promoterDetail.verificationStatus == 'verified'
                                ? Colors.green
                                : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        promoterDetail.verificationStatus == 'verified'
                            ? 'Verified Promoter'
                            : 'Verification Pending',
                        style: TextStyle(
                          color:
                              promoterDetail.verificationStatus == 'verified'
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                if (promoterDetail.description != null) ...[
                  Text(
                    promoterDetail.description!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Social Media Links
                if (promoterDetail.socialMedia != null &&
                    promoterDetail.socialMedia!.isNotEmpty)
                  Wrap(
                    spacing: 16,
                    children: [
                      if (promoterDetail.socialMedia!['facebook'] != null)
                        IconButton(
                          icon: const Icon(Icons.facebook),
                          onPressed:
                              () => _launchUrl(
                                promoterDetail.socialMedia!['facebook']!,
                              ),
                        ),
                      if (promoterDetail.socialMedia!['twitter'] != null)
                        IconButton(
                          icon: const Icon(Icons.flutter_dash),
                          onPressed:
                              () => _launchUrl(
                                promoterDetail.socialMedia!['twitter']!,
                              ),
                        ),
                      if (promoterDetail.socialMedia!['instagram'] != null)
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed:
                              () => _launchUrl(
                                promoterDetail.socialMedia!['instagram']!,
                              ),
                        ),
                      if (promoterDetail.socialMedia!['linkedin'] != null)
                        IconButton(
                          icon: const Icon(Icons.link),
                          onPressed:
                              () => _launchUrl(
                                promoterDetail.socialMedia!['linkedin']!,
                              ),
                        ),
                    ],
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Upcoming Events'),
              Tab(text: 'Past Events'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventList(upcoming: true),
                _buildEventList(upcoming: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList({required bool upcoming}) {
    if (_events == null || _events!.isEmpty) {
      return EmptyStateWidget(
        message: upcoming ? 'No upcoming events' : 'No past events',
        icon: Icons.event_busy,
      );
    }

    final now = DateTime.now();
    final filteredEvents =
        _events!
            .where(
              (event) =>
                  upcoming
                      ? event.startDate.isAfter(now)
                      : event.startDate.isBefore(now),
            )
            .toList();

    if (filteredEvents.isEmpty) {
      return EmptyStateWidget(
        message: upcoming ? 'No upcoming events' : 'No past events',
        icon: Icons.event_busy,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
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
}
