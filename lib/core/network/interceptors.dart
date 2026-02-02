import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:rentease_frontend/core/config/env.dart';

typedef TokenProvider = Future<String?> Function();
typedef OrganizationIdProvider = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenProvider,
    this.organizationIdProvider,
  });

  final TokenProvider tokenProvider;
  final OrganizationIdProvider? organizationIdProvider;

  String? _extractOrgFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded);

      if (map is Map && map['org'] != null) {
        final org = map['org'].toString().trim();
        return org.isEmpty ? null : org;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // ✅ Always attach token if present
    final tokenRaw = await tokenProvider();
    final token = tokenRaw?.trim();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // ✅ Org header priority (IMPORTANT):
    // 1) If token exists -> use org from token (prevents 403 mismatch)
    // 2) organizationIdProvider (optional)
    // 3) Env.organizationId fallback
    String orgId = '';

    if (token != null && token.isNotEmpty) {
      final orgFromToken = _extractOrgFromJwt(token);
      if (orgFromToken != null && orgFromToken.isNotEmpty) {
        orgId = orgFromToken;
      }
    }

    if (orgId.isEmpty && organizationIdProvider != null) {
      final provided = (await organizationIdProvider!())?.trim() ?? '';
      if (provided.isNotEmpty) orgId = provided;
    }

    if (orgId.isEmpty) {
      orgId = Env.organizationId.trim();
    }

    if (orgId.isNotEmpty) {
      options.headers['x-organization-id'] = orgId;
    }

    handler.next(options);
  }
}

class SimpleLogInterceptor extends Interceptor {
  bool _isAuthHeader(String k) => k.toLowerCase() == 'authorization';

  Map<String, dynamic> _safeHeaders(Map<String, dynamic> h) {
    final out = <String, dynamic>{};
    h.forEach((k, v) {
      out[k] = _isAuthHeader(k) ? 'Bearer ***' : v;
    });
    return out;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[HTTP] → ${options.method} ${options.uri}');
    // ignore: avoid_print
    print('[HTTP] headers: ${_safeHeaders(options.headers)}');
    // ignore: avoid_print
    print('[HTTP] body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[HTTP] ← ${response.statusCode} ${response.requestOptions.uri}');
    // ignore: avoid_print
    print('[HTTP] body: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print(
      '[HTTP] ✕ ${err.response?.statusCode} ${err.requestOptions.uri} :: ${err.message}',
    );
    // ignore: avoid_print
    print('[HTTP] errBody: ${err.response?.data}');
    handler.next(err);
  }
}