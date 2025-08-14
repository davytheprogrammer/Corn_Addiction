import 'package:cloud_firestore/cloud_firestore.dart';

class StreakModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int daysCount;
  final bool isActive;
  final String? endReason;

  StreakModel({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.daysCount,
    this.isActive = true,
    this.endReason,
  });

  factory StreakModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StreakModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      daysCount: data['daysCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      endReason: data['endReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'daysCount': daysCount,
      'isActive': isActive,
      'endReason': endReason,
    };
  }
}
