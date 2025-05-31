import 'package:flutter/material.dart';
import 'package:event_spot/core/theme/app_theme.dart';
import 'package:event_spot/core/config/app_router.dart';
import 'package:provider/provider.dart';
import 'package:event_spot/core/providers/auth_provider.dart';
import 'package:event_spot/data/models/user_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Sample data for dashboard stats
  final Map<String, int> _dashboardStats = {
    'Users': 1245,
    'Events': 72,
    'Promoters': 38,
    'Categories': 12,
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
      ),
      drawer: _buildDrawer(currentUser),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 32),
              _buildNavigationSection(),
              const SizedBox(height: 32),
              _buildRecentActivitySection(),
            ],
          ),
        ),
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
                  currentUser?.name ?? 'Admin User',
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
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRouter.admin);
            },
          ),
          // Admin Sections
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('User Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.adminUsers);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Event Moderation'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.adminEvents);
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Promoter Verification'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.adminPromoters);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Category Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.adminCategories);
            },
          ),
          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text('Tag Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.adminTags);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Platform Statistics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.adminStatistics);
            },
          ),
          // General Options
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
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Welcome, Admin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your platform effectively',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: _dashboardStats.length,
      itemBuilder: (context, index) {
        final entry = _dashboardStats.entries.elementAt(index);
        return _buildStatCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildStatCard(String title, int count) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Platform Management',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: 7,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return _buildNavigationCard(
                  'User Management',
                  Icons.people,
                  () => Navigator.pushNamed(context, AppRouter.adminUsers),
                );
              case 1:
                return _buildNavigationCard(
                  'Event Moderation',
                  Icons.event,
                  () => Navigator.pushNamed(context, AppRouter.adminEvents),
                );
              case 2:
                return _buildNavigationCard(
                  'Promoter Verification',
                  Icons.verified_user,
                  () => Navigator.pushNamed(context, AppRouter.adminPromoters),
                );
              case 3:
                return _buildNavigationCard(
                  'Category Management',
                  Icons.category,
                  () => Navigator.pushNamed(context, AppRouter.adminCategories),
                );
              case 4:
                return _buildNavigationCard(
                  'Tag Management',
                  Icons.tag,
                  () => Navigator.pushNamed(context, AppRouter.adminTags),
                );
              case 5:
                return _buildNavigationCard(
                  'Platform Statistics',
                  Icons.bar_chart,
                  () => Navigator.pushNamed(context, AppRouter.adminStatistics),
                );
              case 6:
                return _buildNavigationCard(
                  'System Settings',
                  Icons.settings,
                  () => Navigator.pushNamed(context, AppRouter.adminSettings),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavigationCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    // Sample recent activities
    final List<Map<String, dynamic>> recentActivities = [
      {
        'action': 'New user registration',
        'time': '10 minutes ago',
        'icon': Icons.person_add,
      },
      {
        'action': 'Event reported',
        'time': '1 hour ago',
        'icon': Icons.report_problem,
      },
      {
        'action': 'Promoter verification request',
        'time': '3 hours ago',
        'icon': Icons.verified_user,
      },
      {
        'action': 'Category added',
        'time': '5 hours ago',
        'icon': Icons.category,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Recent Activity',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentActivities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = recentActivities[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    activity['icon'],
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(
                  activity['action'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  activity['time'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
