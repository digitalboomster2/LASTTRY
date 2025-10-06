class AppConfig {
  // App Information
  static const String appName = 'Savvy Bee';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your money, your mind, working together.';
  
  // API Configuration
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String openaiModel = 'gpt-4';
  
  // Feature Flags
  static const bool enableAIInsights = true;
  static const bool enableDocumentProcessing = true;
  static const bool enableNotifications = true;
  static const bool enableDarkMode = true;
  
  // Performance Settings
  static const int maxTransactionsToLoad = 100;
  static const int maxJournalEntriesToLoad = 50;
  static const int maxGoalsToDisplay = 10;
  
  // Animation Durations
  static const Duration splashAnimationDuration = Duration(milliseconds: 2500);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration microInteractionDuration = Duration(milliseconds: 150);
  
  // Financial Thresholds
  static const double minSavingsRate = 0.1; // 10%
  static const double maxExpenseRatio = 0.8; // 80%
  static const double maxDebtRatio = 0.3; // 30%
  
  // AI Response Settings
  static const int maxAITokens = 500;
  static const double aiTemperature = 0.7;
  static const int maxInsightsToStore = 100;
  
  // Security Settings
  static const bool enableBiometricAuth = true;
  static const bool enableDataEncryption = true;
  static const int sessionTimeoutMinutes = 30;
  
  // Localization
  static const String defaultLocale = 'en_US';
  static const List<String> supportedLocales = ['en_US', 'ng_NG'];
  
  // Deep Link Schemes
  static const String deepLinkScheme = 'savvybee';
  static const String deepLinkHost = 'savvybee.app';
  
  // Analytics Events
  static const String analyticsEventAppOpen = 'app_open';
  static const String analyticsEventFeatureUsed = 'feature_used';
  static const String analyticsEventGoalCreated = 'goal_created';
  static const String analyticsEventDocumentUploaded = 'document_uploaded';
  static const String analyticsEventAIInsightGenerated = 'ai_insight_generated';
}
