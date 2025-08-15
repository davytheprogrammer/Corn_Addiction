import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String challengeType; // 'weekly' or 'monthly'
  final DateTime startDate;
  final DateTime endDate;
  final String badgeId; // ID of the badge awarded for completion
  final String badgeName;
  final String badgeDescription;
  final String badgeImagePath;
  final Map<String, dynamic> requirements; // Challenge completion requirements
  final bool isActive;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.challengeType,
    required this.startDate,
    required this.endDate,
    required this.badgeId,
    required this.badgeName,
    required this.badgeDescription,
    required this.badgeImagePath,
    this.requirements = const {},
    this.isActive = true,
  });

  factory ChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      challengeType: data['challengeType'] ?? 'weekly',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      badgeId: data['badgeId'] ?? '',
      badgeName: data['badgeName'] ?? '',
      badgeDescription: data['badgeDescription'] ?? '',
      badgeImagePath: data['badgeImagePath'] ?? '',
      requirements: Map<String, dynamic>.from(data['requirements'] ?? {}),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'challengeType': challengeType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'badgeId': badgeId,
      'badgeName': badgeName,
      'badgeDescription': badgeDescription,
      'badgeImagePath': badgeImagePath,
      'requirements': requirements,
      'isActive': isActive,
    };
  }

  // Helper method to check if a challenge is currently active
  bool isCurrentlyActive() {
    final now = DateTime.now();
    return isActive && startDate.isBefore(now) && endDate.isAfter(now);
  }

  // Helper method to check if a challenge has ended
  bool hasEnded() {
    return DateTime.now().isAfter(endDate);
  }
}