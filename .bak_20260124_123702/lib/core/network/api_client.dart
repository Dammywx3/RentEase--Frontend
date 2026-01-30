import 'package:dio/dio.dart';
import 'package:rentease_frontend/core/config/env.dart';
import 'package:rentease_frontend/core/network/api_error.dart';
import 'package:rentease_frontend/core/network/interceptors.dart';

class ApiClient {
  ApiClient({Dio? dio, Future<String?> Function()? tokenProvider})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: Env.baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              headers: {
                'Content-Type': 'application/json',
              },
            )) {
    _tokenProvider = tokenProvider ?? (() async => _token);

    _dio.interceptors.add(SimpleLogInterceptor());
    _dio.interceptors.add(AuthInterceptor(tokenProvider: _tokenProvider));
  }

  final Dio _dio;
  late final Future<String?> Function() _tokenProvider;

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final res = await _dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );
      if (res.data is Map<String, dynamic>) return Map<String, dynamic>.from(res.data);
      throw ApiError(message: 'Invalid response format (expected JSON object).');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw ApiError(
        message: body?.toString() ?? e.message ?? 'Request failed',
        code: status?.toString(),
        details: body,
      );
    }
  }
}
