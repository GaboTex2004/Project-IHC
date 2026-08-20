class AppConstants {
  static const String appName = 'Pet Track';
  static const String appVersion = '0.1.0';
  
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(minutes: 5);
}
