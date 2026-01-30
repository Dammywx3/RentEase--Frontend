class ApiError implements Exception {
  ApiError(this.message, {this.code, this.details});

  final String message;
  final String? code;
  final dynamic details;

  @override
  String toString() => 'ApiError(message: $message, code: $code, details: $details)';
}
