import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final DateTime createdAt;
  final DateTime lastActive;
  final String? country;
  final String? language;
  final bool isProfileComplete;
  final Map<String, dynamic> preferences;
  final int recoveryStartDate; // timestamp when user started recovery
  final int currentStreak; // current streak in days
  final int longestStreak; // longest streak achieved in days
  final List<String> triggers; // user's identified triggers
  final Map<String, dynamic> recoveryGoals; // daily, weekly, monthly goals
  final int totalCleanDays; // total number of clean days
  final List<String> copingStrategies; // user's preferred coping strategies
  final List<int> achievedMilestones; // streak milestones achieved (1, 7, 30, 90, 365 days)
  final List<String> earnedBadges; // IDs of badges earned from challenges

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    required this.createdAt,
    required this.lastActive,
    this.country,
    this.language,
    this.isProfileComplete = false,
    this.preferences = const {},
    this.recoveryStartDate = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.triggers = const [],
    this.recoveryGoals = const {},
    this.totalCleanDays = 0,
    this.copingStrategies = const [],
    this.achievedMilestones = const [],
    this.earnedBadges = const []
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      country: data['country'],
      language: data['language'],
      isProfileComplete: data['isProfileComplete'] ?? false,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      recoveryStartDate: data['recoveryStartDate'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      triggers: List<String>.from(data['triggers'] ?? []),
      recoveryGoals: Map<String, dynamic>.from(data['recoveryGoals'] ?? {}),
      totalCleanDays: data['totalCleanDays'] ?? 0,
      copingStrategies: List<String>.from(data['copingStrategies'] ?? []),
      achievedMilestones: List<int>.from(data['achievedMilestones'] ?? []),
      earnedBadges: List<String>.from(data['earnedBadges'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'country': country,
      'language': language,
      'isProfileComplete': isProfileComplete,
      'preferences': preferences,
      'recoveryStartDate': recoveryStartDate,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'triggers': triggers,
      'recoveryGoals': recoveryGoals,
      'totalCleanDays': totalCleanDays,
      'copingStrategies': copingStrategies,
      'achievedMilestones': achievedMilestones,
      'earnedBadges': earnedBadges,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
    DateTime? lastActive,
    String? country,
    String? language,
    bool? isProfileComplete,
    Map<String, dynamic>? preferences,
    int? recoveryStartDate,
    int? currentStreak,
    int? longestStreak,
    List<String>? triggers,
    Map<String, dynamic>? recoveryGoals,
    int? totalCleanDays,
    List<String>? copingStrategies,
    List<int>? achievedMilestones,
    List<String>? earnedBadges,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      country: country ?? this.country,
      language: language ?? this.language,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      preferences: preferences ?? this.preferences,
      recoveryStartDate: recoveryStartDate ?? this.recoveryStartDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      triggers: triggers ?? this.triggers,
      recoveryGoals: recoveryGoals ?? this.recoveryGoals,
      totalCleanDays: totalCleanDays ?? this.totalCleanDays,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      achievedMilestones: achievedMilestones ?? this.achievedMilestones,
      earnedBadges: earnedBadges ?? this.earnedBadges,
    );
  }
}
