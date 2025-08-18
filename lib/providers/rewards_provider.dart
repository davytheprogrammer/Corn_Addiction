import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge_badge_model.dart';
import '../models/streak_milestone_model.dart';
import '../models/user_model.dart';
import '../services/challenge_badge_service.dart';
import '../services/streak_milestone_service.dart';
import '../services/rewards_service.dart';
import '../services/auth_service.dart';

// Provider for streak milestone service
final streakMilestoneServiceProvider = Provider<StreakMilestoneService>((ref) {
  return StreakMilestoneService();
});

// Provider for challenge badge service
final challengeBadgeServiceProvider = Provider<ChallengeBadgeService>((ref) {
  return ChallengeBadgeService();
});

// Provider for rewards service
final rewardsServiceProvider = Provider<RewardsService>((ref) {
  return RewardsService();
});

// Provider for user's streak milestones
final userMilestonesProvider =
    FutureProvider.family<List<StreakMilestoneModel>, String>(
  (ref, userId) async {
    final milestoneService = ref.watch(streakMilestoneServiceProvider);
    return await milestoneService.getUserMilestones(userId);
  },
);

// Provider for user's challenge badges
final userBadgesProvider =
    FutureProvider.family<List<ChallengeBadgeModel>, String>(
  (ref, userId) async {
    final badgeService = ref.watch(challengeBadgeServiceProvider);
    return await badgeService.getUserBadges(userId);
  },
);

// Provider to check for new milestone when user streak updates
final checkMilestoneProvider =
    FutureProvider.family<StreakMilestoneModel?, UserModel>(
  (ref, user) async {
    final milestoneService = ref.watch(streakMilestoneServiceProvider);
    return await milestoneService.checkForMilestone(user);
  },
);

// Provider for current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final authService = AuthService();
  final user = authService.currentUser;
  if (user == null) return null;

  // Convert Firebase User to UserModel
  return UserModel(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName,
    createdAt: user.metadata.creationTime ?? DateTime.now(),
    lastActive: user.metadata.lastSignInTime ?? DateTime.now(),
    currentStreak: 0,
    longestStreak: 0,
    totalDaysClean: 0,
    triggers: [],
    copingStrategies: [],
    preferences: {},
    recoveryStartDate: DateTime.now(),
  );
});
