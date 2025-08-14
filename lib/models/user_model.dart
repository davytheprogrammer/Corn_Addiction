import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastActive;
  final DateTime? recoveryStartDate;
  final int currentStreak;
  final int longestStreak;
  final int totalDaysClean;
  final int urgesResisted;
  final int checkInsCompleted;
  final bool isAnonymous;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.lastActive,
    this.recoveryStartDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalDaysClean = 0,
    this.urgesResisted = 0,
    this.checkInsCompleted = 0,
    this.isAnonymous = true,
    this.preferences = const {},
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      recoveryStartDate: data['recoveryStartDate'] != null
          ? (data['recoveryStartDate'] as Timestamp).toDate()
          : null,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalDaysClean: data['totalDaysClean'] ?? 0,
      urgesResisted: data['urgesResisted'] ?? 0,
      checkInsCompleted: data['checkInsCompleted'] ?? 0,
      isAnonymous: data['isAnonymous'] ?? true,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'recoveryStartDate': recoveryStartDate != null
          ? Timestamp.fromDate(recoveryStartDate!)
          : null,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalDaysClean': totalDaysClean,
      'urgesResisted': urgesResisted,
      'checkInsCompleted': checkInsCompleted,
      'isAnonymous': isAnonymous,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastActive,
    DateTime? recoveryStartDate,
    int? currentStreak,
    int? longestStreak,
    int? totalDaysClean,
    int? urgesResisted,
    int? checkInsCompleted,
    bool? isAnonymous,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      recoveryStartDate: recoveryStartDate ?? this.recoveryStartDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalDaysClean: totalDaysClean ?? this.totalDaysClean,
      urgesResisted: urgesResisted ?? this.urgesResisted,
      checkInsCompleted: checkInsCompleted ?? this.checkInsCompleted,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      preferences: preferences ?? this.preferences,
    );
  }
}
