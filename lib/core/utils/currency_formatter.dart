import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, String> _symbols = {
    'usd': '\$',
    'eur': '€',
    'uah': '₴',
  };

  static String formatPrice(double price, String currency) {
    final symbol = _symbols[currency.toLowerCase()] ?? currency.toUpperCase();
    final int decimals;
    if (price >= 1) {
      decimals = 2;
    } else if (price >= 0.01) {
      decimals = 4;
    } else {
      decimals = 8;
    }
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: decimals,
    ).format(price);
  }

  static String formatMarketCap(double cap) {
    if (cap >= 1e12) {
      return '\$${(cap / 1e12).toStringAsFixed(2)}T';
    } else if (cap >= 1e9) {
      return '\$${(cap / 1e9).toStringAsFixed(1)}B';
    } else if (cap >= 1e6) {
      return '\$${(cap / 1e6).toStringAsFixed(1)}M';
    } else if (cap >= 1e3) {
      return '\$${(cap / 1e3).toStringAsFixed(1)}K';
    }
    return '\$${cap.toStringAsFixed(0)}';
  }

  static String formatPercent(double? percent) {
    if (percent == null) return '—';
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

  static String formatUsd(double value) => formatPrice(value, 'usd');

  static String formatCompact(double value) {
    return NumberFormat.compactCurrency(symbol: '\$').format(value);
  }
}
