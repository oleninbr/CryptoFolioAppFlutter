import 'package:intl/intl.dart';

/// Formats monetary and percentage values for display in the UI.
/// All methods are static; never instantiate this class.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, String> _symbols = {
    'usd': '\$',
    'eur': '€',
    'uah': '₴',
  };

  // ── Price ────────────────────────────────────────────────────

  /// Format a coin price with the correct decimal precision.
  ///
  /// Examples (USD):
  ///   65432.10  → "$65,432.10"
  ///   0.8734    → "$0.8734"
  ///   0.000012  → "$0.00001200"
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

  // ── Market cap ───────────────────────────────────────────────

  /// Compact market-cap notation.
  ///
  /// Examples:
  ///   1_200_000_000_000 → "$1.20T"
  ///   340_000_000_000   → "$340.0B"
  ///   12_500_000        → "$12.5M"
  ///   900_000           → "$900K"
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

  // ── Percentage ───────────────────────────────────────────────

  /// Format a 24 h (or any) price-change percentage.
  ///
  /// Returns "—" for null values.
  /// Examples:  3.24 → "+3.24%"   -1.05 → "-1.05%"
  static String formatPercent(double? percent) {
    if (percent == null) return '—';
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

  // ── Legacy helpers (kept for backward compatibility) ─────────

  /// USD price with automatic decimal detection.
  static String formatUsd(double value) => formatPrice(value, 'usd');

  /// Compact USD value (uses Intl compact format).
  static String formatCompact(double value) {
    return NumberFormat.compactCurrency(symbol: '\$').format(value);
  }
}
