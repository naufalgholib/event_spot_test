import 'package:flutter/material.dart';
import 'package:event_spot/core/theme/app_theme.dart';
import 'dart:math';

class PlatformStatisticsScreen extends StatefulWidget {
  const PlatformStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<PlatformStatisticsScreen> createState() =>
      _PlatformStatisticsScreenState();
}

class _PlatformStatisticsScreenState extends State<PlatformStatisticsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;

  // Mock data for statistics
  final Map<String, int> _platformOverview = {
    'Total Users': 3254,
    'Active Users': 1842,
    'New Users (30 days)': 283,
    'Total Events': 457,
    'Active Events': 126,
    'Total Registrations': 8925,
    'Total Promoters': 89,
    'Verified Promoters': 67,
  };

  // Mock data for monthly statistics
  final List<Map<String, dynamic>> _monthlyStats = [
    {'month': 'Jan', 'users': 45, 'events': 12, 'registrations': 230},
    {'month': 'Feb', 'users': 52, 'events': 15, 'registrations': 285},
    {'month': 'Mar', 'users': 64, 'events': 18, 'registrations': 320},
    {'month': 'Apr', 'users': 80, 'events': 22, 'registrations': 390},
    {'month': 'May', 'users': 95, 'events': 28, 'registrations': 450},
    {'month': 'Jun', 'users': 112, 'events': 32, 'registrations': 520},
    {'month': 'Jul', 'users': 128, 'events': 38, 'registrations': 610},
    {'month': 'Aug', 'users': 143, 'events': 42, 'registrations': 680},
    {'month': 'Sep', 'users': 160, 'events': 45, 'registrations': 750},
    {'month': 'Oct', 'users': 192, 'events': 52, 'registrations': 830},
    {'month': 'Nov', 'users': 230, 'events': 60, 'registrations': 920},
    {'month': 'Dec', 'users': 283, 'events': 70, 'registrations': 1040},
  ];

  // Mock data for top categories
  final List<Map<String, dynamic>> _categoryStats = [
    {'name': 'Music', 'events': 120, 'registrations': 2450, 'percentage': 27.5},
    {
      'name': 'Business',
      'events': 85,
      'registrations': 1820,
      'percentage': 20.4
    },
    {
      'name': 'Technology',
      'events': 72,
      'registrations': 1540,
      'percentage': 17.3
    },
    {
      'name': 'Food & Drink',
      'events': 58,
      'registrations': 1220,
      'percentage': 13.7
    },
    {'name': 'Sports', 'events': 42, 'registrations': 950, 'percentage': 10.6},
    {'name': 'Arts', 'events': 35, 'registrations': 645, 'percentage': 7.2},
    {'name': 'Health', 'events': 28, 'registrations': 420, 'percentage': 4.7},
    {'name': 'Other', 'events': 17, 'registrations': 280, 'percentage': 3.1},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'User Growth'),
            Tab(text: 'Event Analysis'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildUserGrowthTab(),
                _buildEventAnalysisTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Platform Overview'),
          const SizedBox(height: 16),
          _buildOverviewGrid(),
          const SizedBox(height: 24),
          _buildSectionTitle('Monthly Registrations'),
          const SizedBox(height: 16),
          _buildMonthlyRegistrationsChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('Top Categories'),
          const SizedBox(height: 16),
          _buildCategoriesTable(),
        ],
      ),
    );
  }

  Widget _buildUserGrowthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('User Growth'),
          const SizedBox(height: 16),
          _buildUserGrowthChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('New Users by Month'),
          const SizedBox(height: 16),
          _buildMonthlyNewUsersChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('User Activity'),
          const SizedBox(height: 16),
          _buildUserActivityStats(),
        ],
      ),
    );
  }

  Widget _buildEventAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Event Statistics'),
          const SizedBox(height: 16),
          _buildEventStatsGrid(),
          const SizedBox(height: 24),
          _buildSectionTitle('Events by Month'),
          const SizedBox(height: 16),
          _buildMonthlyEventsChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('Popular Event Times'),
          const SizedBox(height: 16),
          _buildPopularEventTimes(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOverviewGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _platformOverview.length,
      itemBuilder: (context, index) {
        final entry = _platformOverview.entries.elementAt(index);
        return _buildStatCard(entry.key, entry.value.toString());
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
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

  Widget _buildMonthlyRegistrationsChart() {
    return SizedBox(
      height: 250,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrations per Month',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildBarChart(_monthlyStats, 'registrations'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
                style: BorderStyle.solid,
              ),
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Events',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Registrations',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                ..._categoryStats.map((category) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(category['name']),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(category['events'].toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(category['registrations'].toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${category['percentage']}%'),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    return SizedBox(
      height: 250,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cumulative User Growth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildLineChart(_monthlyStats, 'users'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyNewUsersChart() {
    return SizedBox(
      height: 250,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Users per Month',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildBarChart(_monthlyStats, 'users'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserActivityStats() {
    // Mock data for user activity
    final Map<String, int> _userActivity = {
      'Average Registrations per User': 3,
      'Average Events Attended': 2,
      'Active Users Last 7 Days': 842,
      'Active Users Last 30 Days': 1842,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _userActivity.length,
      itemBuilder: (context, index) {
        final entry = _userActivity.entries.elementAt(index);
        return _buildStatCard(entry.key, entry.value.toString());
      },
    );
  }

  Widget _buildEventStatsGrid() {
    // Mock data for event statistics
    final Map<String, dynamic> _eventStats = {
      'Average Attendees per Event': 19,
      'Paid Events': '68%',
      'Free Events': '32%',
      'Upcoming Events': 78,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: _eventStats.length,
      itemBuilder: (context, index) {
        final entry = _eventStats.entries.elementAt(index);
        return _buildStatCard(entry.key, entry.value.toString());
      },
    );
  }

  Widget _buildMonthlyEventsChart() {
    return SizedBox(
      height: 250,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Events per Month',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildBarChart(_monthlyStats, 'events'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularEventTimes() {
    // Mock data for popular event times
    final List<Map<String, dynamic>> _popularTimes = [
      {'day': 'Monday', 'events': 42, 'color': Colors.blue.shade100},
      {'day': 'Tuesday', 'events': 58, 'color': Colors.blue.shade200},
      {'day': 'Wednesday', 'events': 65, 'color': Colors.blue.shade300},
      {'day': 'Thursday', 'events': 72, 'color': Colors.blue.shade400},
      {'day': 'Friday', 'events': 94, 'color': Colors.blue.shade500},
      {'day': 'Saturday', 'events': 127, 'color': Colors.blue.shade600},
      {'day': 'Sunday', 'events': 87, 'color': Colors.blue.shade500},
    ];

    return SizedBox(
      height: 200,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Popular Days for Events',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _popularTimes.length,
                  itemBuilder: (context, index) {
                    final item = _popularTimes[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item['events'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['day'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, String valueKey) {
    // Find the maximum value to scale the chart properly
    final double maxValue = data
        .map((item) => item[valueKey] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth =
            (constraints.maxWidth - (data.length - 1) * 8) / data.length;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.asMap().entries.map((entry) {
            final int index = entry.key;
            final Map<String, dynamic> item = entry.value;
            final double barHeight = (item[valueKey] as int) /
                maxValue *
                constraints.maxHeight *
                0.8;

            return Padding(
              padding: EdgeInsets.only(right: index < data.length - 1 ? 8 : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: barWidth,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.7),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: barWidth,
                    child: Text(
                      item['month'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data, String valueKey) {
    // This is a simple implementation - a real app would use a chart library
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        // Calculate accumulated values for cumulative chart
        int accumulatedValue = 0;
        final cumulativeData = data.map((item) {
          accumulatedValue += item[valueKey] as int;
          return {...item, 'cumulative': accumulatedValue};
        }).toList();

        final double maxValue = cumulativeData
            .map((item) => item['cumulative'] as int)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

        return CustomPaint(
          size: Size(width, height),
          painter: LineChartPainter(
            data: cumulativeData,
            maxValue: maxValue,
            valueKey: 'cumulative',
            lineColor: AppTheme.primaryColor,
          ),
        );
      },
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;
  final String valueKey;
  final Color lineColor;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.valueKey,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Paint fillPaint = Paint()
      ..color = lineColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Paint dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final double horizontalStep = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final value = (data[i][valueKey] as int).toDouble();
      final x = i * horizontalStep;
      final y = size.height - (value / maxValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw dots at each data point
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // Complete the fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
