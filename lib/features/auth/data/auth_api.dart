import 'package:rentease_frontend/core/config/api_endpoints.dart';
import 'package:rentease_frontend/core/network/api_client.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _client.post(
      ApiEndpoints.login,
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
  }

  Future<Map<String, dynamic>> loginConfirm({
    required String email,
    required String code,
  }) {
    return _client.post(
      ApiEndpoints.loginConfirm,
      data: {'email': email.trim().toLowerCase(), 'code': code.trim()},
    );
  }

  Future<Map<String, dynamic>> register({
    required String organizationId,
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required String role, // tenant | landlord | agent | admin
  }) {
    return _client.post(
      ApiEndpoints.register,
      data: {
        'organizationId': organizationId.trim(),
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'password': password,
        'role': role,
      },
    );
  }

  Future<Map<String, dynamic>> me() {
    return _client.get(ApiEndpoints.me);
  }

  // Password reset (2-step)
  Future<Map<String, dynamic>> requestPasswordReset({required String email}) {
    return _client.post(
      ApiEndpoints.requestPasswordReset,
      data: {'email': email.trim().toLowerCase()},
    );
  }

  Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) {
    return _client.post(
      ApiEndpoints.verifyResetCode,
      data: {'email': email.trim().toLowerCase(), 'code': code.trim()},
    );
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) {
    return _client.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email.trim().toLowerCase(),
        'resetToken': resetToken.trim(),
        'newPassword': newPassword,
      },
    );
  }

  // Generic verification
  Future<Map<String, dynamic>> verificationRequest({
    required String channel, // email|sms
    required String destination,
    required String purpose, // email_verify|password_reset|phone_verify|login
  }) {
    return _client.post(
      ApiEndpoints.verificationRequest,
      data: {
        'channel': channel,
        'destination': destination,
        'purpose': purpose,
      },
    );
  }

  Future<Map<String, dynamic>> verificationConfirm({
    required String channel,
    required String destination,
    required String purpose,
    required String code,
  }) {
    return _client.post(
      ApiEndpoints.verificationConfirm,
      data: {
        'channel': channel,
        'destination': destination,
        'purpose': purpose,
        'code': code,
      },
    );
  }
}
