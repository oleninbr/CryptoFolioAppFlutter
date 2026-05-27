/// Classifies the origin of an [AppException].
enum AppExceptionType {
  network,  // no internet / connection refused
  server,   // HTTP 4xx / 5xx response
  timeout,  // connect / receive timeout
  auth,     // 401 or 403
  parse,    // JSON decode failure
  unknown,  // anything else
}

/// Domain-level exception thrown by repositories and data sources.
/// Always carries a human-readable [message] and a machine-readable [type].
class AppException implements Exception {
  const AppException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  final String message;
  final AppExceptionType type;
  final int? statusCode;

  @override
  String toString() =>
      'AppException(type: $type, statusCode: $statusCode, message: $message)';
}
