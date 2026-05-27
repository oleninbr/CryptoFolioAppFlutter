import '../models/coin_market_model.dart';
import '../../../coin_detail/domain/models/coin_detail_model.dart';
import '../../../coin_detail/domain/models/market_chart_model.dart';

/// Contract for all coin-related data operations.
/// Implemented in the data layer; consumed by Riverpod providers and
/// use-case classes in the presentation layer.
abstract class CoinRepository {
  Future<List<CoinMarketModel>> getTopCoins({String currency = 'usd'});
  Future<CoinDetailModel>       getCoinDetail(String coinId);
  Future<MarketChartModel>      getMarketChart(String coinId, {int days = 7});
  Future<List<CoinMarketModel>> searchCoins(String query);
}
