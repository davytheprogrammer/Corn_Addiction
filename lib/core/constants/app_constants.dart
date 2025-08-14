class AppConstants {
  // General
  static const String appVersion = '1.0.0';
  static const int splashDurationInSeconds = 2;
  static const String defaultLanguage = 'en';
  
  // Auth
  static const int minPasswordLength = 8;
  static const int otpTimeoutSeconds = 60;
  static const int maxLoginAttempts = 5;
  static const int passwordResetTimeoutHours = 24;
  
  // API endpoints
  static const String baseUrl = 'https://api.cornaddiction.com';
  static const String termsUrl = 'https://cornaddiction.com/terms';
  static const String privacyUrl = 'https://cornaddiction.com/privacy';
  static const String helpUrl = 'https://cornaddiction.com/help';
  
  // Shared preferences keys
  static const String prefUserKey = 'user';
  static const String prefTokenKey = 'token';
  static const String prefOnboardingKey = 'onboarding_complete';
  static const String prefThemeModeKey = 'theme_mode';
  static const String prefCurrentStreak = 'current_streak';
  static const String prefLastCheckIn = 'last_check_in';
  static const String prefLanguageKey = 'language';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  
  // Firestore collections
  static const String usersCollection = 'users';
  static const String streaksCollection = 'streaks';
  static const String urgeLogsCollection = 'urge_logs';
  static const String journalEntriesCollection = 'journal_entries';
  static const String checkInsCollection = 'check_ins';
  static const String resourcesCollection = 'resources';
  
  // Default app settings
  static const bool defaultNotificationsEnabled = true;
  static const String defaultThemeMode = 'system';
  static const int defaultDailyGoalHours = 0;
  
  // Duration constants
  static const int dayInSeconds = 86400;
  static const int hourInSeconds = 3600;
  static const int minuteInSeconds = 60;
  
  // Achievement thresholds
  static const int bronzeStreakDays = 7;
  static const int silverStreakDays = 30;
  static const int goldStreakDays = 90;
  static const int platinumStreakDays = 180;
  static const int diamondStreakDays = 365;
  
  // Meditation session durations
  static const List<int> meditationDurations = [1, 3, 5, 10, 15, 20];
  
  // Recovery tools categories
  static const List<String> toolsCategories = [
    'Breathing',
    'Meditation',
    'Education',
    'Journaling',
    'Emergency',
    'Community',
    'Activities'
  ];
  
  // Emergency resources
  static const String emergencyHelplineNumber = '+1-800-123-4567';
  static const String emergencyTextLine = '55555';
  
  // AI chat limits
  static const int maxChatMessagesPerDay = 10;
  static const int maxChatLength = 500;
  
  // Notification IDs
  static const int dailyCheckInNotificationId = 1001;
  static const int urgeAlertNotificationId = 1002;
  static const int streakMilestoneNotificationId = 1003;
  static const int motivationNotificationId = 1004;
}
