import 'package:rentease_frontend/core/network/api_client.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String organizationId,
  }) async {
    final body = <String, dynamic>{
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role,
      'organizationId': organizationId,
    };

    final res = await _client.post(
      '/v1/auth/register',
      data: body,
      headers: {'x-organization-id': organizationId},
    );

    // Backend returns: { ok, token, user:{...snake_case...} }
    final token = (res['token'] ?? '').toString();
    final user = (res['user'] is Map) ? Map<String, dynamic>.from(res['user']) : <String, dynamic>{};

    return <String, dynamic>{
      'token': token,
      ...user,
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String organizationId,
  }) async {
    final body = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    final res = await _client.post(
      '/v1/auth/login',
      data: body,
      headers: {'x-organization-id': organizationId},
    );

    final token = (res['token'] ?? '').toString();
    final user = (res['user'] is Map) ? Map<String, dynamic>.from(res['user']) : <String, dynamic>{};

    return <String, dynamic>{
      'token': token,
      ...user,
    };
  }
}
