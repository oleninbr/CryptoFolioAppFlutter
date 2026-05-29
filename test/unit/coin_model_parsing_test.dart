import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_folio/features/home/domain/models/coin_market_model.dart';

void main() {
  group('CoinMarketModel parsing', () {
    test('parses all standard fields correctly from JSON', () {
      final json = <String, dynamic>{
        'id': 'bitcoin',
        'symbol': 'btc',
        'name': 'Bitcoin',
        'image': 'https://example.com/btc.png',
        'current_price': 65000.0,
        'market_cap': 1200000000000.0,
        'price_change_percentage_24h': 2.5,
        'total_volume': 30000000000.0,
        'ath': 73000.0,
        'market_cap_rank': 1,
      };

      final coin = CoinMarketModel.fromJson(json);

      expect(coin.id, equals('bitcoin'));
      expect(coin.name, equals('Bitcoin'));
      expect(coin.symbol, equals('btc'));
      expect(coin.currentPrice, equals(65000.0));
      expect(coin.priceChangePercentage24h, equals(2.5));
      expect(coin.marketCapRank, equals(1));
    });

    test('handles null optional fields gracefully', () {
      final json = <String, dynamic>{
        'id': 'test',
        'symbol': 'tst',
        'name': 'Test',
        'image': '',
        'current_price': 1.0,
        'market_cap': 0.0,
        'price_change_percentage_24h': null,
        'total_volume': null,
        'ath': null,
        'market_cap_rank': 999,
      };

      final coin = CoinMarketModel.fromJson(json);

      expect(coin.priceChangePercentage24h, isNull);
      expect(coin.totalVolume, isNull);
      expect(coin.ath, isNull);
    });
  });
}
