/// Application configuration for Devyse POS.
class AppConfig {
  static const String appName = 'DevysePOS';

  static const String appVersion = '1.0.0';

  /// Password required in Settings → Wipe Local Database (first dialog).
  static const String wipeDatabasePassword = 'devyse_wipe_confirm';

  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static const bool enableDebugFeatures = !isProduction;
}
