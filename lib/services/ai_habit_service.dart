import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_habit_model.dart';
import '../core/config/api_config.dart';

class AIHabitService {
  static const String _habitCacheKey = 'ai_habits_cache';
  static const String _habitLastUpdateKey = 'ai_habits_last_update';
  static const String _habitStatsKey = 'habit_completion_stats';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AIHabitModel>> getDailyHabits(String userId) async {
    print('🎯 AI Habit Service: getDailyHabits called for user: $userId');

    try {
      // Check if we have cached habits that are still valid
      final cachedHabits = await _getCachedHabits();
      final isCacheValid = await _isHabitCacheValid();

      if (cachedHabits.isNotEmpty && isCacheValid) {
        print(
            '🎯 AI Habit Service: Returning ${cachedHabits.length} cached habits');
        return cachedHabits;
      }

      print('🎯 AI Habit Service: Generating fresh habits...');
      // Generate fresh habits from AI
      final habits = await _generateFreshHabits(userId);
      if (habits.isNotEmpty) {
        await _cacheHabits(habits);
        await _saveHabitsToFirestore(habits);
      }

      return habits;
    } catch (e) {
      print('🎯 AI Habit Service: Error getting daily habits: $e');
      // Return cached habits even if expired as fallback
      return await _getCachedHabits();
    }
  }

  Future<List<AIHabitModel>> _generateFreshHabits(String userId) async {
    print('🎯 AI Habit Service: _generateFreshHabits started');

    try {
      // Gather user data for context
      final userData = await _gatherUserContextData(userId);
      print('🎯 AI Habit Service: User context gathered');

      // Create AI prompt for habit generation
      final prompt = _createHabitPrompt(userData);
      print('🎯 AI Habit Service: Habit prompt created, making API call...');

      // Try models in order with model-specific timeouts. If one fails due to
      // service unavailability or model_not_available, try the next.
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

      for (int i = 0; i < models.length; i++) {
        final model = models[i];
        final timeout = timeouts[i];
        print('🎯 AI Habit Service: Attempting model "$model" with timeout ${timeout.inSeconds}s');

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
                      'content': _getHabitSystemPrompt(),
                    },
                    {
                      'role': 'user',
                      'content': prompt,
                    }
                  ],
                  'max_tokens': 1000,
                  'temperature': 0.3,
                  'top_p': 0.8,
                }),
              )
              .timeout(timeout);

          print('🎯 AI Habit Service: API response status: ${response.statusCode} (model: $model)');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final aiResponse = data['choices']?[0]?['message']?['content'];

            if (aiResponse != null) {
              print('🎯 AI Habit Service: AI response received, parsing habits...');
              final habits = _parseHabitsResponse(aiResponse, userId);
              print('🎯 AI Habit Service: Parsed ${habits.length} habits from AI');
              return habits;
            }
          } else {
            try {
              final parsed = jsonDecode(response.body);
              final errorCode = parsed['error']?['code'];
              final errorMessage = parsed['error']?['message'];
              print('🎯 AI Habit Service: API Error: ${response.statusCode} - $errorMessage (code: $errorCode)');

              if (response.statusCode == 503 || errorCode == 'model_not_available' || parsed['error'] != null) {
                print('🎯 AI Habit Service: Service/model unavailable for "$model", trying next model');
                continue;
              }
            } catch (_) {
              print('🎯 AI Habit Service: API Error: ${response.statusCode} - ${response.body}');
            }
          }
        } catch (e) {
          print('🎯 AI Habit Service: Error calling model $model - $e');
          continue;
        }
      }

      // Fallback to default habits
      print('🎯 AI Habit Service: Using fallback habits');
      return _generateFallbackHabits(userId, userData);
    } catch (e) {
      print('🎯 AI Habit Service: Error generating fresh habits: $e');
      final userData = await _gatherUserContextData(userId);
      return _generateFallbackHabits(userId, userData);
    }
  }

  String _getHabitSystemPrompt() {
    return '''You are an expert addiction recovery coach specializing in pornography addiction recovery. Your role is to generate personalized daily habits that support recovery and build resilience.

HABIT GENERATION FRAMEWORK:
- Focus on evidence-based recovery practices
- Consider user's current streak, risk factors, and patterns
- Prioritize habits that address triggers and build healthy coping mechanisms
- Include physical, mental, emotional, and spiritual wellness
- Make habits specific, measurable, and achievable

RESPONSE FORMAT (JSON only):
{
  "habits": [
    {
      "title": "Morning Cold Shower",
      "description": "Take a 2-minute cold shower to build mental resilience and reduce urges",
      "category": "Physical Wellness",
      "priority": 4,
      "estimatedMinutes": 5,
      "aiReasoning": "Cold exposure builds discipline and reduces dopamine sensitivity, helping with urge management",
      "tags": ["discipline", "physical", "morning"]
    }
  ]
}

CATEGORIES:
- Physical Wellness (exercise, nutrition, sleep)
- Mental Health (meditation, journaling, therapy)
- Social Connection (relationships, community, support)
- Productivity (work, learning, skills)
- Spiritual Growth (values, purpose, meaning)
- Recovery Tools (accountability, tracking, education)

GUIDELINES:
- Generate 3-5 habits per day
- Vary difficulty and time commitment
- Include at least one high-priority habit (4-5)
- Keep descriptions actionable and specific
- Provide clear reasoning for each habit
- Consider time of day and user's schedule''';
  }

  Future<Map<String, dynamic>> _gatherUserContextData(String userId) async {
    try {
      // Get user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.exists ? userDoc.data() ?? {} : {};

      // Get current streak info
      final streaksQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('streaks')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      final currentStreak =
          streaksQuery.docs.isNotEmpty ? streaksQuery.docs.first.data() : {};

      // Get recent habit completion stats
      final habitStats = await _getHabitCompletionStats(userId);

      // Get recent journal entries for mood/context
      final journalQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal_entries')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      final recentJournals =
          journalQuery.docs.map((doc) => doc.data()).toList();

      final now = DateTime.now();

      return {
        'user': userData,
        'currentStreak': currentStreak,
        'habitStats': habitStats.toJson(),
        'recentJournals': recentJournals,
        'currentTime': {
          'hour': now.hour,
          'dayOfWeek': now.weekday,
          'isWeekend': now.weekday >= 6,
          'timeOfDay': _getTimeOfDay(now.hour),
        },
        'streakDays': currentStreak['daysCount'] ?? 0,
      };
    } catch (e) {
      print('🎯 AI Habit Service: Error gathering context data: $e');
      return _getDefaultContextData();
    }
  }

  String _createHabitPrompt(Map<String, dynamic> userData) {
    final user = userData['user'] ?? {};
  // currentStreak available via userData['currentStreak'] when needed
    final habitStats = userData['habitStats'] ?? {};
    final currentTime = userData['currentTime'] ?? {};
    final streakDays = userData['streakDays'] ?? 0;

    return '''DAILY HABIT GENERATION REQUEST

USER PROFILE:
- Current Streak: $streakDays days porn-free
- Age: ${user['age'] ?? 'Not specified'}
- Recovery Stage: ${_getRecoveryStage(streakDays)}
- Known Triggers: ${(user['triggers'] as List?)?.join(', ') ?? 'None identified'}
- Coping Strategies: ${(user['copingStrategies'] as List?)?.join(', ') ?? 'None specified'}

HABIT COMPLETION HISTORY:
- Total Habits Completed: ${habitStats['completedHabits'] ?? 0}
- Completion Rate: ${((habitStats['completionRate'] ?? 0.0) * 100).round()}%
- Habit Streak: ${habitStats['streakDays'] ?? 0} days
- Preferred Categories: ${(habitStats['categoryStats'] as Map?)?.keys.join(', ') ?? 'None'}

CURRENT CONTEXT:
- Time: ${currentTime['timeOfDay']} (${currentTime['hour']}:00)
- Day: ${_getDayName(currentTime['dayOfWeek'] ?? 1)}
- Weekend: ${currentTime['isWeekend'] == true ? 'Yes' : 'No'}

HABIT REQUEST:
Generate 3-5 personalized recovery habits for today. Focus on the user's current recovery stage and recent patterns. Include a mix of difficulty levels and time commitments.''';
  }

  List<AIHabitModel> _parseHabitsResponse(String aiResponse, String userId) {
    try {
      // Clean the response and extract JSON
      String cleanResponse = aiResponse.trim();
      int jsonStart = cleanResponse.indexOf('{');
      int jsonEnd = cleanResponse.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('No valid JSON found in AI response');
      }

      final jsonString = cleanResponse.substring(jsonStart, jsonEnd);
      final data = jsonDecode(jsonString);

      if (!data.containsKey('habits') || data['habits'] is! List) {
        throw Exception('Invalid habits format in AI response');
      }

      final habitsList = data['habits'] as List;
      final habits = <AIHabitModel>[];

      for (final habitData in habitsList) {
        if (habitData is Map<String, dynamic>) {
          final habit = AIHabitModel(
            id: '',
            userId: userId,
            title: habitData['title']?.toString() ?? 'Daily Habit',
            description:
                habitData['description']?.toString() ?? 'Complete this habit',
            category: habitData['category']?.toString() ?? 'General',
            priority: (habitData['priority'] as num?)?.toInt() ?? 3,
            estimatedMinutes:
                (habitData['estimatedMinutes'] as num?)?.toInt() ?? 10,
            isCompleted: false,
            createdAt: DateTime.now(),
            aiReasoning: habitData['aiReasoning']?.toString() ??
                'AI-generated habit for recovery',
            tags: List<String>.from(habitData['tags'] ?? []),
            metadata: {'source': 'ai_generated', 'version': '1.0'},
          );
          habits.add(habit);
        }
      }

      return habits;
    } catch (e) {
      print('🎯 AI Habit Service: Error parsing habits response: $e');
      return _generateFallbackHabits(userId, {});
    }
  }

  List<AIHabitModel> _generateFallbackHabits(
      String userId, Map<String, dynamic> userData) {
    final streakDays = userData['streakDays'] ?? 0;
    final now = DateTime.now();

    final fallbackHabits = <AIHabitModel>[
      AIHabitModel(
        id: '',
        userId: userId,
        title: 'Morning Mindfulness',
        description: 'Spend 5 minutes in quiet reflection or meditation',
        category: 'Mental Health',
        priority: 4,
        estimatedMinutes: 5,
        isCompleted: false,
        createdAt: now,
        aiReasoning:
            'Mindfulness helps build awareness and emotional regulation, key for recovery',
        tags: ['mindfulness', 'morning', 'mental-health'],
        metadata: {
          'source': 'fallback',
          'recovery_stage': _getRecoveryStage(streakDays)
        },
      ),
      AIHabitModel(
        id: '',
        userId: userId,
        title: 'Physical Exercise',
        description:
            'Do 15 minutes of physical activity (walk, pushups, stretching)',
        category: 'Physical Wellness',
        priority: 3,
        estimatedMinutes: 15,
        isCompleted: false,
        createdAt: now,
        aiReasoning:
            'Exercise releases natural endorphins and reduces stress, supporting recovery',
        tags: ['exercise', 'physical', 'endorphins'],
        metadata: {
          'source': 'fallback',
          'recovery_stage': _getRecoveryStage(streakDays)
        },
      ),
      AIHabitModel(
        id: '',
        userId: userId,
        title: 'Gratitude Practice',
        description: 'Write down 3 things you\'re grateful for today',
        category: 'Mental Health',
        priority: 2,
        estimatedMinutes: 3,
        isCompleted: false,
        createdAt: now,
        aiReasoning:
            'Gratitude shifts focus to positive aspects of life and builds resilience',
        tags: ['gratitude', 'journaling', 'positivity'],
        metadata: {
          'source': 'fallback',
          'recovery_stage': _getRecoveryStage(streakDays)
        },
      ),
    ];

    // Add recovery-stage specific habits
    if (streakDays < 7) {
      fallbackHabits.add(AIHabitModel(
        id: '',
        userId: userId,
        title: 'Trigger Awareness',
        description:
            'Identify and write down one potential trigger you might face today',
        category: 'Recovery Tools',
        priority: 5,
        estimatedMinutes: 5,
        isCompleted: false,
        createdAt: now,
        aiReasoning:
            'Early recovery requires strong trigger awareness and preparation',
        tags: ['triggers', 'awareness', 'early-recovery'],
        metadata: {'source': 'fallback', 'recovery_stage': 'early'},
      ));
    } else if (streakDays >= 30) {
      fallbackHabits.add(AIHabitModel(
        id: '',
        userId: userId,
        title: 'Help Someone Else',
        description:
            'Reach out to support someone else in their recovery journey',
        category: 'Social Connection',
        priority: 3,
        estimatedMinutes: 10,
        isCompleted: false,
        createdAt: now,
        aiReasoning:
            'Helping others strengthens your own recovery and builds community',
        tags: ['service', 'community', 'support'],
        metadata: {'source': 'fallback', 'recovery_stage': 'established'},
      ));
    }

    return fallbackHabits;
  }

  Future<bool> completeHabit(String userId, String habitId) async {
    print('🎯 AI Habit Service: Completing habit $habitId for user $userId');

    try {
      // Update habit in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_habits')
          .doc(habitId)
          .update({
        'isCompleted': true,
        'completedAt': Timestamp.now(),
      });

      // Update local cache
      final cachedHabits = await _getCachedHabits();
      final updatedHabits = cachedHabits.map((habit) {
        if (habit.id == habitId) {
          return habit.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }
        return habit;
      }).toList();

      await _cacheHabits(updatedHabits);

      // Update completion stats
      await _updateHabitStats(userId);

      print('🎯 AI Habit Service: Habit completed successfully');
      return true;
    } catch (e) {
      print('🎯 AI Habit Service: Error completing habit: $e');
      return false;
    }
  }

  Future<HabitCompletionStats> _getHabitCompletionStats(String userId) async {
    try {
      // Get habits from last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final habitsQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_habits')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final habits = habitsQuery.docs
          .map((doc) => AIHabitModel.fromJson(doc.data(), doc.id))
          .toList();

      final totalHabits = habits.length;
      final completedHabits = habits.where((h) => h.isCompleted).length;
      final completionRate =
          totalHabits > 0 ? completedHabits / totalHabits : 0.0;

      // Calculate category stats
      final categoryStats = <String, int>{};
      for (final habit in habits.where((h) => h.isCompleted)) {
        categoryStats[habit.category] =
            (categoryStats[habit.category] ?? 0) + 1;
      }

      // Calculate streak days (consecutive days with at least one completed habit)
      int streakDays = 0;
      final today = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final checkDate = today.subtract(Duration(days: i));
        final dayHabits = habits
            .where((h) =>
                h.completedAt != null && _isSameDay(h.completedAt!, checkDate))
            .toList();

        if (dayHabits.isNotEmpty) {
          streakDays++;
        } else {
          break;
        }
      }

      return HabitCompletionStats(
        totalHabits: totalHabits,
        completedHabits: completedHabits,
        streakDays: streakDays,
        completionRate: completionRate,
        categoryStats: categoryStats,
        recentCompletions: habits
            .where((h) => h.isCompleted)
            .take(5)
            .map((h) => h.title)
            .toList(),
      );
    } catch (e) {
      print('🎯 AI Habit Service: Error getting habit stats: $e');
      return HabitCompletionStats(
        totalHabits: 0,
        completedHabits: 0,
        streakDays: 0,
        completionRate: 0.0,
        categoryStats: {},
        recentCompletions: [],
      );
    }
  }

  Future<void> _updateHabitStats(String userId) async {
    try {
      final stats = await _getHabitCompletionStats(userId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_habitStatsKey, jsonEncode(stats.toJson()));
    } catch (e) {
      print('🎯 AI Habit Service: Error updating habit stats: $e');
    }
  }

  Future<void> _saveHabitsToFirestore(List<AIHabitModel> habits) async {
    try {
      final batch = _firestore.batch();

      for (final habit in habits) {
        final docRef = _firestore
            .collection('users')
            .doc(habit.userId)
            .collection('daily_habits')
            .doc();

        batch.set(docRef, habit.copyWith(id: docRef.id).toJson());
      }

      await batch.commit();
      print('🎯 AI Habit Service: Saved ${habits.length} habits to Firestore');
    } catch (e) {
      print('🎯 AI Habit Service: Error saving habits to Firestore: $e');
    }
  }

  Future<List<AIHabitModel>> _getCachedHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_habitCacheKey);

      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> habitsList = jsonDecode(cachedData);
        return habitsList
            .map((data) => AIHabitModel.fromJson(data, data['id'] ?? ''))
            .toList();
      }
    } catch (e) {
      print('🎯 AI Habit Service: Error getting cached habits: $e');
    }
    return [];
  }

  Future<bool> _isHabitCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateString = prefs.getString(_habitLastUpdateKey);

      if (lastUpdateString != null && lastUpdateString.isNotEmpty) {
        final lastUpdate = DateTime.parse(lastUpdateString);
        final now = DateTime.now();

        // Check if it's a new day (after 6 AM)
        final todayMorning = DateTime(now.year, now.month, now.day, 6);
        final lastUpdateMorning =
            DateTime(lastUpdate.year, lastUpdate.month, lastUpdate.day, 6);

        return now.isBefore(todayMorning) ||
            lastUpdate.isAfter(lastUpdateMorning);
      }
    } catch (e) {
      print('🎯 AI Habit Service: Error checking cache validity: $e');
    }
    return false;
  }

  Future<void> _cacheHabits(List<AIHabitModel> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = habits.map((h) => h.toJson()).toList();
      await prefs.setString(_habitCacheKey, jsonEncode(habitsJson));
      await prefs.setString(
          _habitLastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('🎯 AI Habit Service: Error caching habits: $e');
    }
  }

  // Helper methods
  String _getRecoveryStage(int streakDays) {
    if (streakDays < 7) return 'Early Recovery';
    if (streakDays < 30) return 'Building Momentum';
    if (streakDays < 90) return 'Establishing Habits';
    return 'Long-term Recovery';
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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Map<String, dynamic> _getDefaultContextData() {
    final now = DateTime.now();
    return {
      'user': {},
      'currentStreak': {},
      'habitStats': HabitCompletionStats(
        totalHabits: 0,
        completedHabits: 0,
        streakDays: 0,
        completionRate: 0.0,
        categoryStats: {},
        recentCompletions: [],
      ).toJson(),
      'recentJournals': [],
      'currentTime': {
        'hour': now.hour,
        'dayOfWeek': now.weekday,
        'isWeekend': now.weekday >= 6,
        'timeOfDay': _getTimeOfDay(now.hour),
      },
      'streakDays': 0,
    };
  }

  // Public method to get habit completion stats for AI risk analysis
  Future<HabitCompletionStats> getHabitStatsForAI(String userId) async {
    return await _getHabitCompletionStats(userId);
  }
}
