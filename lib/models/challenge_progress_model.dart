import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeProgressModel {
  final String id;
  final String userId;
  final String challengeId;
  final Map<String, dynamic> progress; // Progress towards requirements
  final bool isCompleted;
  final DateTime? completedAt;
  final bool badgeAwarded;

  ChallengeProgressModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    this.progress = const {},
    this.isCompleted = false,
    this.completedAt,
    this.badgeAwarded = false,
  });

  factory ChallengeProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      challengeId: data['challengeId'] ?? '',
      progress: Map<String, dynamic>.from(data['progress'] ?? {}),
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
      badgeAwarded: data['badgeAwarded'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'progress': progress,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'badgeAwarded': badgeAwarded,
    };
  }

  // Helper method to update progress
  ChallengeProgressModel updateProgress(String key, dynamic value) {
    final updatedProgress = Map<String, dynamic>.from(progress);
    updatedProgress[key] = value;
    
    return ChallengeProgressModel(
      id: id,
      userId: userId,
      challengeId: challengeId,
      progress: updatedProgress,
      isCompleted: isCompleted,
      completedAt: completedAt,
      badgeAwarded: badgeAwarded,
    );
  }

  // Helper method to mark challenge as completed
  ChallengeProgressModel markAsCompleted() {
    return ChallengeProgressModel(
      id: id,
      userId: userId,
      challengeId: challengeId,
      progress: progress,
      isCompleted: true,
      completedAt: DateTime.now(),
      badgeAwarded: badgeAwarded,
    );
  }

  // Helper method to mark badge as awarded
  ChallengeProgressModel markBadgeAwarded() {
    return ChallengeProgressModel(
      id: id,
      userId: userId,
      challengeId: challengeId,
      progress: progress,
      isCompleted: isCompleted,
      completedAt: completedAt,
      badgeAwarded: true,
    );
  }
}