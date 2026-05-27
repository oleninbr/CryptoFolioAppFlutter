import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/utils/app_exception.dart';
import '../../domain/models/coin_market_model.dart';
import '../../../coin_detail/domain/models/coin_detail_model.dart';
import '../../../coin_detail/domain/models/market_chart_model.dart';

final coinRemoteDataSourceProvider = Provider<CoinRemoteDataSource>((ref) {
  return CoinRemoteDataSource(ref.watch(dioProvider));
});

/// Fetches coin data directly from the CoinGecko REST API.
/// All [DioException]s are mapped to [AppException] before being rethrown.
class CoinRemoteDataSource {
  const CoinRemoteDataSource(this._dio);

  final Dio _dio;

  // ── Public API ───────────────────────────────────────────────

  Future<List<CoinMarketModel>> getTopCoins({
    String currency = ApiConstants.vsCurrency,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.coinsMarkets,
        queryParameters: {
          'vs_currency':            currency,
          'order':                  'market_cap_desc',
          'per_page':               ApiConstants.perPage,
          'page':                   1,
          'sparkline':              false,
          'price_change_percentage': '24h',
        },
      );
      return (response.data ?? [])
          .map((json) =>
              CoinMarketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<CoinDetailModel> getCoinDetail(String coinId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiConstants.coinDetail}/$coinId',
        queryParameters: {
          'localization':  false,
          'tickers':       false,
          'market_data':   true,
          'community_data': false,
          'developer_data': false,
        },
      );
      return CoinDetailModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<MarketChartModel> getMarketChart(
    String coinId, {
    int days = 7,
    String currency = ApiConstants.vsCurrency,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiConstants.coinDetail}/$coinId${ApiConstants.marketChart}',
        queryParameters: {
          'vs_currency': currency,
          'days':        days,
        },
      );
      return MarketChartModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<List<CoinMarketModel>> searchCoins(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.search,
        queryParameters: {'query': query},
      );
      final coins = response.data?['coins'] as List<dynamic>? ?? [];
      return coins
          .map((json) => CoinMarketModel.fromSearchJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  // ── Error mapping ────────────────────────────────────────────

  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const AppException(
          message: 'Request timed out. Please check your connection.',
          type: AppExceptionType.timeout,
        );

      case DioExceptionType.connectionError:
        return const AppException(
          message: 'No internet connection.',
          type: AppExceptionType.network,
        );

      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401 || code == 403) {
          return AppException(
            message: 'Access denied.',
            type: AppExceptionType.auth,
            statusCode: code,
          );
        }
        return AppException(
          message: 'Server error (HTTP $code).',
          type: AppExceptionType.server,
          statusCode: code,
        );

      case DioExceptionType.cancel:
        return const AppException(
          message: 'Request was cancelled.',
          type: AppExceptionType.unknown,
        );

      case DioExceptionType.badCertificate:
        return const AppException(
          message: 'SSL certificate error.',
          type: AppExceptionType.network,
        );

      case DioExceptionType.unknown:
        return AppException(
          message: e.message ?? 'An unexpected error occurred.',
          type: AppExceptionType.unknown,
        );
    }
  }
}
