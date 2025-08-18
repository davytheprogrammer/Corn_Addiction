import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../../services/ai_habit_service.dart';
import '../../services/auth_service.dart';
import '../../models/ai_habit_model.dart';

// Color extension for opacity handling
extension ColorExtension on Color {
  Color withValues({double? alpha}) {
    return withOpacity(alpha ?? 1.0);
  }
}

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final AIHabitService _habitService = AIHabitService();
  final AuthService _authService = AuthService();

  List<AIHabitModel> _habits = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    print('🎯 Habit Tracker: Loading habits...');
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final habits = await _habitService.getDailyHabits(user.uid);
        print('🎯 Habit Tracker: Loaded ${habits.length} habits');
        if (mounted) {
          setState(() {
            _habits = habits;
            _isLoading = false;
          });
        }
      } else {
        print('🎯 Habit Tracker: No user found');
      }
    } catch (e) {
      print('🎯 Habit Tracker: Error loading habits: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeHabit(AIHabitModel habit) async {
    print('🎯 Habit Tracker: Completing habit: ${habit.title}');

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final success = await _habitService.completeHabit(user.uid, habit.id);
        if (success && mounted) {
          setState(() {
            final index = _habits.indexWhere((h) => h.id == habit.id);
            if (index != -1) {
              _habits[index] = habit.copyWith(
                isCompleted: true,
                completedAt: DateTime.now(),
              );
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Great job! "${habit.title}" completed!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('🎯 Habit Tracker: Error completing habit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing habit: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Habit Tracker',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primary),
            onPressed: _showAddHabitDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTodaySection(),
              const SizedBox(height: 24),
              _buildWeeklyOverview(),
              const SizedBox(height: 24),
              _buildHabitsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final completedToday = _habits.where((h) => h.isCompleted && h.completedAt?.day == DateTime.now().day).length;
    final totalHabits = _habits.length;
    final progress = totalHabits > 0 ? completedToday / totalHabits : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green,
            Colors.green.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$completedToday of $totalHabits habits completed',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Habits',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._habits
            .map((habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHabitCard(habit),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildHabitCard(AIHabitModel habit) {
    final bool isCompletedToday = habit.isCompleted && habit.completedAt?.day == DateTime.now().day;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompletedToday
            ? Border.all(color: Colors.green, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _completeHabit(habit),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompletedToday
                    ? Colors.green
                    : getHabitColor(habit.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
                border: isCompletedToday
                    ? null
                    : Border.all(color: getHabitColor(habit.category).withValues(alpha: 0.3)),
              ),
              child: Icon(
                isCompletedToday ? Icons.check : getHabitIcon(habit.category),
                color: isCompletedToday ? Colors.white : getHabitColor(habit.category),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    decoration: isCompletedToday
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      getStreakText(habit),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isCompletedToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              final isToday = index == 6;
              final completed =
                  index < 5 ? true : (index == 5 ? false : true); // Mock data

              return Column(
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 1),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: completed
                          ? Colors.green
                          : (isToday
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(16),
                      border: isToday
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: completed
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : Text(
                              date.day.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Habits',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._habits
            .map((habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHabitStatsCard(habit),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildHabitStatsCard(AIHabitModel habit) {
    final Color habitColor = getHabitColor(habit.category);
    final IconData habitIcon = getHabitIcon(habit.category);
    final int streak = getHabitStreak(habit);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: habitColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              habitIcon,
              color: habitColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current streak: $streak days',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$streak',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: habitColor,
                ),
              ),
              Text(
                'days',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods to handle AIHabitModel
  Color getHabitColor(String category) {
    switch (category.toLowerCase()) {
      case 'exercise':
        return Colors.blue;
      case 'nutrition':
        return Colors.green;
      case 'meditation':
        return Colors.purple;
      case 'recovery':
        return Colors.orange;
      case 'education':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  IconData getHabitIcon(String category) {
    switch (category.toLowerCase()) {
      case 'exercise':
        return Icons.fitness_center;
      case 'nutrition':
        return Icons.restaurant;
      case 'meditation':
        return Icons.self_improvement;
      case 'recovery':
        return Icons.healing;
      case 'education':
        return Icons.school;
      default:
        return Icons.check_circle_outline;
    }
  }

  int getHabitStreak(AIHabitModel habit) {
    // For now return a placeholder value; in a real app,
    // this would calculate streak based on habit history data
    return habit.metadata.containsKey('streak') ? 
      habit.metadata['streak'] as int : 
      (habit.isCompleted ? 1 : 0);
  }
  
  String getStreakText(AIHabitModel habit) {
    int streak = getHabitStreak(habit);
    return '$streak day streak';
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Habit',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This feature will be available soon!',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// We are now using AIHabitModel instead of the Habit class
