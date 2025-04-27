import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:event_spot/core/theme/app_theme.dart';
import 'package:event_spot/core/utils/size_config.dart';
import 'package:event_spot/domain/entities/event.dart';
import 'package:event_spot/presentation/widgets/custom_app_bar.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  final String eventId;

  const AnalyticsDashboardScreen({Key? key, required this.eventId})
      : super(key: key);

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  late Event _event;
  bool _isLoading = true;
  String _timeRange = 'Week';
  final List<String> _timeRanges = ['Day', 'Week', 'Month', 'Year', 'All Time'];

  // Mock data for analytics
  final Map<String, dynamic> _analyticsData = {
    'totalAttendees': 342,
    'registeredToday': 15,
    'ticketSales': 14256.00,
    'dailyVisits': 532,
    'conversionRate': 4.8,
    'attendeesByGender': {'Male': 45, 'Female': 55},
    'attendeesByAge': {
      '18-24': 22,
      '25-34': 38,
      '35-44': 25,
      '45-54': 10,
      '55+': 5,
    },
    'ticketsSoldByType': {
      'VIP': 24,
      'Standard': 98,
      'Group': 45,
      'Early Bird': 120,
    },
    'salesOverTime': [
      {'date': 'Jan 1', 'sales': 1200},
      {'date': 'Jan 2', 'sales': 1800},
      {'date': 'Jan 3', 'sales': 1400},
      {'date': 'Jan 4', 'sales': 2200},
      {'date': 'Jan 5', 'sales': 1600},
      {'date': 'Jan 6', 'sales': 2800},
      {'date': 'Jan 7', 'sales': 3200},
    ],
    'trafficSources': {
      'Direct': 35,
      'Social Media': 40,
      'Email': 15,
      'Search': 10,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    // In a real app, you would fetch the event data from a repository
    await Future.delayed(const Duration(seconds: 1));

    _event = Event(
      id: widget.eventId,
      title: 'Tech Conference 2023',
      description: 'The biggest tech event of the year',
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 32)),
      location: 'Convention Center, New York',
      imageUrl: 'assets/images/event_cover.jpg',
      organizerId: 'org123',
      ticketPrice: 99.99,
      category: 'Technology',
      status: 'upcoming',
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: const CustomAppBar(
          title: 'Analytics Dashboard', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _event.title,
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 6,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          _buildTimeRangeSelector(),
          SizedBox(height: SizeConfig.safeBlockVertical * 3),
          _buildOverviewCards(),
          SizedBox(height: SizeConfig.safeBlockVertical * 3),
          _buildSalesChart(),
          SizedBox(height: SizeConfig.safeBlockVertical * 3),
          _buildAttendeeInsights(),
          SizedBox(height: SizeConfig.safeBlockVertical * 3),
          _buildTicketSalesByType(),
          SizedBox(height: SizeConfig.safeBlockVertical * 3),
          _buildTrafficSourcesChart(),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SizedBox(
      height: SizeConfig.safeBlockVertical * 5,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeRanges.length,
        itemBuilder: (context, index) {
          final range = _timeRanges[index];
          final isSelected = range == _timeRange;

          return GestureDetector(
            onTap: () {
              setState(() {
                _timeRange = range;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: SizeConfig.safeBlockHorizontal * 3,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 4,
                vertical: SizeConfig.safeBlockVertical * 1,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.secondaryTextLight,
                ),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : AppTheme.secondaryTextLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: SizeConfig.safeBlockHorizontal * 3,
      mainAxisSpacing: SizeConfig.safeBlockVertical * 2,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildInfoCard(
          title: 'Total Attendees',
          value: _analyticsData['totalAttendees'].toString(),
          icon: Icons.people,
          color: AppTheme.primaryColor,
        ),
        _buildInfoCard(
          title: 'Registered Today',
          value: '+${_analyticsData['registeredToday']}',
          icon: Icons.person_add,
          color: Colors.green,
        ),
        _buildInfoCard(
          title: 'Ticket Sales',
          value: '\$${_analyticsData['ticketSales']}',
          icon: Icons.attach_money,
          color: Colors.amber,
        ),
        _buildInfoCard(
          title: 'Conversion Rate',
          value: '${_analyticsData['conversionRate']}%',
          icon: Icons.trending_up,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.secondaryTextLight,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                ),
              ),
              Icon(
                icon,
                color: color,
                size: SizeConfig.safeBlockHorizontal * 5,
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: SizeConfig.safeBlockHorizontal * 5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket Sales Over Time',
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 4,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 25,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppTheme.secondaryTextLight,
                            fontSize: SizeConfig.safeBlockHorizontal * 3,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() <
                                _analyticsData['salesOverTime'].length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _analyticsData['salesOverTime'][value.toInt()]
                                  ['date'],
                              style: TextStyle(
                                color: AppTheme.secondaryTextLight,
                                fontSize: SizeConfig.safeBlockHorizontal * 3,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      _analyticsData['salesOverTime'].length,
                      (index) => FlSpot(
                        index.toDouble(),
                        _analyticsData['salesOverTime'][index]['sales']
                            .toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeInsights() {
    return Row(
      children: [
        Expanded(
          child: _buildPieChart(
            title: 'Attendees By Gender',
            data: _analyticsData['attendeesByGender'],
            colors: [AppTheme.primaryColor, Colors.pink],
          ),
        ),
        SizedBox(width: SizeConfig.safeBlockHorizontal * 3),
        Expanded(
          child: _buildColumnChart(
            title: 'Attendees By Age',
            data: _analyticsData['attendeesByAge'],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart({
    required String title,
    required Map<String, dynamic> data,
    required List<Color> colors,
  }) {
    final pieData = data.entries.toList();
    final totalValue = pieData.fold<double>(
      0,
      (sum, item) => sum + item.value.toDouble(),
    );

    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 20,
            child: PieChart(
              PieChartData(
                sections: List.generate(pieData.length, (index) {
                  final item = pieData[index];
                  final value = item.value.toDouble();
                  final percentage = (value / totalValue * 100).toStringAsFixed(
                    1,
                  );

                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: value,
                    title: '$percentage%',
                    radius: SizeConfig.safeBlockHorizontal * 15,
                    titleStyle: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          Column(
            children: List.generate(pieData.length, (index) {
              final item = pieData[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: SizeConfig.safeBlockVertical * 1,
                ),
                child: Row(
                  children: [
                    Container(
                      width: SizeConfig.safeBlockHorizontal * 3,
                      height: SizeConfig.safeBlockHorizontal * 3,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
                    Text(
                      item.key,
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3,
                        color: AppTheme.secondaryTextLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item.value}',
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnChart({
    required String title,
    required Map<String, dynamic> data,
  }) {
    final chartData = data.entries.toList();

    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 20,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartData
                        .map((e) => e.value)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppTheme.secondaryTextLight,
                            fontSize: SizeConfig.safeBlockHorizontal * 2.5,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < chartData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              chartData[value.toInt()].key,
                              style: TextStyle(
                                color: AppTheme.secondaryTextLight,
                                fontSize: SizeConfig.safeBlockHorizontal * 2.5,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  chartData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: chartData[index].value.toDouble(),
                        color: AppTheme.primaryColor,
                        width: SizeConfig.safeBlockHorizontal * 4,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSalesByType() {
    final data = _analyticsData['ticketsSoldByType'];

    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tickets Sold By Type',
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 4,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          ...data.entries.map((entry) {
            final ticketType = entry.key;
            final ticketCount = entry.value;
            final totalTickets = data.values.fold<int>(
              0,
              (sum, value) => sum + value,
            );
            final percentage =
                (ticketCount / totalTickets * 100).toStringAsFixed(1);

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ticketType,
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '$ticketCount ($percentage%)',
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ticketCount / totalTickets,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                    minHeight: SizeConfig.safeBlockVertical * 1.5,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 1.5),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTrafficSourcesChart() {
    final data = _analyticsData['trafficSources'];
    final entries = data.entries.toList();
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    return Container(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Traffic Sources',
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 4,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: SizeConfig.safeBlockVertical * 20,
                  child: PieChart(
                    PieChartData(
                      sections: List.generate(entries.length, (index) {
                        final item = entries[index];
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: item.value.toDouble(),
                          title: '${item.value}%',
                          radius: SizeConfig.safeBlockHorizontal * 12,
                          titleStyle: TextStyle(
                            fontSize: SizeConfig.safeBlockHorizontal * 3,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                      sectionsSpace: 2,
                      centerSpaceRadius: SizeConfig.safeBlockHorizontal * 5,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.safeBlockHorizontal * 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(entries.length, (index) {
                      final item = entries[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: SizeConfig.safeBlockVertical * 1.5,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 3,
                              height: SizeConfig.safeBlockHorizontal * 3,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
                            Expanded(
                              child: Text(
                                item.key,
                                style: TextStyle(
                                  fontSize: SizeConfig.safeBlockHorizontal * 3,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
