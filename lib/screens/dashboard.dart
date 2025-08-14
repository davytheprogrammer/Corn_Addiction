import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard/dashboard_controller.dart';
import 'dashboard/dashboard_widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your progress...',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
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
                    // Header section (moved from AppBar)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              color: AppColors.primary),
                          onPressed: _controller.loadUserData,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Dashboard content
                    DashboardWidgets.buildModernStreakSection(
                      currentStreakDays: _controller.currentStreakDays,
                      currentStreak: _controller.currentStreak,
                    ),
                    const SizedBox(height: 24),
                    DashboardWidgets.buildModernCheckInSection(
                      hasCheckedInToday: _controller.hasCheckedInToday,
                      onCheckIn: _handleCheckIn,
                    ),
                    const SizedBox(height: 24),
                    DashboardWidgets.buildModernUrgesSection(
                      recentUrges: _controller.recentUrges,
                    ),
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
