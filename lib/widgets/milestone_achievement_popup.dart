import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:corn_addiction/core/constants/app_colors.dart';
import '../models/streak_milestone_model.dart';

class MilestoneAchievementPopup extends StatelessWidget {
  final StreakMilestoneModel milestone;
  final VoidCallback onClose;
  final VoidCallback onClaimReward;

  const MilestoneAchievementPopup({
    Key? key,
    required this.milestone,
    required this.onClose,
    required this.onClaimReward,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
            Text(
              'Congratulations!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _getMilestoneTitle(),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (milestone.animationPath != null)
              SizedBox(
                height: 150,
                child: Lottie.asset(
                  milestone.animationPath!,
                  repeat: true,
                  animate: true,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              milestone.rewards['message'] ??
                  'You have reached an important milestone!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reward: ${milestone.rewards['points']} points',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onClaimReward,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _getPrimaryColor(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Claim Reward',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMilestoneTitle() {
    switch (milestone.milestone) {
      case 1:
        return 'First Day Milestone!';
      case 7:
        return 'One Week Milestone!';
      case 30:
        return 'One Month Milestone!';
      case 90:
        return 'Three Months Milestone!';
      case 365:
        return 'One Year Milestone!';
      default:
        return '${milestone.milestone} Days Milestone!';
    }
  }

  List<Color> _getGradientColors() {
    switch (milestone.milestone) {
      case 1:
        return [AppColors.primary, AppColors.primaryDark];
      case 7:
        return [AppColors.success, AppColors.secondary];
      case 30:
        return [AppColors.accent, AppColors.secondaryDark];
      case 90:
        return [AppColors.warning, AppColors.primary];
      case 365:
        return [AppColors.error, AppColors.primaryDark];
      default:
        return [AppColors.primary, AppColors.primaryDark];
    }
  }

  Color _getPrimaryColor() {
    switch (milestone.milestone) {
      case 1:
        return AppColors.primary;
      case 7:
        return AppColors.success;
      case 30:
        return AppColors.accent;
      case 90:
        return AppColors.warning;
      case 365:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}
