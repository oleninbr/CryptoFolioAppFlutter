class AppConstants {
  AppConstants._();

  static const String appName    = 'CryptoFolio';
  static const String appVersion = '1.0.0';

  static const int      defaultCoinsPerPage = 50;
  static const Duration cacheExpiry         = Duration(minutes: 5);

  /// BCP-47 language tags for supported locales (order = priority)
  static const List<String> supportedLocales = ['en', 'uk', 'pl'];

  // ── SharedPreferences keys ───────────────────────────────────
  static const String themeKey    = 'app_theme';
  static const String languageKey = 'app_language';
  static const String currencyKey = 'app_currency';
}
