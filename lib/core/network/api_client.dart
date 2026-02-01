import 'package:dio/dio.dart';
import 'package:rentease_frontend/core/config/env.dart';
import 'package:rentease_frontend/core/network/api_error.dart';
import 'package:rentease_frontend/core/network/interceptors.dart';
import 'package:rentease_frontend/core/network/token_store.dart';

class ApiClient {
  ApiClient({Dio? dio, Future<String?> Function()? tokenProvider})
      : _dio =
            dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.baseUrl.trim().replaceAll(RegExp(r'/$'), ''),
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                headers: {
                  'Content-Type': 'application/json',
                  // ✅ Default org header (global)
                  if (Env.organizationId.trim().isNotEmpty)
                    'x-organization-id': Env.organizationId.trim(),
                },
                responseType: ResponseType.json,
                validateStatus: (s) => s != null && s < 500,
              ),
            ) {
    _tokenProvider =
        tokenProvider ?? (() async => (await TokenStore.readToken()) ?? _token);

    _dio.interceptors.add(SimpleLogInterceptor());

    // ✅ Attach both token + orgId on every request
    _dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: _tokenProvider,
        organizationIdProvider: () async => Env.organizationId.trim(),
      ),
    );
  }

  final Dio _dio;
  late final Future<String?> Function() _tokenProvider;

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final res = await _dio.get(
        path,
        queryParameters: query,
        options: Options(headers: _mergeHeaders(headers)),
      );

      _throwIfHttpError(res);
      return _ensureMap(res);
    } on DioException catch (e) {
      throw _toApiError(e);
    }
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
        options: Options(headers: _mergeHeaders(headers)),
      );

      _throwIfHttpError(res);
      return _ensureMap(res);
    } on DioException catch (e) {
      throw _toApiError(e);
    }
  }

  // ✅ Merge headers so passing headers doesn't wipe out org header
  Map<String, dynamic> _mergeHeaders(Map<String, dynamic>? headers) {
    final merged = <String, dynamic>{};

    // Keep defaults
    merged['Content-Type'] = 'application/json';

    final orgId = Env.organizationId.trim();
    if (orgId.isNotEmpty) merged['x-organization-id'] = orgId;

    // Add per-request headers last (can override if you intentionally want)
    if (headers != null && headers.isNotEmpty) {
      merged.addAll(headers);
    }

    return merged;
  }

  void _throwIfHttpError(Response<dynamic> res) {
    final status = res.statusCode ?? 0;
    if (status >= 400) {
      final msg = _extractMessage(res.data) ?? 'Request failed ($status)';
      throw ApiError(
        message: msg,
        code: status.toString(),
        details: {
          'method': res.requestOptions.method,
          'url': res.requestOptions.uri.toString(),
          'status': status,
          'body': res.data,
          'headers': res.requestOptions.headers,
        },
      );
    }
  }

  String? _extractMessage(dynamic body) {
    if (body is Map) {
      final m = Map<String, dynamic>.from(body);

      final msg = m['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg;

      final err = m['error'];
      if (err is String && err.trim().isNotEmpty) return err;

      final errs = m['errors'];
      if (errs is List && errs.isNotEmpty) return errs.first.toString();
    }

    if (body is String && body.trim().isNotEmpty) return body;
    return null;
  }

  Map<String, dynamic> _ensureMap(Response<dynamic> res) {
    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ApiError(message: 'Invalid response format (expected JSON object).');
  }

  ApiError _toApiError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;

    final method = e.requestOptions.method;
    final url = e.requestOptions.uri.toString();

    return ApiError(
      message: _extractMessage(body) ?? e.message ?? 'Request failed',
      code: status?.toString(),
      details: {'method': method, 'url': url, 'status': status, 'body': body},
    );
  }
}