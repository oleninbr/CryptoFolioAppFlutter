import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/coin_detail_model.dart';
import '../../domain/models/market_chart_model.dart';
import '../../../home/data/repositories/coin_repository_provider.dart';

/// Selected chart period in days. Shared across all open detail screens.
final selectedDaysProvider = StateProvider<int>((ref) => 7);

/// Fetches full [CoinDetailModel] for the given [coinId].
/// Keyed by coin ID so each coin gets its own provider instance.
final coinDetailProvider =
    FutureProvider.family<CoinDetailModel, String>((ref, coinId) {
  return ref.read(coinRepositoryProvider).getCoinDetail(coinId);
});

/// Fetches price history for [coinId] using the currently selected period.
/// Automatically re-fetches when [selectedDaysProvider] changes.
final marketChartProvider =
    FutureProvider.family<MarketChartModel, String>((ref, coinId) {
  final days = ref.watch(selectedDaysProvider);
  return ref.read(coinRepositoryProvider).getMarketChart(coinId, days: days);
});
