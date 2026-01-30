import 'package:dio/dio.dart';

typedef TokenProvider = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenProvider});

  final TokenProvider tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

class LogInterceptorLite extends Interceptor {
  LogInterceptorLite({this.enabled = true});
  final bool enabled;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      // ignore: avoid_print
      print('[HTTP] → ${options.method} ${options.uri}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled) {
      // ignore: avoid_print
      print('[HTTP] ← ${response.statusCode} ${response.requestOptions.uri}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      // ignore: avoid_print
      print('[HTTP] ✕ ${err.response?.statusCode} ${err.requestOptions.uri} :: ${err.message}');
    }
    super.onError(err, handler);
  }
}
