import 'package:cloud_firestore/cloud_firestore.dart';

class AIHabitModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final int priority; // 1-5, 5 being highest priority
  final int estimatedMinutes;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String aiReasoning; // Why AI suggested this habit
  final List<String> tags;
  final Map<String, dynamic> metadata;

  AIHabitModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.estimatedMinutes,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    required this.aiReasoning,
    required this.tags,
    required this.metadata,
  });

  factory AIHabitModel.fromJson(Map<String, dynamic> json, String id) {
    return AIHabitModel(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? 3,
      estimatedMinutes: json['estimatedMinutes'] ?? 10,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is Timestamp
              ? (json['completedAt'] as Timestamp).toDate()
              : DateTime.parse(json['completedAt']))
          : null,
      aiReasoning: json['aiReasoning'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'estimatedMinutes': estimatedMinutes,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'aiReasoning': aiReasoning,
      'tags': tags,
      'metadata': metadata,
    };
  }

  AIHabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    int? priority,
    int? estimatedMinutes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? aiReasoning,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return AIHabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      aiReasoning: aiReasoning ?? this.aiReasoning,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }
}

class HabitCompletionStats {
  final int totalHabits;
  final int completedHabits;
  final int streakDays;
  final double completionRate;
  final Map<String, int> categoryStats;
  final List<String> recentCompletions;

  HabitCompletionStats({
    required this.totalHabits,
    required this.completedHabits,
    required this.streakDays,
    required this.completionRate,
    required this.categoryStats,
    required this.recentCompletions,
  });

  factory HabitCompletionStats.fromJson(Map<String, dynamic> json) {
    return HabitCompletionStats(
      totalHabits: json['totalHabits'] ?? 0,
      completedHabits: json['completedHabits'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      categoryStats: Map<String, int>.from(json['categoryStats'] ?? {}),
      recentCompletions: List<String>.from(json['recentCompletions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'streakDays': streakDays,
      'completionRate': completionRate,
      'categoryStats': categoryStats,
      'recentCompletions': recentCompletions,
    };
  }
}
