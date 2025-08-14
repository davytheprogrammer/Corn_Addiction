import 'package:cloud_firestore/cloud_firestore.dart';

enum UrgeIntensity { low, medium, high, extreme }

class UrgeLogModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final UrgeIntensity intensity;
  final List<String> triggers;
  final String? copingStrategy;
  final String? notes;
  final bool wasResisted;
  final int durationMinutes;

  UrgeLogModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.intensity,
    this.triggers = const [],
    this.copingStrategy,
    this.notes,
    this.wasResisted = true,
    this.durationMinutes = 0,
  });

  factory UrgeLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UrgeLogModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      intensity: UrgeIntensity.values.firstWhere(
        (e) => e.name == data['intensity'],
        orElse: () => UrgeIntensity.medium,
      ),
      triggers: List<String>.from(data['triggers'] ?? []),
      copingStrategy: data['copingStrategy'],
      notes: data['notes'],
      wasResisted: data['wasResisted'] ?? true,
      durationMinutes: data['durationMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'intensity': intensity.name,
      'triggers': triggers,
      'copingStrategy': copingStrategy,
      'notes': notes,
      'wasResisted': wasResisted,
      'durationMinutes': durationMinutes,
    };
  }

  UrgeLogModel copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    UrgeIntensity? intensity,
    List<String>? triggers,
    String? copingStrategy,
    String? notes,
    bool? wasResisted,
    int? durationMinutes,
  }) {
    return UrgeLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      intensity: intensity ?? this.intensity,
      triggers: triggers ?? this.triggers,
      copingStrategy: copingStrategy ?? this.copingStrategy,
      notes: notes ?? this.notes,
      wasResisted: wasResisted ?? this.wasResisted,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
