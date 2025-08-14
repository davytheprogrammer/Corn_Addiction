import 'package:cloud_firestore/cloud_firestore.dart';

class DailyCheckInModel {
  final String id;
  final String userId;
  final DateTime date;
  final int moodRating; // 1-10 scale
  final String? challenges;
  final String? gratefulFor;
  final List<String> emotions;
  final String? notes;
  final DateTime createdAt;

  DailyCheckInModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodRating,
    this.challenges,
    this.gratefulFor,
    this.emotions = const [],
    this.notes,
    required this.createdAt,
  });

  factory DailyCheckInModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyCheckInModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      moodRating: data['moodRating'] ?? 5,
      challenges: data['challenges'],
      gratefulFor: data['gratefulFor'],
      emotions: List<String>.from(data['emotions'] ?? []),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'moodRating': moodRating,
      'challenges': challenges,
      'gratefulFor': gratefulFor,
      'emotions': emotions,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DailyCheckInModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? moodRating,
    String? challenges,
    String? gratefulFor,
    List<String>? emotions,
    String? notes,
    DateTime? createdAt,
  }) {
    return DailyCheckInModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      moodRating: moodRating ?? this.moodRating,
      challenges: challenges ?? this.challenges,
      gratefulFor: gratefulFor ?? this.gratefulFor,
      emotions: emotions ?? this.emotions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
