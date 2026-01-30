import 'package:rentease_frontend/core/network/api_client.dart';

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> register({
    required String organizationId,
    required String fullName,
    String? email,
    String? phone,
    required String password,
    required String role,
  }) {
    return _client.post(
      '/v1/auth/register',
      data: {
        'organizationId': organizationId,
        'fullName': fullName,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'password': password,
        'role': role,
      },
      headers: {
        // your backend expects this header for other routes; harmless here
        'x-organization-id': organizationId,
      },
    );
  }

  Future<Map<String, dynamic>> login({
    required String organizationId,
    required String email,
    required String password,
  }) {
    return _client.post(
      '/v1/auth/login',
      data: {'email': email.trim(), 'password': password},
      headers: {'x-organization-id': organizationId},
    );
  }
}
