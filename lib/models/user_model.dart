import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final DateTime createdAt;
  final DateTime lastActive;
  final DateTime? recoveryStartDate;
  final String? country;
  final String? timezone;
  final int age;
  final String? gender;
  final int currentStreak;
  final int longestStreak;
  final int totalDaysClean;
  final int urgesResisted;
  final int checkInsCompleted;
  final bool isAnonymous;
  final bool isProfileComplete;
  final Map<String, dynamic> preferences;
  final List<String> triggers;
  final List<String> copingStrategies;
  final List<String> earnedBadges;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    required this.createdAt,
    required this.lastActive,
    this.recoveryStartDate,
    this.country,
    this.timezone,
    this.age = 0,
    this.gender,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalDaysClean = 0,
    this.urgesResisted = 0,
    this.checkInsCompleted = 0,
    this.isAnonymous = true,
    this.isProfileComplete = false,
    this.preferences = const {},
    this.triggers = const [],
    this.copingStrategies = const [],
    this.earnedBadges = const [],
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
      recoveryStartDate: data['recoveryStartDate'] != null
          ? (data['recoveryStartDate'] as Timestamp).toDate()
          : null,
      country: data['country'],
      timezone: data['timezone'],
      age: data['age'] ?? 0,
      gender: data['gender'],
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalDaysClean: data['totalDaysClean'] ?? 0,
      urgesResisted: data['urgesResisted'] ?? 0,
      checkInsCompleted: data['checkInsCompleted'] ?? 0,
      isAnonymous: data['isAnonymous'] ?? true,
      isProfileComplete: data['isProfileComplete'] ?? false,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      triggers: List<String>.from(data['triggers'] ?? []),
      copingStrategies: List<String>.from(data['copingStrategies'] ?? []),
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
      'recoveryStartDate': recoveryStartDate != null
          ? Timestamp.fromDate(recoveryStartDate!)
          : null,
      'country': country,
      'timezone': timezone,
      'age': age,
      'gender': gender,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalDaysClean': totalDaysClean,
      'urgesResisted': urgesResisted,
      'checkInsCompleted': checkInsCompleted,
      'isAnonymous': isAnonymous,
      'isProfileComplete': isProfileComplete,
      'preferences': preferences,
      'triggers': triggers,
      'copingStrategies': copingStrategies,
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
    DateTime? recoveryStartDate,
    String? country,
    String? timezone,
    int? age,
    String? gender,
    int? currentStreak,
    int? longestStreak,
    int? totalDaysClean,
    int? urgesResisted,
    int? checkInsCompleted,
    bool? isAnonymous,
    bool? isProfileComplete,
    Map<String, dynamic>? preferences,
    List<String>? triggers,
    List<String>? copingStrategies,
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
      recoveryStartDate: recoveryStartDate ?? this.recoveryStartDate,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalDaysClean: totalDaysClean ?? this.totalDaysClean,
      urgesResisted: urgesResisted ?? this.urgesResisted,
      checkInsCompleted: checkInsCompleted ?? this.checkInsCompleted,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      preferences: preferences ?? this.preferences,
      triggers: triggers ?? this.triggers,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      earnedBadges: earnedBadges ?? this.earnedBadges,
    );
  }
}
