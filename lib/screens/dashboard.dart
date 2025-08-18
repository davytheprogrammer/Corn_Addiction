import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dashboard/dashboard_controller.dart';
import '../widgets/ai_prediction_widget.dart';
import 'ai_analysis_detail_screen.dart';
import 'journal_screen.dart';
import 'recovery/habit_tracker_screen.dart';
import 'recovery/recovery_quotes_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late DashboardController _controller;
  late Timer _timer;
  Duration _timeSinceStart = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.loadUserData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_controller.currentStreak?.startDate != null) {
        setState(() {
          _timeSinceStart =
              DateTime.now().difference(_controller.currentStreak!.startDate);
        });
      }
    });
  }

  Future<void> _handleCheckIn() async {
    try {
      final message = await _controller.checkIn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _handleRelapse() async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report Relapse',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to report a relapse? This will reset your current streak.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
            ),
            child: Text(
              'Report Relapse',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final message = await _controller.reportRelapse();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  Widget _buildMainProgressCircle() {
    double progressPercentage =
        (_controller.currentStreakDays / 30).clamp(0.0, 1.0);

    return Column(
      children: [
        // Progress indicator with label
        Text(
          'Progress to 30 Days',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progressPercentage,
                strokeWidth: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lottie Avatar - bigger
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Lottie.asset(
                    'assets/animations/Profile Avatar for Child.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'I have been free for',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                _buildTimeDisplay(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${(progressPercentage * 100).toInt()}% Complete',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay() {
    if (_timeSinceStart == Duration.zero) {
      return Text(
        '0 days, 0 hours, 0 minutes',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      );
    }

    final days = _timeSinceStart.inDays;
    final hours = _timeSinceStart.inHours % 24;
    final minutes = _timeSinceStart.inMinutes % 60;

    return Text(
      '$days days, $hours hours, $minutes minutes',
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF00BCD4),
            Color(0xFF26A69A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main circular progress
          Center(
            child: _buildMainProgressCircle(),
          ),
          const SizedBox(height: 24),

          // Side by side buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCheckIn,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: Text(
              'CHECK IN TODAY',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanicButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.red.shade600,
            Colors.red.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showPanicDialog,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'PANIC BUTTON',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'URGENT',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryTools() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recovery Tools',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionIcon(
                Icons.track_changes_rounded,
                'HABIT TRACKER',
                AppColors.primary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HabitTrackerScreen(),
                    ),
                  );
                },
              ),
              _buildActionIcon(
                Icons.book_rounded,
                'JOURNAL',
                AppColors.secondary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JournalScreen(),
                    ),
                  );
                },
              ),
              _buildActionIcon(
                Icons.format_quote_rounded,
                'QUOTES',
                AppColors.accent,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecoveryQuotesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recovery Stats',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Days',
                  '${_controller.currentStreakDays}',
                  Icons.calendar_today,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Best Streak',
                  '${_controller.currentStreakDays}',
                  Icons.emoji_events,
                  AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'This Week',
                  '${(_controller.currentStreakDays % 7)}',
                  Icons.date_range,
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAIAnalysisCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard() {
    return GestureDetector(
      onTap: () {
        // Navigate to detailed AI analysis page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AIAnalysisDetailScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.info.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.psychology_rounded,
              color: AppColors.info,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              'AI',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.info,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Analysis',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPanicDialog() {
    final quotes = [
      "You're about to throw away ${_controller.currentStreakDays} days of progress for 5 minutes of fake pleasure. Is it worth it?",
      "That urge you're feeling? It's your porn addiction lying to you. Don't believe the lie.",
      "Every time you watch porn, you're choosing to be controlled instead of being free. Choose freedom.",
      "You know exactly how you'll feel after: empty, ashamed, and back to day zero. Stop before you start.",
      "Your future self is begging you not to watch porn right now. Listen to them.",
      "Porn isn't love, it's not connection, it's not real intimacy. You deserve better than fake substitutes.",
      "You've worked too hard to throw it all away for something that will be over in minutes.",
      "The person you want to become would never choose porn. Be that person now.",
      "Your brain is hijacked by porn right now. This urge will pass in 20 minutes if you don't feed it.",
      "You're not 'just looking' - you know exactly where porn leads. Stop lying to yourself.",
      "Every porn relapse makes the next one easier. Break the cycle right now.",
      "You're about to trade your self-respect for pixels on a screen. That's not a fair trade.",
      "Porn addiction has already stolen enough from you. Don't let it steal today too.",
      "You know you'll hate yourself after watching porn. Choose to love yourself now instead.",
      "Your streak isn't just numbers - it's proof you can control your life. Don't give up that power to porn.",
      "The shame spiral starts with this one click on porn. You have the power to stop it before it begins.",
      "You're stronger than your weakest moment. This is your chance to prove porn doesn't control you.",
      "That porn will still exist tomorrow, but your progress won't if you give in now.",
      "You've survived every porn urge before this one. You can survive this one too.",
      "Your porn addiction wants you to believe you have no choice. You always have a choice.",
      "Five minutes of fake porn pleasure isn't worth destroying the real person you're becoming.",
      "You're not missing out on anything real with porn. You're protecting something precious - your recovery.",
      "The urge feels overwhelming because your brain is lying about how good porn will be. It won't be.",
      "You've already seen it all before in porn. There's nothing new, just the same trap with different content.",
      "Your worth isn't determined by your ability to resist porn, but your recovery is. Choose wisely.",
      "This moment will define whether you're controlled by porn or you control your impulses.",
      "You know the script: porn urge, give in, shame, promise to quit, repeat. Break the script.",
      "Porn addiction doesn't care about your goals, dreams, or relationships. But you should.",
      "The temporary high from porn isn't worth the permanent damage to your self-trust.",
      "You're not 'treating yourself' with porn - you're poisoning yourself. Choose health instead."
    ];

    final randomQuote = quotes[DateTime.now().millisecond % quotes.length];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(
              'URGE ALERT',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              randomQuote,
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showPanicDialog(); // Show another quote
            },
            child: Text(
              'Another Quote',
              style: GoogleFonts.poppins(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Urge Passed',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF00BCD4),
                    Color(0xFF26A69A),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your progress...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: _controller.loadUserData,
            color: AppColors.primary,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Progress Card
                    _buildProgressCard(),
                    const SizedBox(height: 16),

                    // Panic Button
                    _buildPanicButton(),
                    const SizedBox(height: 20),

                    // AI Prediction Widget (renamed to Chances of Relapse) - smaller
                    const AIPredictionWidget(),
                    const SizedBox(height: 20),

                    // Recovery Tools
                    _buildRecoveryTools(),
                    const SizedBox(height: 20),

                    // Bottom card with stats only
                    _buildStatsCard(),
                    const SizedBox(height: 120), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
