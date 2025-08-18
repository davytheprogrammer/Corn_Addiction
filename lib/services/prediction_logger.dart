import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';

class PredictionLogger {
  static const String _logKey = 'prediction_logs';
  static const String _metricsKey = 'prediction_metrics';
  static const int _maxLogEntries = 50;

  static Future<void> logPrediction({
    required String userId,
    required double probability,
    required String source, // 'ai' or 'fallback'
    required Duration responseTime,
    String? error,
  }) async {
    if (!ApiConfig.enableDetailedLogging) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = await _getLogs();

      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId.substring(0, 8), // Anonymized
        'probability': probability,
        'source': source,
        'responseTimeMs': responseTime.inMilliseconds,
        'error': error,
      };

      logs.add(logEntry);

      // Keep only recent logs
      if (logs.length > _maxLogEntries) {
        logs.removeRange(0, logs.length - _maxLogEntries);
      }

      await prefs.setString(_logKey, jsonEncode(logs));
      await _updateMetrics(source, error != null);
    } catch (e) {
      print('Error logging prediction: $e');
    }
  }

  static Future<void> logError({
    required String operation,
    required String error,
    Map<String, dynamic>? context,
  }) async {
    if (!ApiConfig.enableDetailedLogging) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = await _getLogs();

      final errorEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'error',
        'operation': operation,
        'error': error,
        'context': context ?? {},
      };

      logs.add(errorEntry);

      if (logs.length > _maxLogEntries) {
        logs.removeRange(0, logs.length - _maxLogEntries);
      }

      await prefs.setString(_logKey, jsonEncode(logs));
    } catch (e) {
      print('Error logging error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> _getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsString = prefs.getString(_logKey);

      if (logsString != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(logsString));
      }
    } catch (e) {
      print('Error getting logs: $e');
    }
    return [];
  }

  static Future<void> _updateMetrics(String source, bool hasError) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsString = prefs.getString(_metricsKey);

      Map<String, dynamic> metrics = {};
      if (metricsString != null) {
        metrics = Map<String, dynamic>.from(jsonDecode(metricsString));
      }

      // Initialize metrics if needed
      metrics['totalPredictions'] = (metrics['totalPredictions'] ?? 0) + 1;
      metrics['aiPredictions'] =
          (metrics['aiPredictions'] ?? 0) + (source == 'ai' ? 1 : 0);
      metrics['fallbackPredictions'] = (metrics['fallbackPredictions'] ?? 0) +
          (source == 'fallback' ? 1 : 0);
      metrics['errors'] = (metrics['errors'] ?? 0) + (hasError ? 1 : 0);
      metrics['lastUpdated'] = DateTime.now().toIso8601String();

      await prefs.setString(_metricsKey, jsonEncode(metrics));
    } catch (e) {
      print('Error updating metrics: $e');
    }
  }

  static Future<Map<String, dynamic>> getMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsString = prefs.getString(_metricsKey);

      if (metricsString != null) {
        return Map<String, dynamic>.from(jsonDecode(metricsString));
      }
    } catch (e) {
      print('Error getting metrics: $e');
    }
    return {};
  }

  static Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logKey);
      await prefs.remove(_metricsKey);
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }
}
