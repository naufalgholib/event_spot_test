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
                      ? Icon(Icons.person, size: 30, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser?.name ?? 'Admin User',
                  style: TextStyle(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your platform effectively',
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
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Platform Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildNavigationCard(
              'User Management',
              Icons.people,
              () => Navigator.pushNamed(context, AppRouter.adminUsers),
            ),
            _buildNavigationCard(
              'Event Moderation',
              Icons.event,
              () => Navigator.pushNamed(context, AppRouter.adminEvents),
            ),
            _buildNavigationCard(
              'Promoter Verification',
              Icons.verified_user,
              () => Navigator.pushNamed(context, AppRouter.adminPromoters),
            ),
            _buildNavigationCard(
              'Category Management',
              Icons.category,
              () => Navigator.pushNamed(context, AppRouter.adminCategories),
            ),
            _buildNavigationCard(
              'Tag Management',
              Icons.tag,
              () => Navigator.pushNamed(context, AppRouter.adminTags),
            ),
            _buildNavigationCard(
              'Platform Statistics',
              Icons.bar_chart,
              () => Navigator.pushNamed(context, AppRouter.adminStatistics),
            ),
            _buildNavigationCard(
              'System Settings',
              Icons.settings,
              () => Navigator.pushNamed(context, AppRouter.adminSettings),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: AppTheme.primaryColor),
              const SizedBox(height: 12),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
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
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    activity['icon'],
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(activity['action']),
                subtitle: Text(activity['time']),
              );
            },
          ),
        ),
      ],
    );
  }
}
