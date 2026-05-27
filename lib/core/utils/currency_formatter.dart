import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String formatUsd(double value) {
    if (value >= 1) {
      return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);
    }
    return NumberFormat.currency(symbol: '\$', decimalDigits: 6).format(value);
  }

  static String formatCompact(double value) {
    return NumberFormat.compactCurrency(symbol: '\$').format(value);
  }
}
