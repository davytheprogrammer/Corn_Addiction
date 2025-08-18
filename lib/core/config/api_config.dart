class ApiConfig {
  // Together AI API key
  static const String togetherApiKey =
      '4db152889da5afebdba262f90e4cdcf12976ee8b48d9135c2bb86ef9b0d12bdd';

  // API endpoints
  static const String togetherBaseUrl =
      'https://api.together.xyz/v1/chat/completions';

  // Production-ready model configurations
  // Model selection (ordered preference)
  static const String defaultModel =
      'meta-llama/Llama-3.3-70B-Instruct-Turbo-Free'; // Primary model
  static const String fallbackModel =
      'lgai/exaone-deep-32b'; // Secondary model
  static const String fastModel =
      'mistralai/Mistral-7B-Instruct-v0.2'; // Fast / low-latency model

  // Per-model timeouts (tight but reasonable)
  // These are used when targeting a specific model to keep latency bounded.
  static const Duration defaultModelTimeout =
      Duration(seconds: 20); // Llama-3.3-70B — large, allow a bit more time
  static const Duration fallbackModelTimeout =
      Duration(seconds: 15); // ExaOne 32B — medium-large
  static const Duration fastModelTimeout =
      Duration(seconds: 8); // Mistral 7B — fast responses

  // Cache and performance settings
  static const Duration predictionCacheDuration =
      Duration(hours: 6); // Cache predictions for 6 hours
  static const Duration habitCacheDuration =
      Duration(hours: 12); // Cache habits until next morning
  static const int maxRetries = 2; // Retry failed requests
    // General request timeout (fallback if a per-model timeout isn't applied)
    static const Duration requestTimeout = Duration(seconds: 20); // API timeout

  // Risk assessment thresholds (production calibrated)
  static const double criticalRiskThreshold = 0.85; // 85%+ = Critical
  static const double highRiskThreshold = 0.65; // 65%+ = High Risk
  static const double mediumRiskThreshold = 0.35; // 35%+ = Medium Risk
  static const double lowRiskThreshold = 0.0; // Below 35% = Low Risk

  // Feature toggles for production deployment
  static const bool enableAIPredictions = true; // Master switch for AI features
  static const bool enableFallbackPredictions =
      true; // Always use fallback if AI fails
  static const bool enablePredictionCaching = true; // Cache for performance
  static const bool enableDetailedLogging = false; // Set to false in production
  static const bool enableOfflineMode = true; // Work without internet

  // API rate limiting and cost control
  static const int maxDailyPredictions =
      100; // Limit API calls per user per day
  static const Duration minTimeBetweenCalls =
      Duration(minutes: 30); // Minimum time between API calls

  // Fallback prediction weights (fine-tuned for accuracy)
  static const double streakWeight = 0.4; // 40% weight on streak length
  static const double timeWeight = 0.25; // 25% weight on time factors
  static const double activityWeight = 0.2; // 20% weight on app engagement
  static const double contextWeight =
      0.15; // 15% weight on environmental factors

  // Production safety settings
  static const int maxRecommendations = 5; // Limit recommendation count
  static const int maxReasoningLength = 200; // Limit reasoning text length
  static const bool validateAllInputs = true; // Validate all user inputs
  static const bool sanitizeOutputs = true; // Clean all AI outputs
}
