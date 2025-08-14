import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:corn_addiction/core/constants/app_text_styles.dart';
import 'package:corn_addiction/models/streak_model.dart';
import 'package:corn_addiction/models/urge_log_model.dart';
import 'package:corn_addiction/services/auth.dart';
import 'package:corn_addiction/services/database.dart';
import 'package:corn_addiction/shared/responsive_layout.dart';
import 'package:corn_addiction/widgets/common_widgets.dart';
import 'package:corn_addiction/widgets/daily_reward_indicator.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  StreakModel? _currentStreak;
  List<UrgeLogModel> _recentUrges = [];
  bool _hasCheckedInToday = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final database = DatabaseService(uid: AuthService().currentUser!.uid);
      final streak = await database.getCurrentStreak();
      final urges = await database.getRecentUrgeLogs(limit: 5);
      final lastCheckIn = await database.getLastCheckin();

      setState(() {
        _currentStreak = streak;
        _recentUrges = urges;
        
        // Check if user has checked in today
        if (lastCheckIn != null) {
          final today = DateTime.now();
          final lastCheckInDate = lastCheckIn.date;
          _hasCheckedInToday = 
              lastCheckInDate.year == today.year &&
              lastCheckInDate.month == today.month &&
              lastCheckInDate.day == today.day;
        } else {
          _hasCheckedInToday = false;
        }
      });
    } catch (e) {
      // Handle errors
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final database = DatabaseService(uid: AuthService().currentUser!.uid);
      await database.recordDailyCheckin();
      await _loadUserData(); // Reload data to update UI
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in successful! Keep up the good work!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logUrge(double intensity) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final database = DatabaseService(uid: AuthService().currentUser!.uid);
      final urge = UrgeLogModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        intensity: intensity,
        notes: '',
        triggers: [],
        didRelapse: false,
      );
      
      await database.logUrge(urge);
      await _loadUserData(); // Reload data to update UI
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Urge logged successfully. Stay strong!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recovery Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUserData,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Insights'),
              Tab(text: 'Community'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildInsightsTab(),
            _buildCommunityTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showLogUrgeBottomSheet();
          },
          backgroundColor: AppColors.accent,
          icon: const Icon(Icons.warning_amber_rounded),
          label: const Text('Log Urge'),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ResponsiveLayout(
          mobileBody: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakSection(),
              const SizedBox(height: 24),
              _buildDailyCheckInSection(),
              const SizedBox(height: 24),
              _buildRecentUrgesSection(),
            ],
          ),
          tabletBody: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildStreakSection(),
                    const SizedBox(height: 24),
                    _buildDailyCheckInSection(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildRecentUrgesSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Current Streak',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          Center(
            child: StreakCounterBadge(
              days: _currentStreak?.currentDays ?? 0,
              label: 'DAYS CLEAN',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Best Streak: ${_currentStreak?.bestDays ?? 0} days',
            style: AppTextStyles.bodyLarge,
          ),
          if (_currentStreak?.startDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Started on: ${DateFormat('MMM dd, yyyy').format(_currentStreak!.startDate)}',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyCheckInSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Check-in',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mark today as clean',
                      style: AppTextStyles.bodyLarge,
                    ),
                    Text(
                      'Maintain your streak by checking in daily',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _hasCheckedInToday
                  ? const DailyRewardIndicator(hasCheckedIn: true)
                  : PrimaryButton(
                      text: 'Check In',
                      onPressed: _checkIn,
                      isFullWidth: false,
                      height: 48,
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUrgesSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Urges',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          _recentUrges.isEmpty
              ? const EmptyStateWidget(
                  title: 'No Recent Urges',
                  message: 'When you log urges, they will appear here.',
                  icon: Icons.check_circle_outline,
                  iconSize: 60,
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentUrges.length,
                  itemBuilder: (context, index) {
                    final urge = _recentUrges[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: _getUrgeIntensityColor(urge.intensity),
                        child: Text(
                          urge.intensity.round().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        DateFormat('MMM d, h:mm a').format(urge.timestamp),
                      ),
                      subtitle: Text(
                        urge.notes.isNotEmpty 
                            ? urge.notes 
                            : 'No notes added',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: urge.didRelapse
                          ? const Icon(
                              Icons.warning_rounded,
                              color: AppColors.error,
                            )
                          : const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    // Placeholder for now - will be implemented fully later
    return const Center(
      child: Text('Insights coming soon!'),
    );
  }

  Widget _buildCommunityTab() {
    // Placeholder for now - will be implemented fully later
    return const Center(
      child: Text('Community features coming soon!'),
    );
  }

  Color _getUrgeIntensityColor(double intensity) {
    if (intensity <= 3) {
      return AppColors.urgeIntensityLow;
    } else if (intensity <= 7) {
      return AppColors.urgeIntensityMedium;
    } else {
      return AppColors.urgeIntensityHigh;
    }
  }

  void _showLogUrgeBottomSheet() {
    double urgeIntensity = 5.0;
    bool didRelapse = false;
    TextEditingController notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Log an Urge',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'How strong is your urge? (1-10)',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('1', style: AppTextStyles.bodyMedium),
                      Expanded(
                        child: Slider(
                          value: urgeIntensity,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: _getUrgeIntensityColor(urgeIntensity),
                          label: urgeIntensity.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              urgeIntensity = value;
                            });
                          },
                        ),
                      ),
                      Text('10', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text(
                      'I relapsed',
                      style: AppTextStyles.bodyLarge,
                    ),
                    value: didRelapse,
                    onChanged: (value) {
                      setState(() {
                        didRelapse = value ?? false;
                      });
                    },
                    activeColor: AppColors.error,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'What triggered this urge?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      PrimaryButton(
                        text: 'Save',
                        isFullWidth: false,
                        onPressed: () async {
                          Navigator.pop(context);
                          
                          final urge = UrgeLogModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            timestamp: DateTime.now(),
                            intensity: urgeIntensity,
                            notes: notesController.text,
                            triggers: [],
                            didRelapse: didRelapse,
                          );
                          
                          final database = DatabaseService(
                            uid: AuthService().currentUser!.uid
                          );
                          
                          setState(() {
                            _isLoading = true;
                          });
                          
                          try {
                            await database.logUrge(urge);
                            // If user relapsed, reset streak
                            if (didRelapse) {
                              await database.resetStreak();
                            }
                            await _loadUserData();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
