import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_folio/features/portfolio/domain/models/portfolio_item_model.dart';

PortfolioItemModel _makeItem({
  required double quantity,
  required double buyPrice,
}) {
  return PortfolioItemModel(
    id: 'test',
    coinId: 'test',
    coinName: 'Test Coin',
    coinSymbol: 'tst',
    coinImage: '',
    quantity: quantity,
    buyPrice: buyPrice,
    addedAt: DateTime(2024, 1, 1),
  );
}

void main() {
  group('PortfolioItemModel calculations', () {
    test('totalInvested returns quantity multiplied by buyPrice', () {
      final item = _makeItem(quantity: 2.5, buyPrice: 40000);
      expect(item.totalInvested, equals(100000.0));
    });

    test('profitLoss is positive when current price exceeds buy price', () {
      final item = _makeItem(quantity: 1.0, buyPrice: 30000);
      expect(item.profitLoss(40000), equals(10000.0));
    });

    test('profitLossPercent is ~33.33% when price rises from 30000 to 40000', () {
      final item = _makeItem(quantity: 1.0, buyPrice: 30000);
      expect(item.profitLossPercent(40000), closeTo(33.33, 0.01));
    });
  });
}
