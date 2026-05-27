import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';

/// Provides a pre-configured [Dio] instance shared across all data sources.
final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  final dio = Dio(options);

  // Log request/response lines only in debug builds.
  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ),
    );
    return true;
  }());

  return dio;
});
