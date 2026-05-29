
enum AppExceptionType {
  network,
  server,
  timeout,
  auth,
  parse,
  unknown,
}

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
