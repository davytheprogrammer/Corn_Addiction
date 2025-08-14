import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _prefsUserKey = 'user_data';
  static const String _prefsStreakKey = 'streak_data';
  static const String _prefsLastCheckInKey = 'last_checkin_date';
  static const String _prefsAppSettingsKey = 'app_settings';
  static const String _prefsOnboardingKey = 'onboarding_completed';
  static const String _prefsMotivationalQuotesKey = 'motivational_quotes';
  static const String _prefsNotificationSettingsKey = 'notification_settings';
  static const String _prefsDailyGoalsKey = 'daily_goals';
  static const String _prefsJournalEntriesKey = 'journal_entries';

  // Generic methods
  static Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      // For complex objects, convert to JSON string
      await prefs.setString(key, jsonEncode(value));
    }
  }

  static Future<dynamic> getData(String key, {dynamic defaultValue}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) return defaultValue;
    return prefs.get(key);
  }

  static Future<bool> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  static Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  // User data methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await saveData(_prefsUserKey, userData);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final data = await getData(_prefsUserKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<bool> clearUserData() async {
    return await removeData(_prefsUserKey);
  }

  // Streak methods
  static Future<void> saveStreakData(Map<String, dynamic> streakData) async {
    await saveData(_prefsStreakKey, streakData);
  }

  static Future<Map<String, dynamic>?> getStreakData() async {
    final data = await getData(_prefsStreakKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  // Last check-in date
  static Future<void> saveLastCheckInDate(DateTime date) async {
    await saveData(_prefsLastCheckInKey, date.toIso8601String());
  }

  static Future<DateTime?> getLastCheckInDate() async {
    final dateStr = await getData(_prefsLastCheckInKey);
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  // App settings
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await saveData(_prefsAppSettingsKey, settings);
  }

  static Future<Map<String, dynamic>> getAppSettings() async {
    final data = await getData(_prefsAppSettingsKey);
    if (data == null) return {};
    return jsonDecode(data);
  }

  // Onboarding status
  static Future<void> setOnboardingCompleted(bool completed) async {
    await saveData(_prefsOnboardingKey, completed);
  }

  static Future<bool> isOnboardingCompleted() async {
    return await getData(_prefsOnboardingKey, defaultValue: false);
  }

  // Motivational quotes
  static Future<void> saveMotivationalQuotes(List<String> quotes) async {
    await saveData(_prefsMotivationalQuotesKey, quotes);
  }

  static Future<List<String>> getMotivationalQuotes() async {
    final data = await getData(_prefsMotivationalQuotesKey);
    if (data == null) return [];
    
    if (data is List<String>) {
      return data;
    } else if (data is String) {
      final parsed = jsonDecode(data);
      return List<String>.from(parsed);
    }
    
    return [];
  }

  // Notification settings
  static Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    await saveData(_prefsNotificationSettingsKey, settings);
  }

  static Future<Map<String, dynamic>> getNotificationSettings() async {
    final data = await getData(_prefsNotificationSettingsKey);
    if (data == null) {
      // Default notification settings
      return {
        'dailyReminder': true,
        'reminderTime': '21:00',
        'weeklyReports': true,
        'urgeAlerts': true,
        'achievementNotifications': true,
      };
    }
    return jsonDecode(data);
  }

  // Daily goals
  static Future<void> saveDailyGoals(List<Map<String, dynamic>> goals) async {
    await saveData(_prefsDailyGoalsKey, goals);
  }

  static Future<List<Map<String, dynamic>>> getDailyGoals() async {
    final data = await getData(_prefsDailyGoalsKey);
    if (data == null) return [];
    
    final parsed = jsonDecode(data);
    return List<Map<String, dynamic>>.from(
      parsed.map((item) => Map<String, dynamic>.from(item))
    );
  }

  // Journal entries (stored locally for privacy)
  static Future<void> saveJournalEntry(Map<String, dynamic> entry) async {
    final entries = await getJournalEntries();
    entries.add(entry);
    await saveData(_prefsJournalEntriesKey, entries);
  }

  static Future<List<Map<String, dynamic>>> getJournalEntries() async {
    final data = await getData(_prefsJournalEntriesKey);
    if (data == null) return [];
    
    final parsed = jsonDecode(data);
    return List<Map<String, dynamic>>.from(
      parsed.map((item) => Map<String, dynamic>.from(item))
    );
  }

  static Future<void> deleteJournalEntry(String entryId) async {
    final entries = await getJournalEntries();
    entries.removeWhere((entry) => entry['id'] == entryId);
    await saveData(_prefsJournalEntriesKey, entries);
  }

  static Future<void> updateJournalEntry(String entryId, Map<String, dynamic> updatedEntry) async {
    final entries = await getJournalEntries();
    final index = entries.indexWhere((entry) => entry['id'] == entryId);
    if (index != -1) {
      entries[index] = updatedEntry;
      await saveData(_prefsJournalEntriesKey, entries);
    }
  }
}
