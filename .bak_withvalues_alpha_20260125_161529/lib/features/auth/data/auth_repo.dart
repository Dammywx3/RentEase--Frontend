import 'package:rentease_frontend/core/config/env.dart';
import 'package:rentease_frontend/core/network/api_client.dart';
import 'package:rentease_frontend/core/network/api_error.dart';
import 'package:rentease_frontend/features/auth/data/auth_api.dart';
import 'package:rentease_frontend/shared/models/user_model.dart';

class AuthRepo {
  AuthRepo({ApiClient? client})
    : _client = client ?? ApiClient(),
      _api = AuthApi(client ?? ApiClient());

  final ApiClient _client;
  final AuthApi _api;

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final orgId = Env.organizationId;
    if (orgId.isEmpty) {
      throw ApiError(message: 'Missing ORGANIZATION_ID in .env');
    }

    final res = await _api.login(
      organizationId: orgId,
      email: email,
      password: password,
    );

    final user = UserModel.fromAuthResponse(res);
    if (user.id.isEmpty || user.token == null || user.token!.isEmpty) {
      throw ApiError(
        message: 'Login succeeded but response was missing user/token.',
      );
    }

    _client.setToken(user.token);
    return user;
  }

  Future<UserModel?> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final orgId = Env.organizationId;
    if (orgId.isEmpty) {
      throw ApiError(message: 'Missing ORGANIZATION_ID in .env');
    }

    final res = await _api.register(
      organizationId: orgId,
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );

    final user = UserModel.fromAuthResponse(res);
    if (user.id.isEmpty || user.token == null || user.token!.isEmpty) {
      throw ApiError(
        message: 'Register succeeded but response was missing user/token.',
      );
    }

    _client.setToken(user.token);
    return user;
  }

  // Keep these so other screens compile (until backend endpoints exist)
  Future<void> requestPasswordReset({required String emailOrPhone}) async {
    throw ApiError(
      message: 'Password reset is not implemented on backend yet.',
      code: 'NOT_IMPLEMENTED',
    );
  }

  Future<void> verifyOtp({
    required String emailOrPhone,
    required String otp,
  }) async {
    throw ApiError(
      message: 'OTP verify is not implemented on backend yet.',
      code: 'NOT_IMPLEMENTED',
    );
  }
}
