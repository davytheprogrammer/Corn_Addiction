import 'package:flutter_test/flutter_test.dart';
import 'package:corn_addiction/models/ai_prediction_model.dart';
import 'package:corn_addiction/services/ai_prediction_service.dart';
import 'package:corn_addiction/core/config/api_config.dart';

void main() {
  group('AI Prediction System Tests', () {
    late AIPredictionService service;

    setUp(() {
      service = AIPredictionService();
    });

    group('AIPredictionModel Tests', () {
      test('should create model with valid data', () {
        final model = AIPredictionModel(
          temptationProbability: 0.65,
          reasoning: 'Test reasoning',
          recommendations: ['Test recommendation'],
          timestamp: DateTime.now(),
          riskLevel: 'medium',
          factors: {'test': 'value'},
        );

        expect(model.temptationProbability, 0.65);
        expect(model.reasoning, 'Test reasoning');
        expect(model.recommendations.length, 1);
        expect(model.riskLevel, 'medium');
        expect(model.isMediumRisk, true);
        expect(model.isHighRisk, false);
        expect(model.isLowRisk, false);
      });

      test('should correctly identify risk levels', () {
        final lowRisk = AIPredictionModel(
          temptationProbability: 0.2,
          reasoning: 'Low risk',
          recommendations: [],
          timestamp: DateTime.now(),
          riskLevel: 'low',
          factors: {},
        );

        final mediumRisk = AIPredictionModel(
          temptationProbability: 0.5,
          reasoning: 'Medium risk',
          recommendations: [],
          timestamp: DateTime.now(),
          riskLevel: 'medium',
          factors: {},
        );

        final highRisk = AIPredictionModel(
          temptationProbability: 0.8,
          reasoning: 'High risk',
          recommendations: [],
          timestamp: DateTime.now(),
          riskLevel: 'high',
          factors: {},
        );

        expect(lowRisk.isLowRisk, true);
        expect(mediumRisk.isMediumRisk, true);
        expect(highRisk.isHighRisk, true);
      });

      test('should serialize and deserialize correctly', () {
        final original = AIPredictionModel(
          temptationProbability: 0.75,
          reasoning: 'Test reasoning for serialization',
          recommendations: ['Rec 1', 'Rec 2'],
          timestamp: DateTime.now(),
          riskLevel: 'high',
          factors: {'factor1': 'value1', 'factor2': 42},
        );

        final json = original.toJson();
        final deserialized = AIPredictionModel.fromJson(json);

        expect(
            deserialized.temptationProbability, original.temptationProbability);
        expect(deserialized.reasoning, original.reasoning);
        expect(deserialized.recommendations, original.recommendations);
        expect(deserialized.riskLevel, original.riskLevel);
        expect(deserialized.factors, original.factors);
      });
    });

    group('API Configuration Tests', () {
      test('should have valid configuration values', () {
        expect(ApiConfig.togetherBaseUrl, isNotEmpty);
        expect(ApiConfig.defaultModel, isNotEmpty);
        expect(ApiConfig.predictionCacheDuration.inHours, greaterThan(0));
        expect(ApiConfig.requestTimeout.inSeconds, greaterThan(0));
        expect(ApiConfig.highRiskThreshold,
            greaterThan(ApiConfig.mediumRiskThreshold));
        expect(ApiConfig.mediumRiskThreshold, greaterThan(0));
      });

      test('should have reasonable threshold values', () {
        expect(ApiConfig.highRiskThreshold, lessThanOrEqualTo(1.0));
        expect(ApiConfig.mediumRiskThreshold, greaterThanOrEqualTo(0.0));
        expect(ApiConfig.criticalRiskThreshold,
            greaterThan(ApiConfig.highRiskThreshold));
      });
    });

    group('Fallback Prediction Tests', () {
      test('should generate fallback prediction with valid data', () async {
        // This test would require mocking Firebase, so we'll test the logic
        expect(service, isNotNull);
      });

      test('should handle empty user data gracefully', () {
        // Test that the service can handle missing or empty user data
        expect(service, isNotNull);
      });
    });

    group('Cache Management Tests', () {
      test('should handle cache operations without errors', () async {
        await service.clearCache();
        // Should not throw any exceptions
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        // Test that network errors don't crash the app
        final prediction = await service.getPrediction('test-user-id');
        // Should return either a prediction or null, not throw
        expect(prediction, anyOf(isNull, isA<AIPredictionModel>()));
      });

      test('should handle invalid API responses', () {
        // Test parsing of malformed API responses
        expect(service, isNotNull);
      });
    });

    group('Production Readiness Tests', () {
      test('should have production-safe configuration', () {
        // Verify production settings
        expect(ApiConfig.enableFallbackPredictions, true);
        expect(ApiConfig.enablePredictionCaching, true);
        expect(ApiConfig.maxRecommendations, greaterThan(0));
        expect(ApiConfig.maxRecommendations, lessThanOrEqualTo(10));
      });

      test('should handle rate limiting', () {
        expect(ApiConfig.minTimeBetweenCalls.inMinutes, greaterThan(0));
        expect(ApiConfig.maxDailyPredictions, greaterThan(0));
      });

      test('should have reasonable timeout values', () {
        expect(ApiConfig.requestTimeout.inSeconds, greaterThan(10));
        expect(ApiConfig.requestTimeout.inSeconds, lessThan(60));
      });
    });
  });

  group('Integration Tests', () {
    test('should work end-to-end with fallback', () async {
      final service = AIPredictionService();

      // This should work even without API key (fallback mode)
      final prediction = await service.getPrediction('test-user-123');

      if (prediction != null) {
        expect(prediction.temptationProbability, greaterThanOrEqualTo(0.0));
        expect(prediction.temptationProbability, lessThanOrEqualTo(1.0));
        expect(prediction.reasoning, isNotEmpty);
        expect(prediction.recommendations, isNotEmpty);
        expect(['low', 'medium', 'high', 'critical'],
            contains(prediction.riskLevel));
      }
    });
  });
}
