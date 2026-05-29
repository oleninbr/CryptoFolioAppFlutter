import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_exception.dart';
import '../../data/datasources/coin_local_datasource.dart';
import '../../data/repositories/coin_repository_provider.dart';
import '../../domain/models/coin_market_model.dart';
import 'selected_currency_provider.dart';

enum SortOption {
  marketCapDesc,
  priceDesc,
  priceAsc,
  changeDesc,
}

final isOfflineModeProvider = StateProvider<bool>((ref) => false);

final coinsProvider =
    AsyncNotifierProvider<CoinsNotifier, List<CoinMarketModel>>(
  CoinsNotifier.new,
);

class CoinsNotifier extends AsyncNotifier<List<CoinMarketModel>> {

  @override
  Future<List<CoinMarketModel>> build() async {
    final currency = ref.watch(selectedCurrencyProvider);

    Future.microtask(
      () => ref.read(isOfflineModeProvider.notifier).state = false,
    );

    final local = ref.read(coinLocalDataSourceProvider);
    final cached = await local.loadCoinsFromCache();
    final expired = await local.isCacheExpired();

    if (cached != null && cached.isNotEmpty && !expired) {

      _backgroundRefresh(currency);
      return cached;
    }

    return _fetchFromNetwork(currency);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<CoinMarketModel>>()
        .copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => _fetchFromNetwork(ref.read(selectedCurrencyProvider)),
    );
  }

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
      rethrow;
    }
  }

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

final searchQueryProvider = StateProvider<String>((ref) => '');

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

final sortOptionProvider =
    StateProvider<SortOption>((ref) => SortOption.marketCapDesc);

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
