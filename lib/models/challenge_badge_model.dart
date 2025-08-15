import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeBadgeModel {
  final String id;
  final String userId;
  final String badgeId;
  final String badgeName;
  final String badgeDescription;
  final String badgeImagePath;
  final DateTime earnedAt;
  final String challengeType; // 'weekly' or 'monthly'
  final String challengeId;
  final bool isDisplayed; // Whether user has chosen to display this badge

  ChallengeBadgeModel({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.badgeName,
    required this.badgeDescription,
    required this.badgeImagePath,
    required this.earnedAt,
    required this.challengeType,
    required this.challengeId,
    this.isDisplayed = true,
  });

  factory ChallengeBadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeBadgeModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      badgeId: data['badgeId'] ?? '',
      badgeName: data['badgeName'] ?? '',
      badgeDescription: data['badgeDescription'] ?? '',
      badgeImagePath: data['badgeImagePath'] ?? '',
      earnedAt: (data['earnedAt'] as Timestamp).toDate(),
      challengeType: data['challengeType'] ?? 'weekly',
      challengeId: data['challengeId'] ?? '',
      isDisplayed: data['isDisplayed'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'badgeId': badgeId,
      'badgeName': badgeName,
      'badgeDescription': badgeDescription,
      'badgeImagePath': badgeImagePath,
      'earnedAt': Timestamp.fromDate(earnedAt),
      'challengeType': challengeType,
      'challengeId': challengeId,
      'isDisplayed': isDisplayed,
    };
  }
  
  // CopyWith method to create a new instance with updated fields
  ChallengeBadgeModel copyWith({
    String? id,
    String? userId,
    String? badgeId,
    String? badgeName,
    String? badgeDescription,
    String? badgeImagePath,
    DateTime? earnedAt,
    String? challengeType,
    String? challengeId,
    bool? isDisplayed,
  }) {
    return ChallengeBadgeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      badgeId: badgeId ?? this.badgeId,
      badgeName: badgeName ?? this.badgeName,
      badgeDescription: badgeDescription ?? this.badgeDescription,
      badgeImagePath: badgeImagePath ?? this.badgeImagePath,
      earnedAt: earnedAt ?? this.earnedAt,
      challengeType: challengeType ?? this.challengeType,
      challengeId: challengeId ?? this.challengeId,
      isDisplayed: isDisplayed ?? this.isDisplayed,
    );
  }
}