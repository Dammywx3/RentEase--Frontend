class ApiError implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  ApiError({required this.message, this.code, this.details});

  @override
  String toString() =>
      'ApiError(message: $message, code: $code, details: $details)';
}
