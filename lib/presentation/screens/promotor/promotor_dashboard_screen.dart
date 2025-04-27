import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/event_model.dart';
import '../../../data/repositories/mock_event_repository.dart';
import '../../../core/config/app_router.dart';
import 'event_creation_screen.dart';
import 'event_management_screen.dart';
import 'analytics_dashboard_screen.dart';

class PromotorDashboardScreen extends StatefulWidget {
  const PromotorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PromotorDashboardScreen> createState() =>
      _PromotorDashboardScreenState();
}

class _PromotorDashboardScreenState extends State<PromotorDashboardScreen> {
  final MockEventRepository _eventRepository = MockEventRepository();
  List<EventModel> _promotorEvents = [];
  bool _isLoading = true;

  // Mock data for earnings
  final Map<String, double> _monthlyEarnings = {
    'Jan': 450.0,
    'Feb': 780.0,
    'Mar': 520.0,
    'Apr': 890.0,
    'May': 670.0,
    'Jun': 1250.0,
  };

  @override
  void initState() {
    super.initState();
    _loadPromotorEvents();
  }

  Future<void> _loadPromotorEvents() async {
    setState(() {
      _isLoading = true;
    });

    // Mock promotor ID - in a real app, this would come from auth
    const int promotorId = 2;

    try {
      final events = await _eventRepository.getEventsByPromoter(promotorId);
      setState(() {
        _promotorEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load events: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promoter Dashboard'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPromotorEvents,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildEarningsChart(),
                    const SizedBox(height: 20),
                    _buildUpcomingEventsSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          // Navigate to event creation screen
          Navigator.pushNamed(context, AppRouter.eventCreation);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.business, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back, Live Nation!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'You have ${_promotorEvents.length} active events',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  icon: Icons.people,
                  value: _promotorEvents
                      .fold(
                        0,
                        (sum, event) => sum + (event.totalAttendees ?? 0),
                      )
                      .toString(),
                  label: 'Attendees',
                ),
                _buildStatCard(
                  icon: Icons.event,
                  value: _promotorEvents.length.toString(),
                  label: 'Events',
                ),
                _buildStatCard(
                  icon: Icons.visibility,
                  value: _promotorEvents
                      .fold(0, (sum, event) => sum + event.viewsCount)
                      .toString(),
                  label: 'Views',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Create Event',
                icon: Icons.add_circle,
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.eventCreation);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Manage Events',
                icon: Icons.event_note,
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.eventManagement);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'View Earnings',
                icon: Icons.attach_money,
                color: Colors.amber,
                onTap: () {
                  // Navigate to earnings page
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Edit Profile',
                icon: Icons.business,
                color: Colors.purple,
                onTap: () {
                  // Navigate to profile edit page
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: _buildSimpleBarChart()),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Earnings:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '\$${_monthlyEarnings.values.fold(0.0, (sum, value) => sum + value).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    final double maxValue = _monthlyEarnings.values.reduce(
      (a, b) => a > b ? a : b,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _monthlyEarnings.entries.map((entry) {
        final double percentage = entry.value / maxValue;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${entry.value.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 150 * percentage,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(entry.key, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingEventsSection() {
    final upcomingEvents = _promotorEvents
        .where((e) => e.startDate.isAfter(DateTime.now()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Upcoming Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.eventManagement);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (upcomingEvents.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No upcoming events. Create a new event to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingEvents.length > 3 ? 3 : upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = upcomingEvents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: event.posterImage != null
                        ? Image.network(
                            event.posterImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.event,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        _eventRepository.formatDateTime(event.startDate),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${event.totalAttendees ?? 0}${event.maxAttendees != null ? '/${event.maxAttendees}' : ''}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      // Navigate to event details/edit page
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNavigationItems() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildNavigationItem(
            icon: Icons.add_box_outlined,
            label: 'Create Event',
            onTap: () {
              Navigator.pushNamed(context, AppRouter.eventCreation);
            },
          ),
          _buildNavigationItem(
            icon: Icons.event_available_outlined,
            label: 'My Events',
            onTap: () {
              Navigator.pushNamed(context, '/promotor/my-events');
            },
          ),
          _buildNavigationItem(
            icon: Icons.people_outline,
            label: 'Attendee Management',
            onTap: () {
              // Navigate to attendee management
            },
          ),
          _buildNavigationItem(
            icon: Icons.analytics_outlined,
            label: 'Analytics Dashboard',
            onTap: () {
              // Navigate to analytics dashboard with a sample event ID
              Navigator.pushNamed(
                context,
                AppRouter.analytics,
                arguments: 'event123',
              );
            },
          ),
          _buildNavigationItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Earnings',
            onTap: () {
              // Navigate to earnings
            },
          ),
          _buildNavigationItem(
            icon: Icons.comment_outlined,
            label: 'Comments',
            onTap: () {
              // Navigate to comments
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
