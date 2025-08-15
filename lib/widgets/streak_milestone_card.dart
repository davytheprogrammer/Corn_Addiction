import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/streak_milestone_model.dart';

class StreakMilestoneCard extends StatelessWidget {
  final StreakMilestoneModel milestone;
  final VoidCallback? onClaimReward;

  const StreakMilestoneCard({
    Key? key,
    required this.milestone,
    this.onClaimReward,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _getMilestoneTitle(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (milestone.animationPath != null)
              SizedBox(
                height: 120,
                child: Lottie.asset(
                  milestone.animationPath!,
                  repeat: true,
                  animate: true,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              milestone.rewards['message'] ?? 'Congratulations on your milestone!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reward: ${milestone.rewards['points']} points',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (!milestone.rewardClaimed && onClaimReward != null)
              ElevatedButton(
                onPressed: onClaimReward,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _getPrimaryColor(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Claim Reward', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            else if (milestone.rewardClaimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Reward Claimed',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
        return [Colors.blue.shade300, Colors.blue.shade700];
      case 7:
        return [Colors.green.shade300, Colors.green.shade700];
      case 30:
        return [Colors.purple.shade300, Colors.purple.shade700];
      case 90:
        return [Colors.orange.shade300, Colors.orange.shade700];
      case 365:
        return [Colors.red.shade300, Colors.red.shade700];
      default:
        return [Colors.blue.shade300, Colors.blue.shade700];
    }
  }

  Color _getPrimaryColor() {
    switch (milestone.milestone) {
      case 1:
        return Colors.blue.shade700;
      case 7:
        return Colors.green.shade700;
      case 30:
        return Colors.purple.shade700;
      case 90:
        return Colors.orange.shade700;
      case 365:
        return Colors.red.shade700;
      default:
        return Colors.blue.shade700;
    }
  }
}