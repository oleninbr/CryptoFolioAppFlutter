import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_folio/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formatMarketCap formats large values with correct T/B/M/K suffixes', () {
      expect(CurrencyFormatter.formatMarketCap(1200000000000), equals('\$1.20T'));
      expect(CurrencyFormatter.formatMarketCap(340000000000), equals('\$340.0B'));
      expect(CurrencyFormatter.formatMarketCap(5000000), equals('\$5.0M'));
      expect(CurrencyFormatter.formatMarketCap(750000), equals('\$750.0K'));
    });

    test('formatPercent adds + sign for positive values and em-dash for null', () {
      expect(CurrencyFormatter.formatPercent(3.24), equals('+3.24%'));
      expect(CurrencyFormatter.formatPercent(-1.05), equals('-1.05%'));
      expect(CurrencyFormatter.formatPercent(0), equals('+0.00%'));
      expect(CurrencyFormatter.formatPercent(null), equals('—'));
    });
  });
}
