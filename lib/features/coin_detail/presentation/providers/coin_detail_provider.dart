import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/coin_detail_model.dart';
import '../../domain/models/market_chart_model.dart';
import '../../../home/data/repositories/coin_repository_provider.dart';

final selectedDaysProvider = StateProvider<int>((ref) => 7);

final coinDetailProvider =
    FutureProvider.family<CoinDetailModel, String>((ref, coinId) {
  return ref.read(coinRepositoryProvider).getCoinDetail(coinId);
});

final marketChartProvider =
    FutureProvider.family<MarketChartModel, String>((ref, coinId) {
  final days = ref.watch(selectedDaysProvider);
  return ref.read(coinRepositoryProvider).getMarketChart(coinId, days: days);
});
