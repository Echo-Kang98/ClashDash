class AppConstants {
  // Hive Box Names
  static const String subscriptionsBox = 'subscriptions';
  static const String nodesBox = 'nodes';
  static const String rulesBox = 'rules';
  static const String settingsBox = 'settings';
  
  // Settings Keys
  static const String selectedNodeKey = 'selected_node';
  static const String autoTestIntervalKey = 'auto_test_interval';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Default Values
  static const int defaultAutoTestInterval = 30; // minutes
  static const String testUrl = 'https://www.google.com/generate_204';
  static const int connectionTimeout = 5000; // ms
  static const int speedTestTimeout = 10000; // ms
}
