class AIPredictionModel {
  final double temptationProbability;
  final String reasoning;
  final List<String> recommendations;
  final DateTime timestamp;
  final String riskLevel;
  final Map<String, dynamic> factors;

  AIPredictionModel({
    required this.temptationProbability,
    required this.reasoning,
    required this.recommendations,
    required this.timestamp,
    required this.riskLevel,
    required this.factors,
  });

  factory AIPredictionModel.fromJson(Map<String, dynamic> json) {
    return AIPredictionModel(
      temptationProbability: (json['temptationProbability'] as num).toDouble(),
      reasoning: json['reasoning'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      timestamp: DateTime.parse(json['timestamp']),
      riskLevel: json['riskLevel'] ?? 'medium',
      factors: Map<String, dynamic>.from(json['factors'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temptationProbability': temptationProbability,
      'reasoning': reasoning,
      'recommendations': recommendations,
      'timestamp': timestamp.toIso8601String(),
      'riskLevel': riskLevel,
      'factors': factors,
    };
  }

  String get riskLevelText {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return 'Low Risk';
      case 'medium':
        return 'Medium Risk';
      case 'high':
        return 'High Risk';
      case 'critical':
        return 'Critical Risk';
      default:
        return 'Unknown Risk';
    }
  }

  bool get isHighRisk => temptationProbability >= 0.7;
  bool get isMediumRisk =>
      temptationProbability >= 0.4 && temptationProbability < 0.7;
  bool get isLowRisk => temptationProbability < 0.4;
}
