class ApiConstants {
  ApiConstants._();

  static const String baseUrl      = 'https://api.coingecko.com/api/v3';
  static const String coinsMarkets = '/coins/markets';
  static const String coinDetail   = '/coins';
  static const String marketChart  = '/market_chart';
  static const String search       = '/search';

  static const int    perPage      = 50;
  static const String vsCurrency   = 'usd';
}
