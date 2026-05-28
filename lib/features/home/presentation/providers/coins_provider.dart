import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_exception.dart';
import '../../data/datasources/coin_local_datasource.dart';
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
// Offline-mode flag
// ══════════════════════════════════════════════════════════════

/// `true` while the app is showing cached data because the network
/// is unavailable.  Observed by [HomeScreen] to show a banner.
final isOfflineModeProvider = StateProvider<bool>((ref) => false);

// ══════════════════════════════════════════════════════════════
// 1. coinsProvider  — AsyncNotifier
// ══════════════════════════════════════════════════════════════

/// Primary coins state.
/// A currency change (via [selectedCurrencyProvider]) triggers a rebuild.
final coinsProvider =
    AsyncNotifierProvider<CoinsNotifier, List<CoinMarketModel>>(
  CoinsNotifier.new,
);

class CoinsNotifier extends AsyncNotifier<List<CoinMarketModel>> {
  // ── Riverpod lifecycle ──────────────────────────────────────

  @override
  Future<List<CoinMarketModel>> build() async {
    final currency = ref.watch(selectedCurrencyProvider);

    // Clear any stale offline flag at the start of each build.
    Future.microtask(
      () => ref.read(isOfflineModeProvider.notifier).state = false,
    );

    final local = ref.read(coinLocalDataSourceProvider);
    final cached = await local.loadCoinsFromCache();
    final expired = await local.isCacheExpired();

    if (cached != null && cached.isNotEmpty && !expired) {
      // Cache is fresh — serve immediately and refresh in the background.
      _backgroundRefresh(currency);
      return cached;
    }

    // Cache absent or stale — must hit the network.
    return _fetchFromNetwork(currency);
  }

  // ── Public actions ──────────────────────────────────────────

  /// Bypasses the cache and forces a network fetch.
  /// Previous data stays visible during the load (no blank-screen flash).
  Future<void> refresh() async {
    state = const AsyncLoading<List<CoinMarketModel>>()
        .copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => _fetchFromNetwork(ref.read(selectedCurrencyProvider)),
    );
  }

  // ── Private helpers ─────────────────────────────────────────

  /// Fetches from the network, saves to cache, and returns the list.
  /// On [AppException] falls back to the cache and sets offline mode.
  Future<List<CoinMarketModel>> _fetchFromNetwork(String currency) async {
    try {
      final coins = await ref
          .read(coinRepositoryProvider)
          .getTopCoins(currency: currency);
      await ref.read(coinLocalDataSourceProvider).saveCoinsToCache(coins);
      ref.read(isOfflineModeProvider.notifier).state = false;
      return coins;
    } on AppException {
      final cached =
          await ref.read(coinLocalDataSourceProvider).loadCoinsFromCache();
      if (cached != null && cached.isNotEmpty) {
        ref.read(isOfflineModeProvider.notifier).state = true;
        return cached;
      }
      rethrow; // No cache — surface the error to the UI.
    }
  }

  /// Silently refreshes the cache with fresh network data.
  /// Any error is swallowed — the UI already shows valid cached data.
  Future<void> _backgroundRefresh(String currency) async {
    try {
      final coins = await ref
          .read(coinRepositoryProvider)
          .getTopCoins(currency: currency);
      await ref.read(coinLocalDataSourceProvider).saveCoinsToCache(coins);
      ref.read(isOfflineModeProvider.notifier).state = false;
      state = AsyncData(coins);
    } catch (_) {}
  }
}

// ══════════════════════════════════════════════════════════════
// 2. searchQueryProvider  — StateProvider
// ══════════════════════════════════════════════════════════════

/// Current search-field text.  Write:
///   ref.read(searchQueryProvider.notifier).state = query;
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

/// Active sort criterion for the coin list.
final sortOptionProvider =
    StateProvider<SortOption>((ref) => SortOption.marketCapDesc);

// ══════════════════════════════════════════════════════════════
// 5. sortedFilteredCoinsProvider  — derived Provider
// ══════════════════════════════════════════════════════════════

/// Filtered coins with the active [sortOptionProvider] applied.
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
