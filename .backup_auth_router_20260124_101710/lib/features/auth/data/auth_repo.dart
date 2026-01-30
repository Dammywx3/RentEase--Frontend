import 'package:rentease_frontend/core/config/env.dart';
import 'package:rentease_frontend/core/network/api_client.dart';
import 'package:rentease_frontend/core/network/api_error.dart';
import 'package:rentease_frontend/features/auth/data/auth_api.dart';
import 'package:rentease_frontend/shared/models/user_model.dart';

class AuthRepo {
  AuthRepo(this._client) : _api = AuthApi(_client);

  final ApiClient _client;
  final AuthApi _api;

  bool _looksLikeEmail(String v) => v.contains('@');

  String _requireOrg(String? organizationId) {
    final org = (organizationId ?? Env.organizationId).trim();
    if (org.isEmpty) {
      throw ApiError(
        message: 'Missing ORGANIZATION_ID. Put it in .env (frontend root).',
        code: 'MISSING_ORG',
      );
    }
    return org;
  }

  Future<UserModel?> login({
    required String emailOrPhone,
    required String password,
    String? organizationId,
  }) async {
    final org = _requireOrg(organizationId);

    if (!_looksLikeEmail(emailOrPhone.trim())) {
      // Backend login schema currently supports EMAIL only.
      throw ApiError(
        message: 'Phone login is not supported yet. Use an email for now.',
        code: 'PHONE_LOGIN_NOT_SUPPORTED',
      );
    }

    final json = await _api.login(
      email: emailOrPhone,
      password: password,
      organizationId: org,
    );

    final user = UserModel.fromJson(json);
    if (user.id.isEmpty || user.token.isEmpty) {
      throw ApiError(message: 'Login succeeded but response was missing user/token.', code: 'BAD_LOGIN_RESPONSE');
    }
    return user;
  }

  Future<UserModel?> register({
    required String fullName,
    required String emailOrPhone,
    required String password,
    required String role,
  }) async {
    final org = _requireOrg(null);

    if (!_looksLikeEmail(emailOrPhone.trim())) {
      throw ApiError(
        message: 'Phone registration is not supported yet. Use an email for now.',
        code: 'PHONE_REGISTER_NOT_SUPPORTED',
      );
    }

    final json = await _api.register(
      fullName: fullName,
      email: emailOrPhone,
      password: password,
      role: role,
      organizationId: org,
    );

    final user = UserModel.fromJson(json);
    if (user.id.isEmpty || user.token.isEmpty) {
      throw ApiError(message: 'Register succeeded but response was missing user/token.', code: 'BAD_REGISTER_RESPONSE');
    }
    return user;
  }

  // Backend does not have these endpoints yet, but screens reference them.
  Future<void> requestPasswordReset({required String emailOrPhone}) async {
    throw ApiError(message: 'Password reset is not implemented on backend yet.', code: 'NOT_IMPLEMENTED');
  }

  Future<void> verifyOtp({required String emailOrPhone, required String otp}) async {
    throw ApiError(message: 'OTP verify is not implemented on backend yet.', code: 'NOT_IMPLEMENTED');
  }
}
