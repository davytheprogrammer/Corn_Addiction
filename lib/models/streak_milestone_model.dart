import 'package:cloud_firestore/cloud_firestore.dart';

class StreakMilestoneModel {
  final String id;
  final String userId;
  final int milestone; // 1, 7, 30, 90, or 365 days
  final DateTime achievedAt;
  final bool rewardClaimed;
  final String? animationPath; // Path to the animation asset
  final Map<String, dynamic> rewards; // In-app rewards data

  StreakMilestoneModel({
    required this.id,
    required this.userId,
    required this.milestone,
    required this.achievedAt,
    this.rewardClaimed = false,
    this.animationPath,
    this.rewards = const {},
  });

  factory StreakMilestoneModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StreakMilestoneModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      milestone: data['milestone'] ?? 0,
      achievedAt: (data['achievedAt'] as Timestamp).toDate(),
      rewardClaimed: data['rewardClaimed'] ?? false,
      animationPath: data['animationPath'],
      rewards: Map<String, dynamic>.from(data['rewards'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'milestone': milestone,
      'achievedAt': Timestamp.fromDate(achievedAt),
      'rewardClaimed': rewardClaimed,
      'animationPath': animationPath,
      'rewards': rewards,
    };
  }

  // CopyWith method to create a new instance with updated fields
  StreakMilestoneModel copyWith({
    String? id,
    String? userId,
    int? milestone,
    DateTime? achievedAt,
    bool? rewardClaimed,
    String? animationPath,
    Map<String, dynamic>? rewards,
  }) {
    return StreakMilestoneModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      milestone: milestone ?? this.milestone,
      achievedAt: achievedAt ?? this.achievedAt,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
      animationPath: animationPath ?? this.animationPath,
      rewards: rewards ?? this.rewards,
    );
  }

  // Helper method to get animation path based on milestone
  static String getAnimationPathForMilestone(int milestone) {
    switch (milestone) {
      case 1:
        return 'assets/animations/streak_milestone_1.json';
      case 7:
        return 'assets/animations/streak_milestone_7.json';
      case 30:
        return 'assets/animations/streak_milestone_30.json';
      case 90:
        return 'assets/animations/streak_milestone_90.json';
      case 365:
        return 'assets/animations/streak_milestone_365.json';
      default:
        return 'assets/animations/streak_milestone_default.json';
    }
  }

  // Helper method to check if a milestone is achieved
  static bool isMilestoneDay(int streakDays) {
    return streakDays == 1 || streakDays == 7 || streakDays == 30 || 
           streakDays == 90 || streakDays == 365;
  }
}