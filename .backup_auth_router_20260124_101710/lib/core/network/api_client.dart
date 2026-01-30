import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rentease_frontend/core/config/env.dart';
import 'package:rentease_frontend/core/network/interceptors.dart';
import 'package:rentease_frontend/core/network/token_store.dart';

typedef TokenProvider = Future<String?> Function();

class ApiError implements Exception {
  final dynamic message;
  final String? code;
  final dynamic details;

  ApiError({required this.message, this.code, this.details});

  @override
  String toString() => 'ApiError(message: $message, code: $code, details: $details)';
}

class ApiClient {
  ApiClient({
    String? baseUrl,
    TokenProvider? tokenProvider,
  })  : _dio = Dio(
          BaseOptions(
            baseUrl: (baseUrl ?? Env.baseUrl).trim(),
            connectTimeout: const Duration(seconds: 25),
            receiveTimeout: const Duration(seconds: 25),
            sendTimeout: const Duration(seconds: 25),
            headers: <String, dynamic>{
              'Content-Type': 'application/json',
            },
          ),
        ),
        _tokenProvider = tokenProvider ?? TokenStore.readToken {
    // Always attach x-organization-id if present
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final orgId = Env.organizationId.trim();
          if (orgId.isNotEmpty) {
            options.headers['x-organization-id'] = orgId;
          }
          return handler.next(options);
        },
      ),
    );

    // Auth + logging interceptors from your project
    _dio.interceptors.add(AuthInterceptor(_tokenProvider));
    _dio.interceptors.add(HttpLogInterceptor());
  }

  final Dio _dio;
  final TokenProvider _tokenProvider;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final res = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return res.data;
    } on DioException catch (e) {
      throw _toApiError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    try {
      final res = await _dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return res.data;
    } on DioException catch (e) {
      throw _toApiError(e);
    }
  }

  ApiError _toApiError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('message')) {
      return ApiError(
        message: data['message'],
        code: (data['code'] ?? '').toString().isEmpty ? null : data['code'].toString(),
        details: data['details'],
      );
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map && decoded.containsKey('message')) {
          return ApiError(
            message: decoded['message'],
            code: (decoded['code'] ?? '').toString().isEmpty ? null : decoded['code'].toString(),
            details: decoded['details'],
          );
        }
      } catch (_) {}
    }
    return ApiError(message: e.message ?? 'Request failed');
  }
}
