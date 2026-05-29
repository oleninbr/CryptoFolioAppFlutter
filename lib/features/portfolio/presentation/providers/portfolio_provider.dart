import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/coins_provider.dart';
import '../../data/datasources/portfolio_remote_datasource.dart';
import '../../domain/models/portfolio_item_model.dart';

// ── Helper types ───────────────────────────────────────────────────────────────

/// A portfolio item paired with its live market price.
class PortfolioItemWithPrice {
  const PortfolioItemWithPrice({
    required this.item,
    required this.currentPrice,
  });

  final PortfolioItemModel item;
  final double currentPrice;
}

/// Aggregated portfolio totals derived from [portfolioWithPricesProvider].
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

// ── a) Stream provider (real-time Firestore) ───────────────────────────────────

/// Real-time stream of portfolio items for [uid].
final portfolioStreamProvider =
    StreamProvider.family<List<PortfolioItemModel>, String>((ref, uid) {
  return ref.watch(portfolioRemoteDataSourceProvider).watchPortfolio(uid);
});

// ── b) Portfolio combined with live market prices ──────────────────────────────

/// Merges [portfolioStreamProvider] with current coin prices from
/// [coinsProvider].  Returns [AsyncLoading] until both sources are ready.
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

// ── c) Aggregated totals ───────────────────────────────────────────────────────

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

// ── d) Action notifier ────────────────────────────────────────────────────────

final portfolioNotifierProvider =
    AsyncNotifierProvider<PortfolioNotifier, void>(PortfolioNotifier.new);

class PortfolioNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Adds a new item or updates quantity if the coin is already in portfolio.
  Future<void> addItem(PortfolioItemModel item) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    await ref.read(portfolioRemoteDataSourceProvider).addOrUpdateItem(uid, item);
  }

  /// Removes the coin with [coinId] from the portfolio.
  Future<void> deleteItem(String coinId) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    await ref.read(portfolioRemoteDataSourceProvider).deleteItem(uid, coinId);
  }
}
