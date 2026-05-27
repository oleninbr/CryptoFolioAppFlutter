class AppConstants {
  AppConstants._();

  static const String appName = 'CryptoFolio';
  static const int defaultCoinsPerPage = 50;
  static const Duration cacheExpiry = Duration(minutes: 5);
  static const List<String> supportedLocales = ['en', 'uk', 'pl'];
}
