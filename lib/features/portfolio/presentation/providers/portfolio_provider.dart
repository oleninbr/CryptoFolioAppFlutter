import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/coins_provider.dart';
import '../../data/datasources/portfolio_remote_datasource.dart';
import '../../domain/models/portfolio_item_model.dart';

class PortfolioItemWithPrice {
  const PortfolioItemWithPrice({
    required this.item,
    required this.currentPrice,
  });

  final PortfolioItemModel item;
  final double currentPrice;
}

class PortfolioTotals {
  const PortfolioTotals({
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalProfitLoss,
    required this.totalProfitLossPercent,
  });

  final double totalInvested;
  final double totalCurrentValue;
  final double totalProfitLoss;
  final double totalProfitLossPercent;

  static const zero = PortfolioTotals(
    totalInvested: 0,
    totalCurrentValue: 0,
    totalProfitLoss: 0,
    totalProfitLossPercent: 0,
  );
}

final portfolioStreamProvider =
    StreamProvider.family<List<PortfolioItemModel>, String>((ref, uid) {
  return ref.watch(portfolioRemoteDataSourceProvider).watchPortfolio(uid);
});

final portfolioWithPricesProvider =
    Provider<AsyncValue<List<PortfolioItemWithPrice>>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final uid = authAsync.valueOrNull?.uid;

  if (uid == null) {
    return authAsync.isLoading
        ? const AsyncLoading()
        : const AsyncData(<PortfolioItemWithPrice>[]);
  }

  final portfolioAsync = ref.watch(portfolioStreamProvider(uid));
  final coinsAsync = ref.watch(coinsProvider);

  if (portfolioAsync.isLoading || coinsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (portfolioAsync.hasError) {
    return AsyncError(portfolioAsync.error!, StackTrace.current);
  }
  if (coinsAsync.hasError) {
    return AsyncError(coinsAsync.error!, StackTrace.current);
  }

  final portfolio = portfolioAsync.valueOrNull ?? const [];
  final coins = coinsAsync.valueOrNull ?? const [];
  final priceMap = <String, double>{for (final c in coins) c.id: c.currentPrice};

  return AsyncData(
    portfolio
        .map(
          (item) => PortfolioItemWithPrice(
            item: item,
            currentPrice: priceMap[item.coinId] ?? item.buyPrice,
          ),
        )
        .toList(),
  );
});

final portfolioTotalsProvider = Provider<PortfolioTotals>((ref) {
  final items = ref.watch(portfolioWithPricesProvider).valueOrNull ?? const [];

  if (items.isEmpty) return PortfolioTotals.zero;

  final invested = items.fold(0.0, (s, i) => s + i.item.totalInvested);
  final current = items.fold(0.0, (s, i) => s + i.item.currentValue(i.currentPrice));
  final pl = current - invested;
  final plPct = invested > 0 ? (pl / invested) * 100 : 0.0;

  return PortfolioTotals(
    totalInvested: invested,
    totalCurrentValue: current,
    totalProfitLoss: pl,
    totalProfitLossPercent: plPct,
  );
});

final portfolioNotifierProvider =
    AsyncNotifierProvider<PortfolioNotifier, void>(PortfolioNotifier.new);

class PortfolioNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> addItem(PortfolioItemModel item) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    await ref.read(portfolioRemoteDataSourceProvider).addOrUpdateItem(uid, item);
  }

  Future<void> deleteItem(String coinId) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    await ref.read(portfolioRemoteDataSourceProvider).deleteItem(uid, coinId);
  }
}
