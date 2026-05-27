import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_exception.dart';
import '../../data/repositories/coin_repository_provider.dart';
import '../../domain/models/coin_market_model.dart';
import 'selected_currency_provider.dart';

// ══════════════════════════════════════════════════════════════
// Sort option
// ══════════════════════════════════════════════════════════════

enum SortOption {
  marketCapDesc,
  priceDesc,
  priceAsc,
  changeDesc,
}

// ══════════════════════════════════════════════════════════════
// 1. coinsProvider  — AsyncNotifier
// ══════════════════════════════════════════════════════════════

/// The primary coins state.
/// Watches [selectedCurrencyProvider]: a currency change triggers a new fetch.
final coinsProvider =
    AsyncNotifierProvider<CoinsNotifier, List<CoinMarketModel>>(
  CoinsNotifier.new,
);

class CoinsNotifier extends AsyncNotifier<List<CoinMarketModel>> {
  // ── Riverpod lifecycle ──────────────────────────────────────

  @override
  Future<List<CoinMarketModel>> build() async {
    // Reactive: re-runs automatically whenever the currency changes.
    final currency = ref.watch(selectedCurrencyProvider);
    return _fetchAndCache(currency);
  }

  // ── Public actions ──────────────────────────────────────────

  /// Re-fetches coins from the network, keeping the previous list
  /// visible during the load (no blank-screen flicker).
  Future<void> refresh() async {
    state = const AsyncLoading<List<CoinMarketModel>>()
        .copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => _fetchAndCache(ref.read(selectedCurrencyProvider)),
    );
  }

  // ── Private helpers ─────────────────────────────────────────

  Future<List<CoinMarketModel>> _fetchAndCache(String currency) async {
    try {
      final coins = await ref
          .read(coinRepositoryProvider)
          .getTopCoins(currency: currency);
      await _saveToCache(coins);
      return coins;
    } on AppException {
      // Network / server error: fall back to cache rather than crash.
      final cached = await _loadFromCache();
      if (cached != null && cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<CoinMarketModel>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.coinsKey);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CoinMarketModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null; // Corrupt cache — ignore silently.
    }
  }

  Future<void> _saveToCache(List<CoinMarketModel> coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(coins.map((c) => c.toJson()).toList());
      await prefs.setString(AppConstants.coinsKey, encoded);
    } catch (_) {
      // Cache write failure must never propagate to the UI.
    }
  }
}

// ══════════════════════════════════════════════════════════════
// 2. searchQueryProvider  — StateProvider
// ══════════════════════════════════════════════════════════════

/// The current text in the search field.
/// Write with ref.read(searchQueryProvider.notifier).state = query;
final searchQueryProvider = StateProvider<String>((ref) => '');

// ══════════════════════════════════════════════════════════════
// 3. filteredCoinsProvider  — derived Provider
// ══════════════════════════════════════════════════════════════

/// Coins filtered by [searchQueryProvider].
/// Loading / error states from [coinsProvider] pass through unchanged.
final filteredCoinsProvider =
    Provider<AsyncValue<List<CoinMarketModel>>>((ref) {
  final coinsAsync = ref.watch(coinsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return coinsAsync.whenData((coins) {
    if (query.isEmpty) return coins;
    return coins
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.symbol.toLowerCase().contains(query))
        .toList();
  });
});

// ══════════════════════════════════════════════════════════════
// 4. sortOptionProvider  — StateProvider
// ══════════════════════════════════════════════════════════════

/// Active sort mode for the coin list.
final sortOptionProvider =
    StateProvider<SortOption>((ref) => SortOption.marketCapDesc);

// ══════════════════════════════════════════════════════════════
// 5. sortedFilteredCoinsProvider  — derived Provider
// ══════════════════════════════════════════════════════════════

/// Filtered coins with [sortOptionProvider] applied.
/// This is the provider the home list widget should watch.
final sortedFilteredCoinsProvider =
    Provider<AsyncValue<List<CoinMarketModel>>>((ref) {
  final filtered = ref.watch(filteredCoinsProvider);
  final sort = ref.watch(sortOptionProvider);

  return filtered.whenData((coins) {
    final list = List<CoinMarketModel>.of(coins);
    switch (sort) {
      case SortOption.marketCapDesc:
        list.sort((a, b) => b.marketCap.compareTo(a.marketCap));
      case SortOption.priceDesc:
        list.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
      case SortOption.priceAsc:
        list.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
      case SortOption.changeDesc:
        list.sort((a, b) {
          final ac =
              a.priceChangePercentage24h ?? double.negativeInfinity;
          final bc =
              b.priceChangePercentage24h ?? double.negativeInfinity;
          return bc.compareTo(ac);
        });
    }
    return list;
  });
});
