import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_prediction_model.dart';
import '../core/config/api_config.dart';
import 'ai_habit_service.dart';

class AIPredictionService {
  static const String _cacheKey = 'ai_prediction_cache';
  static const String _lastUpdateKey = 'ai_prediction_last_update';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIHabitService _habitService = AIHabitService();

  Future<AIPredictionModel?> getPrediction(String userId) async {
    print('🤖 AI Prediction Service: getPrediction called for user: $userId');
    try {
      // Check cache first
      final cachedPrediction = await _getCachedPrediction();
      final isCacheValid = await _isCacheValid();

      print('🤖 AI Prediction Service: Cache valid: $isCacheValid');
      if (cachedPrediction != null) {
        print(
            '🤖 AI Prediction Service: Found cached prediction with ${(cachedPrediction.temptationProbability * 100).round()}% risk');
      }

      if (cachedPrediction != null && isCacheValid) {
        print('🤖 AI Prediction Service: Returning cached prediction');
        return cachedPrediction;
      }

      print('🤖 AI Prediction Service: Fetching fresh prediction...');
      // Fetch fresh prediction from AI
      final prediction = await _fetchFreshPrediction(userId);
      if (prediction != null) {
        print(
            '🤖 AI Prediction Service: Fresh prediction received with ${(prediction.temptationProbability * 100).round()}% risk');
        await _cachePrediction(prediction);
      } else {
        print('🤖 AI Prediction Service: Failed to get fresh prediction');
      }

      return prediction;
    } catch (e) {
      print('🤖 AI Prediction Service: Error getting AI prediction: $e');
      // Return cached prediction even if expired as fallback
      final fallback = await _getCachedPrediction();
      if (fallback != null) {
        print(
            '🤖 AI Prediction Service: Returning expired cached prediction as fallback');
      }
      return fallback;
    }
  }

  Future<AIPredictionModel?> _fetchFreshPrediction(String userId) async {
    print(
        '🤖 AI Prediction Service: _fetchFreshPrediction started for user: $userId');
    try {
      // Gather user data from Firebase
      print('🤖 AI Prediction Service: Gathering user data from Firebase...');
      final userData = await _gatherUserData(userId);
      print(
          '🤖 AI Prediction Service: User data gathered - Current streak: ${userData['streakStats']?['currentStreak'] ?? 0} days');

      // Skip API call if no API key configured, use fallback
      if (ApiConfig.togetherApiKey == 'YOUR_TOGETHER_API_KEY_HERE' ||
          ApiConfig.togetherApiKey.isEmpty) {
        print(
            '🤖 AI Prediction Service: No API key configured, using fallback prediction');
        return _generateFallbackPrediction(userData);
      }

      // Create AI prompt with user data
      final prompt = _createPrompt(userData);
      print('🤖 AI Prediction Service: AI prompt created, making API call...');

      // Try models in order with model-specific timeouts and simple retries.
      final models = [
        ApiConfig.defaultModel,
        ApiConfig.fallbackModel,
        ApiConfig.fastModel,
      ];

      final timeouts = [
        ApiConfig.defaultModelTimeout,
        ApiConfig.fallbackModelTimeout,
        ApiConfig.fastModelTimeout,
      ];

      for (int m = 0; m < models.length; m++) {
        final model = models[m];
        final timeout = timeouts[m];

        print('🤖 AI Prediction Service: Attempting model "$model" with timeout ${timeout.inSeconds}s');

        try {
          final response = await http
              .post(
                Uri.parse(ApiConfig.togetherBaseUrl),
                headers: {
                  'Authorization': 'Bearer ${ApiConfig.togetherApiKey}',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'model': model,
                  'messages': [
                    {
                      'role': 'system',
                      'content': _getSystemPrompt(),
                    },
                    {
                      'role': 'user',
                      'content': prompt,
                    }
                  ],
                  'max_tokens': 800,
                  'temperature': 0.2,
                  'top_p': 0.8,
                  'stop': ['Human:', 'User:'],
                }),
              )
              .timeout(timeout);

          print('🤖 AI Prediction Service: API response status: ${response.statusCode} (model: $model)');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final aiResponse = data['choices']?[0]?['message']?['content'];

            if (aiResponse != null) {
              print('🤖 AI Prediction Service: AI response received, parsing...');
              final prediction = _parseAIResponse(aiResponse);
              print('🤖 AI Prediction Service: AI prediction parsed successfully (model: $model)');
              return prediction;
            } else {
              print('🤖 AI Prediction Service: No AI response content found (model: $model)');
            }
          } else {
            // Try to detect model-unavailable errors and continue to next model
            try {
              final body = response.body;
              final parsed = jsonDecode(body);
              final errorCode = parsed['error']?['code'];
              final errorMessage = parsed['error']?['message'];
              print('🤖 AI Prediction Service: API Error: ${response.statusCode} - $errorMessage (code: $errorCode)');

              if (response.statusCode == 503 || errorCode == 'model_not_available' || parsed['error'] != null) {
                print('🤖 AI Prediction Service: Service/model unavailable for "$model", trying next model');
                continue; // try next model in list
              }
            } catch (_) {
              print('🤖 AI Prediction Service: API Error: ${response.statusCode} - ${response.body}');
            }
          }
        } on SocketException catch (e) {
          print('🤖 AI Prediction Service: Network error with model $model - $e');
          // try next model
          continue;
        } on TimeoutException catch (e) {
          print('🤖 AI Prediction Service: Timeout when calling model $model - $e');
          continue;
        } catch (e) {
          print('🤖 AI Prediction Service: Unexpected error calling model $model - $e');
          continue;
        }
      }

      // Fallback to rule-based prediction
      print(
          '🤖 AI Prediction Service: Using fallback prediction due to API issues');
      return _generateFallbackPrediction(userData);
    } on SocketException catch (e) {
      print(
          '🤖 AI Prediction Service: Network error - $e - using fallback prediction');
      final userData = await _gatherUserData(userId);
      return _generateFallbackPrediction(userData);
    } on HttpException catch (e) {
      print(
          '🤖 AI Prediction Service: HTTP error - $e - using fallback prediction');
      final userData = await _gatherUserData(userId);
      return _generateFallbackPrediction(userData);
    } catch (e) {
      print(
          '🤖 AI Prediction Service: Unexpected error fetching AI prediction: $e');
      final userData = await _gatherUserData(userId);
      return _generateFallbackPrediction(userData);
    }
  }

  String _getSystemPrompt() {
    return '''You are an expert addiction recovery counselor and data analyst specializing in pornography addiction recovery. Your role is to analyze user recovery data and provide accurate temptation risk assessments.

ANALYSIS FRAMEWORK:
- Analyze current streak patterns, historical data, and contextual factors
- Consider psychological triggers: time of day, stress levels, isolation periods
- Evaluate protective factors: coping strategies, support systems, recent successes
- Account for high-risk periods: evenings, weekends, stressful days

RESPONSE FORMAT (JSON only):
{
  "temptationProbability": 0.65,
  "reasoning": "Your current 12-day streak shows strong momentum, but evening hours and weekend timing increase risk. Recent consistent check-ins are protective.",
  "recommendations": ["Take a 15-minute walk outside", "Call your accountability partner", "Practice the 5-4-3-2-1 grounding technique"],
  "riskLevel": "medium",
  "factors": {
    "streakMomentum": "positive",
    "timeContext": "risky", 
    "recentPatterns": "stable"
  }
}

GUIDELINES:
- temptationProbability: 0.0-1.0 (precise decimal, not percentage)
- reasoning: 1-2 sentences, specific to user's data
- recommendations: 3-4 immediate, actionable steps
- riskLevel: "low" (0-0.39), "medium" (0.4-0.69), "high" (0.7-0.89), "critical" (0.9-1.0)
- factors: 3-4 key elements influencing the assessment

Be direct, supportive, and evidence-based. Focus on immediate actionable guidance.''';
  }

  Future<Map<String, dynamic>> _gatherUserData(String userId) async {
    try {
      // Get user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.exists ? userDoc.data() ?? {} : {};

      // Get recent streaks (last 10)
      final streaksQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('streaks')
          .orderBy('startDate', descending: true)
          .limit(10)
          .get();

      final recentStreaks = streaksQuery.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      // Get recent check-ins (last 14 days)
      final fourteenDaysAgo = DateTime.now().subtract(const Duration(days: 14));
      final checkInsQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkIns')
          .where('date', isGreaterThan: Timestamp.fromDate(fourteenDaysAgo))
          .orderBy('date', descending: true)
          .get();

      final recentCheckIns =
          checkInsQuery.docs.map((doc) => doc.data()).toList();

      // Get current time context
      final now = DateTime.now();

      // Calculate streak consistency
      final streakConsistency = _calculateStreakConsistency(recentStreaks);
      final checkInFrequency = _calculateCheckInFrequency(recentCheckIns);

      // Get habit completion stats
      final habitStats = await _habitService.getHabitStatsForAI(userId);
      print(
          '🤖 AI Prediction Service: Habit stats gathered - ${habitStats.completedHabits}/${habitStats.totalHabits} completed, ${habitStats.streakDays} day streak');

      return {
        'user': userData,
        'recentStreaks': recentStreaks,
        'recentCheckIns': recentCheckIns,
        'currentTime': {
          'hour': now.hour,
          'dayOfWeek': now.weekday,
          'isWeekend': now.weekday >= 6,
          'timeOfDay': _getTimeOfDay(now.hour),
          'isHighRiskHour': _isHighRiskHour(now.hour),
        },
        'streakStats': {
          'currentStreak': userData['currentStreak'] ?? 0,
          'longestStreak': userData['longestStreak'] ?? 0,
          'totalDaysClean': userData['totalDaysClean'] ?? 0,
          'consistency': streakConsistency,
        },
        'activityStats': {
          'checkInFrequency': checkInFrequency,
          'recentCheckIns': recentCheckIns.length,
          'lastActiveHours': _getHoursSinceLastActive(userData['lastActive']),
        },
        'habitStats': {
          'totalHabits': habitStats.totalHabits,
          'completedHabits': habitStats.completedHabits,
          'completionRate': habitStats.completionRate,
          'habitStreak': habitStats.streakDays,
          'categoryStats': habitStats.categoryStats,
          'recentCompletions': habitStats.recentCompletions,
        }
      };
    } catch (e) {
      print('Error gathering user data: $e');
      return _getDefaultUserData();
    }
  }

  double _calculateStreakConsistency(List<Map<String, dynamic>> streaks) {
    if (streaks.isEmpty) return 0.0;

    final activeSteaks = streaks.where((s) => s['isActive'] == true).length;
    final totalStreaks = streaks.length;

    return activeSteaks / totalStreaks;
  }

  double _calculateCheckInFrequency(List<Map<String, dynamic>> checkIns) {
    if (checkIns.isEmpty) return 0.0;

    final daysCovered = checkIns.length;
    return (daysCovered / 14.0).clamp(0.0, 1.0); // Last 14 days
  }

  int _getHoursSinceLastActive(dynamic lastActive) {
    if (lastActive == null) return 999;

    try {
      final lastActiveDate = lastActive is Timestamp
          ? lastActive.toDate()
          : DateTime.parse(lastActive.toString());
      return DateTime.now().difference(lastActiveDate).inHours;
    } catch (e) {
      return 999;
    }
  }

  bool _isHighRiskHour(int hour) {
    // High risk: late evening to early morning
    return hour >= 21 || hour <= 6;
  }

  Map<String, dynamic> _getDefaultUserData() {
    final now = DateTime.now();
    return {
      'user': {},
      'recentStreaks': [],
      'recentCheckIns': [],
      'currentTime': {
        'hour': now.hour,
        'dayOfWeek': now.weekday,
        'isWeekend': now.weekday >= 6,
        'timeOfDay': _getTimeOfDay(now.hour),
        'isHighRiskHour': _isHighRiskHour(now.hour),
      },
      'streakStats': {
        'currentStreak': 0,
        'longestStreak': 0,
        'totalDaysClean': 0,
        'consistency': 0.0,
      },
      'activityStats': {
        'checkInFrequency': 0.0,
        'recentCheckIns': 0,
        'lastActiveHours': 999,
      }
    };
  }

  String _createPrompt(Map<String, dynamic> userData) {
    final user = userData['user'] ?? {};
    final streakStats = userData['streakStats'] ?? {};
    final currentTime = userData['currentTime'] ?? {};
    final activityStats = userData['activityStats'] ?? {};
    final habitStats = userData['habitStats'] ?? {};
    final recentCheckIns = userData['recentCheckIns'] ?? [];
    final recentStreaks = userData['recentStreaks'] ?? [];

    return '''RECOVERY DATA ANALYSIS REQUEST

USER PROFILE:
- Current Streak: ${streakStats['currentStreak']} days
- Longest Streak: ${streakStats['longestStreak']} days  
- Total Recovery Days: ${streakStats['totalDaysClean']} days
- Streak Consistency: ${((streakStats['consistency'] ?? 0.0) * 100).round()}%
- Age: ${user['age'] ?? 'Not specified'}
- Known Triggers: ${(user['triggers'] as List?)?.join(', ') ?? 'None identified'}
- Coping Strategies: ${(user['copingStrategies'] as List?)?.join(', ') ?? 'None specified'}

CURRENT CONTEXT:
- Time: ${currentTime['timeOfDay']} (${currentTime['hour']}:00)
- Day: ${_getDayName(currentTime['dayOfWeek'] ?? 1)}
- Weekend Risk: ${currentTime['isWeekend'] == true ? 'Yes' : 'No'}
- High-Risk Hours: ${currentTime['isHighRiskHour'] == true ? 'Yes' : 'No'}

RECENT ACTIVITY:
- Check-ins (14 days): ${recentCheckIns.length}/14 possible
- Check-in Frequency: ${((activityStats['checkInFrequency'] ?? 0.0) * 100).round()}%
- Hours Since Active: ${activityStats['lastActiveHours']}
- Recent Streaks: ${recentStreaks.length} tracked

HABIT COMPLETION DATA:
- Total Habits: ${habitStats['totalHabits']} assigned
- Completed Habits: ${habitStats['completedHabits']} finished
- Completion Rate: ${((habitStats['completionRate'] ?? 0.0) * 100).round()}%
- Habit Streak: ${habitStats['habitStreak']} consecutive days
- Active Categories: ${(habitStats['categoryStats'] as Map?)?.keys.join(', ') ?? 'None'}
- Recent Completions: ${(habitStats['recentCompletions'] as List?)?.join(', ') ?? 'None'}

RISK ASSESSMENT REQUEST:
Analyze this recovery data including habit completion patterns and provide a JSON risk assessment focusing on immediate temptation probability and actionable recommendations. Consider how habit completion affects recovery stability.''';
  }

  AIPredictionModel _parseAIResponse(String aiResponse) {
    try {
      // Clean the response and extract JSON
      String cleanResponse = aiResponse.trim();

      // Find JSON boundaries
      int jsonStart = cleanResponse.indexOf('{');
      int jsonEnd = cleanResponse.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('No valid JSON found in AI response');
      }

      final jsonString = cleanResponse.substring(jsonStart, jsonEnd);
      final data = jsonDecode(jsonString);

      // Validate required fields
      if (!data.containsKey('temptationProbability') ||
          !data.containsKey('reasoning') ||
          !data.containsKey('recommendations')) {
        throw Exception('Missing required fields in AI response');
      }

      return AIPredictionModel(
        temptationProbability:
            (data['temptationProbability'] as num).toDouble().clamp(0.0, 1.0),
        reasoning: data['reasoning']?.toString() ?? 'Analysis completed',
        recommendations: List<String>.from(data['recommendations'] ?? [])
            .where((r) => r.isNotEmpty)
            .take(5)
            .toList(),
        timestamp: DateTime.now(),
        riskLevel: _validateRiskLevel(data['riskLevel']?.toString()),
        factors: Map<String, dynamic>.from(data['factors'] ?? {}),
      );
    } catch (e) {
      print('Error parsing AI response: $e');
      print('Raw response: $aiResponse');

      // Return intelligent fallback based on response content
      return _createFallbackFromResponse(aiResponse);
    }
  }

  String _validateRiskLevel(String? riskLevel) {
    const validLevels = ['low', 'medium', 'high', 'critical'];
    final level = riskLevel?.toLowerCase() ?? 'medium';
    return validLevels.contains(level) ? level : 'medium';
  }

  AIPredictionModel _createFallbackFromResponse(String response) {
    // Try to extract some meaning from partial response
    final lowerResponse = response.toLowerCase();

    double probability = 0.5;
    String riskLevel = 'medium';

    if (lowerResponse.contains('high risk') ||
        lowerResponse.contains('dangerous')) {
      probability = 0.75;
      riskLevel = 'high';
    } else if (lowerResponse.contains('low risk') ||
        lowerResponse.contains('safe')) {
      probability = 0.25;
      riskLevel = 'low';
    }

    return AIPredictionModel(
      temptationProbability: probability,
      reasoning:
          'Analysis partially completed. Stay vigilant and use your coping strategies.',
      recommendations: [
        'Take deep breaths and center yourself',
        'Engage in a healthy distraction activity',
        'Reach out to your support network',
        'Review your recovery goals'
      ],
      timestamp: DateTime.now(),
      riskLevel: riskLevel,
      factors: {'analysis': 'partial'},
    );
  }

  AIPredictionModel _generateFallbackPrediction(Map<String, dynamic> userData) {
    final streakStats = userData['streakStats'] ?? {};
    final currentTime = userData['currentTime'] ?? {};
    final activityStats = userData['activityStats'] ?? {};
    final habitStats = userData['habitStats'] ?? {};

    final currentStreak = streakStats['currentStreak'] ?? 0;
    final hour = currentTime['hour'] ?? 12;
    final isWeekend = currentTime['isWeekend'] ?? false;
    final isHighRiskHour = currentTime['isHighRiskHour'] ?? false;
    final checkInFrequency = activityStats['checkInFrequency'] ?? 0.0;
    final lastActiveHours = activityStats['lastActiveHours'] ?? 0;
    final habitCompletionRate = habitStats['completionRate'] ?? 0.0;
    final habitStreak = habitStats['habitStreak'] ?? 0;

    // Advanced rule-based calculation
    double probability = 0.4; // Base probability
    List<String> riskFactors = [];
    List<String> protectiveFactors = [];

    // Streak length impact (strongest factor)
    if (currentStreak >= 90) {
      probability -= 0.25;
      protectiveFactors.add('Strong 90+ day streak momentum');
    } else if (currentStreak >= 30) {
      probability -= 0.15;
      protectiveFactors.add('Solid 30+ day foundation');
    } else if (currentStreak >= 7) {
      probability -= 0.05;
      protectiveFactors.add('Building weekly consistency');
    } else if (currentStreak <= 3) {
      probability += 0.2;
      riskFactors.add('Early recovery vulnerability');
    }

    // Time-based risk factors
    if (isHighRiskHour) {
      probability += 0.15;
      riskFactors.add('High-risk evening/night hours');
    }

    if (isWeekend) {
      probability += 0.1;
      riskFactors.add('Weekend isolation risk');
    }

    // Activity and engagement
    if (checkInFrequency < 0.3) {
      probability += 0.15;
      riskFactors.add('Low engagement with recovery tools');
    } else if (checkInFrequency > 0.7) {
      probability -= 0.1;
      protectiveFactors.add('Consistent daily check-ins');
    }

    if (lastActiveHours > 48) {
      probability += 0.1;
      riskFactors.add('Extended period without app engagement');
    }

    // Habit completion impact (significant factor)
    if (habitCompletionRate < 0.3) {
      probability += 0.2;
      riskFactors.add('Low habit completion rate');
    } else if (habitCompletionRate > 0.7) {
      probability -= 0.15;
      protectiveFactors.add('Strong habit completion consistency');
    }

    if (habitStreak >= 7) {
      probability -= 0.1;
      protectiveFactors.add('Consistent daily habit completion');
    } else if (habitStreak == 0) {
      probability += 0.1;
      riskFactors.add('No recent habit completion streak');
    }

    // Clamp probability
    probability = probability.clamp(0.0, 1.0);

    // Determine risk level
    String riskLevel = 'low';
    if (probability >= 0.7) {
      riskLevel = 'high';
    } else if (probability >= 0.4) {
      riskLevel = 'medium';
    }

    // Generate contextual recommendations
    List<String> recommendations = _generateContextualRecommendations(
        currentStreak, hour, isWeekend, riskLevel, riskFactors);

    // Create reasoning
    String reasoning = _generateReasoning(
        currentStreak, riskLevel, riskFactors, protectiveFactors);

    return AIPredictionModel(
      temptationProbability: probability,
      reasoning: reasoning,
      recommendations: recommendations,
      timestamp: DateTime.now(),
      riskLevel: riskLevel,
      factors: {
        'streakMomentum': currentStreak > 7 ? 'positive' : 'building',
        'timeContext': isHighRiskHour ? 'risky' : 'safe',
        'engagement': checkInFrequency > 0.5 ? 'active' : 'low',
        'riskFactors': riskFactors.length,
        'protectiveFactors': protectiveFactors.length,
      },
    );
  }

  List<String> _generateContextualRecommendations(int streak, int hour,
      bool isWeekend, String riskLevel, List<String> riskFactors) {
    List<String> recommendations = [];

    // Time-specific recommendations
    if (hour >= 21 || hour <= 6) {
      recommendations.addAll([
        'Consider going to bed early tonight',
        'Put your phone in another room',
        'Practice a calming bedtime routine',
      ]);
    } else if (hour >= 18) {
      recommendations.addAll([
        'Take a 15-minute evening walk',
        'Call a friend or family member',
        'Prepare a healthy dinner',
      ]);
    } else {
      recommendations.addAll([
        'Engage in a productive activity',
        'Step outside for fresh air',
        'Focus on your daily goals',
      ]);
    }

    // Risk-level specific
    if (riskLevel == 'high') {
      recommendations.insert(
          0, 'Immediately remove yourself from triggering environments');
      recommendations.insert(
          1, 'Contact your accountability partner right now');
    }

    // Streak-specific encouragement
    if (streak > 30) {
      recommendations.add('Remember your incredible ${streak}-day progress');
    } else if (streak > 0) {
      recommendations.add('Protect your current ${streak}-day streak');
    } else {
      recommendations.add('Today is a perfect day to start fresh');
    }

    return recommendations.take(4).toList();
  }

  String _generateReasoning(int streak, String riskLevel,
      List<String> riskFactors, List<String> protectiveFactors) {
    if (riskLevel == 'high') {
      return 'Multiple risk factors detected including ${riskFactors.isNotEmpty ? riskFactors.first.toLowerCase() : 'current timing'}. Your ${streak}-day streak is valuable - take immediate protective action.';
    } else if (riskLevel == 'medium') {
      return 'Your ${streak}-day streak shows progress, but ${riskFactors.isNotEmpty ? riskFactors.first.toLowerCase() : 'current conditions'} require extra vigilance. Stay focused on your coping strategies.';
    } else {
      return 'Your ${streak}-day streak and ${protectiveFactors.isNotEmpty ? protectiveFactors.first.toLowerCase() : 'current stability'} indicate good momentum. Continue your positive patterns.';
    }
  }

  Future<AIPredictionModel?> _getCachedPrediction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);

      if (cachedData != null && cachedData.isNotEmpty) {
        final data = jsonDecode(cachedData);
        return AIPredictionModel.fromJson(data);
      }
    } catch (e) {
      print('Error getting cached prediction: $e');
    }
    return null;
  }

  Future<bool> _isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateString = prefs.getString(_lastUpdateKey);

      if (lastUpdateString != null && lastUpdateString.isNotEmpty) {
        final lastUpdate = DateTime.parse(lastUpdateString);
        final now = DateTime.now();
        return now.difference(lastUpdate) < ApiConfig.predictionCacheDuration;
      }
    } catch (e) {
      print('Error checking cache validity: $e');
    }
    return false;
  }

  Future<void> _cachePrediction(AIPredictionModel prediction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(prediction.toJson()));
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching prediction: $e');
    }
  }

  String _getTimeOfDay(int hour) {
    if (hour < 6) return 'Late Night';
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    if (hour < 22) return 'Evening';
    return 'Night';
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    if (weekday >= 1 && weekday <= 7) {
      return days[weekday - 1];
    }
    return 'Unknown';
  }

  // Force refresh prediction (bypass cache)
  Future<AIPredictionModel?> forceRefresh(String userId) async {
    print('🔄 AI Prediction Service: forceRefresh called for user: $userId');
    try {
      final prediction = await _fetchFreshPrediction(userId);
      if (prediction != null) {
        print(
            '🔄 AI Prediction Service: Fresh prediction obtained, caching...');
        await _cachePrediction(prediction);
        print('🔄 AI Prediction Service: Prediction cached successfully');
      } else {
        print(
            '🔄 AI Prediction Service: No prediction obtained from force refresh');
      }
      return prediction;
    } catch (e) {
      print('🔄 AI Prediction Service: Error force refreshing prediction: $e');
      return null;
    }
  }

  // Clear cache (for testing or reset)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUpdateKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
