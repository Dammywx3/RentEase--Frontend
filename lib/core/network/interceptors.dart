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

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // ✅ Always ensure org header (multi-tenancy)
    String orgId = Env.organizationId.trim();
    if (organizationIdProvider != null) {
      final provided = (await organizationIdProvider!())?.trim() ?? '';
      if (provided.isNotEmpty) orgId = provided;
    }

    if (orgId.isNotEmpty) {
      // overwrite to guarantee correct org per request
      options.headers['x-organization-id'] = orgId;
    }

    // ✅ Attach auth token when present
    final token = await tokenProvider();
    if (token != null && token.trim().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    handler.next(options);
  }
}

class SimpleLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[HTTP] → ${options.method} ${options.uri}');
    // ignore: avoid_print
    print('[HTTP] headers: ${options.headers}');
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