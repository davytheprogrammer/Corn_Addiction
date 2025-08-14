import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:corn_addiction/services/database.dart';
import 'package:corn_addiction/services/auth.dart';
import 'package:corn_addiction/models/streak_model.dart';
import 'package:corn_addiction/models/urge_log_model.dart';
import 'package:intl/intl.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<void> _dataFuture;
  
  StreakModel? _streak;
  List<UrgeLogModel> _urgeLogs = [];
  List<MapEntry<String, int>> _triggerCategories = [];
  Map<DateTime, int> _urgesByDate = {};
  
  int _totalDaysClean = 0;
  int _totalRelapses = 0;
  double _avgUrgeIntensity = 0;
  String _timeframe = 'week';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final database = DatabaseService(uid: AuthService().currentUser!.uid);
      
      // Get streak data
      final streak = await database.getCurrentStreak();
      
      // Get urge logs based on timeframe
      final urgeLogs = await database.getUrgeLogs(timeframe: _timeframe);
      
      // Process data
      _processData(streak, urgeLogs);
      
      setState(() {
        _streak = streak;
        _urgeLogs = urgeLogs;
      });
    } catch (e) {
      debugPrint('Error loading stats data: $e');
    }
  }
  
  void _processData(StreakModel? streak, List<UrgeLogModel> urgeLogs) {
    // Calculate stats
    _totalDaysClean = streak?.daysCount ?? 0;
    _totalRelapses = urgeLogs.where((log) => !log.wasResisted).length;
    
    if (urgeLogs.isNotEmpty) {
      _avgUrgeIntensity = urgeLogs.fold(0.0, 
        (sum, log) => sum + (log.intensity == UrgeIntensity.low ? 3 : 
                             log.intensity == UrgeIntensity.medium ? 5 : 
                             log.intensity == UrgeIntensity.high ? 7 : 9)) / urgeLogs.length;
    } else {
      _avgUrgeIntensity = 0;
    }
    
    // Process triggers
    final triggerCount = <String, int>{};
    for (final log in urgeLogs) {
      for (final trigger in log.triggers) {
        triggerCount[trigger] = (triggerCount[trigger] ?? 0) + 1;
      }
    }
    
    _triggerCategories = triggerCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (_triggerCategories.length > 5) {
      _triggerCategories = _triggerCategories.sublist(0, 5);
    }
    
    // Process urges by date
    _urgesByDate = {};
    for (final log in urgeLogs) {
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      _urgesByDate[date] = (_urgesByDate[date] ?? 0) + 1;
    }
  }
  
  void _changeTimeframe(String timeframe) {
    setState(() {
      _timeframe = timeframe;
      _dataFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Progress & Analytics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildTrendsTab(),
              _buildInsightsTab(),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeframeSelector(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildStrengthChart(),
          const SizedBox(height: 24),
          _buildTriggersList(),
        ],
      ),
    );
  }
  
  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeframeSelector(),
          const SizedBox(height: 24),
          _buildUrgesOverTimeChart(),
          const SizedBox(height: 24),
          _buildStreakProgress(),
          const SizedBox(height: 24),
          _buildHeatmapChart(),
        ],
      ),
    );
  }
  
  Widget _buildInsightsTab() {
    // For now this is just a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Personalized Insights Coming Soon',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'We\'ll analyze your patterns to provide customized recommendations and insights',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeframeSelector() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _buildTimeframeButton('Week', 'week'),
          _buildTimeframeButton('Month', 'month'),
          _buildTimeframeButton('3 Months', '3months'),
          _buildTimeframeButton('Year', 'year'),
        ],
      ),
    );
  }
  
  Widget _buildTimeframeButton(String label, String value) {
    final isSelected = _timeframe == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeTimeframe(value),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Days Clean', _totalDaysClean.toString(), Icons.calendar_today, AppColors.primary),
        _buildStatCard('Relapses', _totalRelapses.toString(), Icons.warning_amber, Colors.orange),
        _buildStatCard('Avg Urge Intensity', _avgUrgeIntensity.toStringAsFixed(1), Icons.speed, Colors.red),
        _buildStatCard('Urges Resisted', '${_urgeLogs.where((log) => log.wasResisted).length}', Icons.verified, Colors.green),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStrengthChart() {
    if (_urgeLogs.isEmpty) {
      return _buildEmptyState('No urge data available', 'Log your urges to see intensity patterns');
    }
    
    // Calculate intensity distribution
    int low = 0, medium = 0, high = 0, extreme = 0;
    for (final log in _urgeLogs) {
      switch (log.intensity) {
        case UrgeIntensity.low:
          low++;
          break;
        case UrgeIntensity.medium:
          medium++;
          break;
        case UrgeIntensity.high:
          high++;
          break;
        case UrgeIntensity.extreme:
          extreme++;
          break;
      }
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Urge Intensity Distribution',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String intensity;
                        switch (groupIndex) {
                          case 0:
                            intensity = 'Low';
                            break;
                          case 1:
                            intensity = 'Medium';
                            break;
                          case 2:
                            intensity = 'High';
                            break;
                          case 3:
                            intensity = 'Extreme';
                            break;
                          default:
                            intensity = '';
                        }
                        return BarTooltipItem(
                          '${rod.toY.round()} urges\n$intensity',
                          GoogleFonts.poppins(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Low';
                              break;
                            case 1:
                              text = 'Medium';
                              break;
                            case 2:
                              text = 'High';
                              break;
                            case 3:
                              text = 'Extreme';
                              break;
                            default:
                              text = '';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              text,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    horizontalInterval: 5,
                    drawVerticalLine: false,
                  ),
                  barGroups: [
                    _createBarGroup(0, low, Colors.green),
                    _createBarGroup(1, medium, Colors.amber),
                    _createBarGroup(2, high, Colors.orange),
                    _createBarGroup(3, extreme, Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  BarChartGroupData _createBarGroup(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTriggersList() {
    if (_triggerCategories.isEmpty) {
      return _buildEmptyState('No trigger data', 'Log what causes urges to see patterns');
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Triggers',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_triggerCategories.length, (index) {
              final trigger = _triggerCategories[index];
              final percentage = (trigger.value / _urgeLogs.length * 100).round();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trigger.key,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUrgesOverTimeChart() {
    if (_urgesByDate.isEmpty) {
      return _buildEmptyState('No data to display', 'Log your urges to see trends over time');
    }
    
    final List<FlSpot> spots = [];
    
    // Get date range based on timeframe
    DateTime endDate = DateTime.now();
    DateTime startDate;
    
    switch (_timeframe) {
      case 'week':
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
        break;
      case '3months':
        startDate = DateTime(endDate.year, endDate.month - 3, endDate.day);
        break;
      case 'year':
        startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
        break;
      default:
        startDate = endDate.subtract(const Duration(days: 7));
    }
    
    // Create day-by-day data
    for (DateTime date = startDate;
         date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
         date = date.add(const Duration(days: 1))) {
      
      final daysSinceStart = date.difference(startDate).inDays.toDouble();
      final value = _urgesByDate[DateTime(date.year, date.month, date.day)] ?? 0;
      
      spots.add(FlSpot(daysSinceStart, value.toDouble()));
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Urges Over Time',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track how your urges change over time',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value % 1 != 0) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (_timeframe == 'week') {
                            // For week, show day names
                            final date = startDate.add(Duration(days: value.toInt()));
                            final format = DateFormat('E');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                format.format(date),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          } else {
                            // For other timeframes, show selected dates
                            if (value % 5 == 0 || value == 0 || value == spots.length - 1) {
                              final date = startDate.add(Duration(days: value.toInt()));
                              final format = DateFormat('M/d');
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  format.format(date),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final date = startDate.add(Duration(days: barSpot.x.toInt()));
                          final format = DateFormat('MMM d');
                          return LineTooltipItem(
                            '${barSpot.y.toInt()} urges\n${format.format(date)}',
                            GoogleFonts.poppins(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStreakProgress() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Streak',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Days without relapsing',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: (_streak?.daysCount ?? 0) / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_streak?.daysCount ?? 0}',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Days',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStreakStat('Best', '${_streak?.daysCount ?? 0}'),
                  _buildStreakStat('Average', '${_totalDaysClean ~/ 2}'),
                  _buildStreakStat('Streaks', '1'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStreakStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeatmapChart() {
    // This would be a placeholder since a full heatmap implementation is complex
    // In a real app, you'd use a calendar heatmap package
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Calendar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your progress over time',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // Placeholder for heatmap visualization
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Calendar Heatmap Coming Soon',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorIndicator('Less', Colors.green.shade100),
                _buildColorIndicator('', Colors.green.shade300),
                _buildColorIndicator('', Colors.green.shade500),
                _buildColorIndicator('', Colors.green.shade700),
                _buildColorIndicator('More', Colors.green.shade900),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorIndicator(String label, Color color) {
    return Row(
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
        ],
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (label.isNotEmpty) const SizedBox(width: 4),
      ],
    );
  }
  
  Widget _buildEmptyState(String title, String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
