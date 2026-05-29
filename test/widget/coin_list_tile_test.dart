import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_folio/features/home/domain/models/coin_market_model.dart';
import 'package:crypto_folio/features/home/presentation/widgets/coin_list_tile.dart';

void main() {
  const testCoin = CoinMarketModel(
    id: 'bitcoin',
    symbol: 'btc',
    name: 'Bitcoin',
    image: '',        // empty → CachedNetworkImage shows errorWidget immediately
    currentPrice: 65000.0,
    marketCap: 1200000000000.0,
    marketCapRank: 1,
    priceChangePercentage24h: 2.5,
    totalVolume: 30000000000.0,
    ath: 73000.0,
  );

  testWidgets('CoinListTile renders coin name, symbol, price, and change',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CoinListTile(coin: testCoin, currency: 'usd'),
        ),
      ),
    );
    await tester.pump(); // process first frame

    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('BTC'), findsOneWidget);
    expect(find.textContaining('65,000'), findsOneWidget);
    expect(find.text('+2.50%'), findsOneWidget);
  });
}
