import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/coin_repository.dart';
import '../datasources/coin_remote_datasource.dart';
import 'coin_repository_impl.dart';

/// Binds the abstract [CoinRepository] to [CoinRepositoryImpl].
/// Swap this provider in tests to inject a mock without touching
/// any presentation-layer code.
final coinRepositoryProvider = Provider<CoinRepository>((ref) {
  return CoinRepositoryImpl(ref.watch(coinRemoteDataSourceProvider));
});
