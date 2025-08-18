import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntryModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final int mood; // 1-10 scale
  final List<String> tags;

  JournalEntryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.mood,
    required this.tags,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json, String id) {
    return JournalEntryModel(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              json['createdAt'] ?? DateTime.now().toIso8601String()),
      mood: json['mood'] ?? 5,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'mood': mood,
      'tags': tags,
    };
  }

  JournalEntryModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    int? mood,
    List<String>? tags,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
    );
  }
}
