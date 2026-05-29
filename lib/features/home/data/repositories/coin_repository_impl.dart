import '../../../../core/utils/app_exception.dart';
import '../../domain/models/coin_market_model.dart';
import '../../domain/repositories/coin_repository.dart';
import '../datasources/coin_remote_datasource.dart';
import '../../../coin_detail/domain/models/coin_detail_model.dart';
import '../../../coin_detail/domain/models/market_chart_model.dart';

class CoinRepositoryImpl implements CoinRepository {
  const CoinRepositoryImpl(this._dataSource);

  final CoinRemoteDataSource _dataSource;

  @override
  Future<List<CoinMarketModel>> getTopCoins({
    String currency = 'usd',
  }) async {
    try {
      return await _dataSource.getTopCoins(currency: currency);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Failed to load top coins: $e',
        type: AppExceptionType.unknown,
      );
    }
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async {
    try {
      return await _dataSource.getCoinDetail(coinId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Failed to load coin details for "$coinId": $e',
        type: AppExceptionType.unknown,
      );
    }
  }

  @override
  Future<MarketChartModel> getMarketChart(
    String coinId, {
    int days = 7,
  }) async {
    try {
      return await _dataSource.getMarketChart(coinId, days: days);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Failed to load chart for "$coinId": $e',
        type: AppExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<CoinMarketModel>> searchCoins(String query) async {
    try {
      return await _dataSource.searchCoins(query);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Search failed for "$query": $e',
        type: AppExceptionType.unknown,
      );
    }
  }
}
