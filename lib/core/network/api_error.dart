class ApiError implements Exception {
  ApiError({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  @override
  String toString() => message;
}