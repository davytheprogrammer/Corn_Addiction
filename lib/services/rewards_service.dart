import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/streak_milestone_model.dart';
import '../models/challenge_badge_model.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';
import '../models/user_model.dart';

class RewardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _streakMilestonesCollection = 
      FirebaseFirestore.instance.collection('streak_milestones');
  final CollectionReference _challengeBadgesCollection = 
      FirebaseFirestore.instance.collection('challenge_badges');
  final CollectionReference _challengesCollection = 
      FirebaseFirestore.instance.collection('challenges');
  final CollectionReference _challengeProgressCollection = 
      FirebaseFirestore.instance.collection('challenge_progress');
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');

  // Check for streak milestones and award them if achieved
  Future<StreakMilestoneModel?> checkAndAwardStreakMilestone(String userId, int currentStreak) async {
    // Check if the current streak is a milestone day
    if (!StreakMilestoneModel.isMilestoneDay(currentStreak)) {
      return null;
    }

    // Check if this milestone has already been awarded
    final existingMilestoneQuery = await _streakMilestonesCollection
        .where('userId', isEqualTo: userId)
        .where('milestone', isEqualTo: currentStreak)
        .limit(1)
        .get();

    if (existingMilestoneQuery.docs.isNotEmpty) {
      // Milestone already awarded
      return StreakMilestoneModel.fromFirestore(existingMilestoneQuery.docs.first);
    }

    // Create a new milestone reward
    final newMilestoneRef = _streakMilestonesCollection.doc();
    final animationPath = StreakMilestoneModel.getAnimationPathForMilestone(currentStreak);
    
    // Define rewards based on milestone
    final Map<String, dynamic> rewards = {};
    switch (currentStreak) {
      case 1:
        rewards['message'] = 'Congratulations on your first day!';
        rewards['points'] = 10;
        break;
      case 7:
        rewards['message'] = 'One week strong! Keep going!';
        rewards['points'] = 50;
        break;
      case 30:
        rewards['message'] = 'A full month of progress! Amazing work!';
        rewards['points'] = 200;
        break;
      case 90:
        rewards['message'] = '90 days is a huge achievement!';
        rewards['points'] = 500;
        break;
      case 365:
        rewards['message'] = 'A full year of dedication! Incredible!';
        rewards['points'] = 2000;
        break;
    }

    final milestone = StreakMilestoneModel(
      id: newMilestoneRef.id,
      userId: userId,
      milestone: currentStreak,
      achievedAt: DateTime.now(),
      animationPath: animationPath,
      rewards: rewards,
    );

    // Save to Firestore
    await newMilestoneRef.set(milestone.toFirestore());

    // Update user's achieved milestones
    final userDoc = await _usersCollection.doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final List<dynamic> achievedMilestones = List.from(userData['achievedMilestones'] ?? []);
      
      if (!achievedMilestones.contains(currentStreak)) {
        achievedMilestones.add(currentStreak);
        await _usersCollection.doc(userId).update({
          'achievedMilestones': achievedMilestones,
        });
      }
    }

    return milestone;
  }

  // Get all active challenges
  Future<List<ChallengeModel>> getActiveChallenges() async {
    final now = DateTime.now();
    final challengesSnapshot = await _challengesCollection
        .where('isActive', isEqualTo: true)
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .get();

    return challengesSnapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
  }

  // Get user's challenge progress
  Future<ChallengeProgressModel?> getUserChallengeProgress(String userId, String challengeId) async {
    final progressSnapshot = await _challengeProgressCollection
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .limit(1)
        .get();

    if (progressSnapshot.docs.isEmpty) {
      return null;
    }

    return ChallengeProgressModel.fromFirestore(progressSnapshot.docs.first);
  }

  // Update user's challenge progress
  Future<void> updateChallengeProgress(ChallengeProgressModel progress) async {
    await _challengeProgressCollection.doc(progress.id).set(progress.toFirestore());
  }

  // Create initial challenge progress for a user
  Future<ChallengeProgressModel> createChallengeProgress(String userId, String challengeId) async {
    final newProgressRef = _challengeProgressCollection.doc();
    
    final progress = ChallengeProgressModel(
      id: newProgressRef.id,
      userId: userId,
      challengeId: challengeId,
    );

    await newProgressRef.set(progress.toFirestore());
    return progress;
  }

  // Check if challenge is completed and award badge if needed
  Future<ChallengeBadgeModel?> checkAndAwardChallengeBadge(
      String userId, String challengeId, Map<String, dynamic> requirements, Map<String, dynamic> progress) async {
    // Check if all requirements are met
    bool isCompleted = true;
    for (final requirement in requirements.entries) {
      final key = requirement.key;
      final requiredValue = requirement.value;
      final currentValue = progress[key] ?? 0;

      if (currentValue < requiredValue) {
        isCompleted = false;
        break;
      }
    }

    if (!isCompleted) {
      return null;
    }

    // Get challenge details
    final challengeDoc = await _challengesCollection.doc(challengeId).get();
    if (!challengeDoc.exists) {
      return null;
    }

    final challenge = ChallengeModel.fromFirestore(challengeDoc);

    // Check if badge already awarded
    final existingBadgeQuery = await _challengeBadgesCollection
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .limit(1)
        .get();

    if (existingBadgeQuery.docs.isNotEmpty) {
      // Badge already awarded
      return ChallengeBadgeModel.fromFirestore(existingBadgeQuery.docs.first);
    }

    // Create a new badge
    final newBadgeRef = _challengeBadgesCollection.doc();
    
    final badge = ChallengeBadgeModel(
      id: newBadgeRef.id,
      userId: userId,
      badgeId: challenge.badgeId,
      badgeName: challenge.badgeName,
      badgeDescription: challenge.badgeDescription,
      badgeImagePath: challenge.badgeImagePath,
      earnedAt: DateTime.now(),
      challengeType: challenge.challengeType,
      challengeId: challengeId,
    );

    // Save to Firestore
    await newBadgeRef.set(badge.toFirestore());

    // Update user's earned badges
    final userDoc = await _usersCollection.doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final List<dynamic> earnedBadges = List.from(userData['earnedBadges'] ?? []);
      
      if (!earnedBadges.contains(badge.badgeId)) {
        earnedBadges.add(badge.badgeId);
        await _usersCollection.doc(userId).update({
          'earnedBadges': earnedBadges,
        });
      }
    }

    // Update challenge progress to mark badge as awarded
    final progressQuery = await _challengeProgressCollection
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .limit(1)
        .get();

    if (progressQuery.docs.isNotEmpty) {
      final progressDoc = progressQuery.docs.first;
      final progress = ChallengeProgressModel.fromFirestore(progressDoc);
      
      await _challengeProgressCollection.doc(progress.id).update({
        'isCompleted': true,
        'completedAt': Timestamp.fromDate(DateTime.now()),
        'badgeAwarded': true,
      });
    }

    return badge;
  }

  // Get all streak milestones for a user
  Future<List<StreakMilestoneModel>> getUserStreakMilestones(String userId) async {
    final milestonesSnapshot = await _streakMilestonesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('milestone', descending: true)
        .get();

    return milestonesSnapshot.docs
        .map((doc) => StreakMilestoneModel.fromFirestore(doc))
        .toList();
  }

  // Get all badges earned by a user
  Future<List<ChallengeBadgeModel>> getUserBadges(String userId) async {
    final badgesSnapshot = await _challengeBadgesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('earnedAt', descending: true)
        .get();

    return badgesSnapshot.docs
        .map((doc) => ChallengeBadgeModel.fromFirestore(doc))
        .toList();
  }

  // Mark a streak milestone reward as claimed
  Future<void> claimMilestoneReward(String milestoneId) async {
    await _streakMilestonesCollection.doc(milestoneId).update({
      'rewardClaimed': true,
    });
  }

  // Toggle badge display status
  Future<void> toggleBadgeDisplay(String badgeId, bool isDisplayed) async {
    await _challengeBadgesCollection.doc(badgeId).update({
      'isDisplayed': isDisplayed,
    });
  }
}