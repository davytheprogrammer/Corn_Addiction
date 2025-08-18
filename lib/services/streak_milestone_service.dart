import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/streak_milestone_model.dart';
import '../models/user_model.dart';
import '../widgets/milestone_achievement_popup.dart';

class StreakMilestoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Milestone days to check for
  final List<int> _milestones = [1, 7, 30, 90, 365];

  // Check if user has reached a new milestone
  Future<StreakMilestoneModel?> checkForMilestone(UserModel user) async {
    // If current streak is not in milestones list, return null
    if (!_milestones.contains(user.currentStreak)) {
      return null;
    }

    // Check if milestone is already achieved by querying Firestore
    final existingMilestone = await _firestore
        .collection('streak_milestones')
        .where('userId', isEqualTo: user.uid)
        .where('milestone', isEqualTo: user.currentStreak)
        .get();

    if (existingMilestone.docs.isNotEmpty) {
      return null;
    }

    // Create new milestone
    final milestone = StreakMilestoneModel(
      id: '', // Will be set after Firestore add
      userId: user.uid,
      milestone: user.currentStreak,
      achievedAt: DateTime.now(),
      rewardClaimed: false,
      animationPath:
          StreakMilestoneModel.getAnimationPathForMilestone(user.currentStreak),
      rewards: _getRewardsForMilestone(user.currentStreak),
    );

    // Save milestone to Firestore
    final docRef = await _firestore
        .collection('streak_milestones')
        .add(milestone.toFirestore());

    // Update milestone with generated ID
    final updatedMilestone = milestone.copyWith(id: docRef.id);
    await docRef.update({'id': docRef.id});

    // No need to update user document since we track milestones separately in their own collection

    return updatedMilestone;
  }

  // Get rewards for milestone
  Map<String, dynamic> _getRewardsForMilestone(int milestone) {
    switch (milestone) {
      case 1:
        return {
          'points': 10,
          'message': 'You completed your first day! Keep going!',
        };
      case 7:
        return {
          'points': 50,
          'message': 'One week clean! Your brain is already healing.',
        };
      case 30:
        return {
          'points': 200,
          'message': 'One month milestone! You\'re building a new life.',
        };
      case 90:
        return {
          'points': 500,
          'message': 'Three months clean! This is a major achievement.',
        };
      case 365:
        return {
          'points': 2000,
          'message': 'One year clean! You\'ve transformed your life!',
        };
      default:
        return {
          'points': 10,
          'message': 'Congratulations on your milestone!',
        };
    }
  }

  // Get all user's milestones
  Future<List<StreakMilestoneModel>> getUserMilestones(String userId) async {
    final querySnapshot = await _firestore
        .collection('streak_milestones')
        .where('userId', isEqualTo: userId)
        .orderBy('achievedAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => StreakMilestoneModel.fromFirestore(doc))
        .toList();
  }

  // Claim milestone reward
  Future<void> claimMilestoneReward(String milestoneId) async {
    await _firestore.collection('streak_milestones').doc(milestoneId).update({
      'rewardClaimed': true,
    });
  }

  // Show milestone achievement popup
  void showMilestonePopup(BuildContext context, StreakMilestoneModel milestone,
      Function onRewardClaimed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MilestoneAchievementPopup(
          milestone: milestone,
          onClose: () => Navigator.of(context).pop(),
          onClaimReward: () async {
            await claimMilestoneReward(milestone.id);
            onRewardClaimed();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
