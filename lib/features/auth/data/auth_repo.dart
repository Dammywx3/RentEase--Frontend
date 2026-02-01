// lib/features/auth/data/auth_repo.dart
import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/core/network/api_client.dart';
import 'package:rentease_frontend/core/network/token_store.dart';
import 'package:rentease_frontend/features/auth/data/auth_api.dart';
import 'package:rentease_frontend/shared/models/user_model.dart';

class AuthRepo {
  AuthRepo(this._apiClient) : _api = AuthApi(_apiClient);

  final ApiClient _apiClient;
  final AuthApi _api;

  UserModel _userFromResponse(Map<String, dynamic> res) {
    return UserModel.fromAuthResponse(res);
  }

  String? _extractToken(Map<String, dynamic> res) {
    final t1 = res['token'];
    if (t1 is String && t1.isNotEmpty) return t1;

    final t2 = res['accessToken'];
    if (t2 is String && t2.isNotEmpty) return t2;

    final t3 = res['access_token'];
    if (t3 is String && t3.isNotEmpty) return t3;

    final data = res['data'];
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final dt1 = m['token'];
      if (dt1 is String && dt1.isNotEmpty) return dt1;

      final dt2 = m['accessToken'];
      if (dt2 is String && dt2.isNotEmpty) return dt2;

      final dt3 = m['access_token'];
      if (dt3 is String && dt3.isNotEmpty) return dt3;
    }

    return null;
  }

  String _msg(Map<String, dynamic> res, {String fallback = 'Request failed'}) {
    final m1 = res['message'];
    if (m1 is String && m1.trim().isNotEmpty) return m1;

    final m2 = res['error'];
    if (m2 is String && m2.trim().isNotEmpty) return m2;

    final errs = res['errors'];
    if (errs is List && errs.isNotEmpty) return errs.first.toString();

    return fallback;
  }

  bool _isOk(Map<String, dynamic> res) {
    final ok = res['ok'];
    if (ok is bool) return ok;
    return true;
  }

  Future<void> _persistToken(String token) async {
    _apiClient.setToken(token);
    await TokenStore.writeToken(token);
  }

  // ---------------------------
  // REGISTER
  // ---------------------------
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    required String organizationId,
    String? phone,
  }) async {
    final res = await _api.register(
      organizationId: organizationId,
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      role: role.name,
    );

    if (!_isOk(res) || res['ok'] == false) {
      throw Exception(_msg(res));
    }

    final token = _extractToken(res);
    if (token != null) {
      await _persistToken(token);
    }

    return _userFromResponse(res);
  }

  // ---------------------------
  // LOGIN (OTP-aware)
  // ---------------------------
  Future<LoginOutcome> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.login(email: email, password: password);

    if (!_isOk(res) || res['ok'] == false) {
      throw Exception(_msg(res, fallback: 'Invalid login details.'));
    }

    final requiresOtp = (res['requiresOtp'] == true);
    if (requiresOtp) {
      return LoginOutcome.requiresOtp(email: email.trim().toLowerCase());
    }

    final token = _extractToken(res);
    if (token != null) {
      await _persistToken(token);
    }

    return LoginOutcome.success(user: _userFromResponse(res));
  }

  Future<UserModel> confirmLoginOtp({
    required String email,
    required String code,
  }) async {
    final res = await _api.loginConfirm(email: email, code: code);

    if (!_isOk(res) || res['ok'] == false) {
      throw Exception(_msg(res, fallback: 'Invalid verification code.'));
    }

    final token = _extractToken(res);
    if (token != null) {
      await _persistToken(token);
    }

    return _userFromResponse(res);
  }

  // ---------------------------
  // PASSWORD RESET (2-step)
  // ---------------------------
  Future<void> requestPasswordReset({required String email}) async {
    final res = await _api.requestPasswordReset(email: email);
    if (res['ok'] == false) {
      throw Exception(_msg(res, fallback: 'Could not request reset code.'));
    }
  }

  Future<ResetVerifyResult> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final res = await _api.verifyResetCode(email: email, code: code);

    if (!_isOk(res) || res['ok'] == false) {
      throw Exception(_msg(res, fallback: 'Invalid verification code.'));
    }

    final resetToken = res['resetToken'];
    if (resetToken is! String || resetToken.trim().isEmpty) {
      throw Exception('Reset token missing from server response.');
    }

    final expiresAt = (res['expiresAt'] ?? '').toString();
    return ResetVerifyResult(resetToken: resetToken, expiresAt: expiresAt);
  }

  /// ✅ Backward-compatible name (some screens call this)
  Future<ResetVerifyResult> verifyPasswordResetCode({
    required String email,
    required String code,
  }) {
    return verifyResetCode(email: email, code: code);
  }

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final res = await _api.resetPassword(
      email: email,
      resetToken: resetToken,
      newPassword: newPassword,
    );

    if (res['ok'] == false) {
      throw Exception(_msg(res, fallback: 'Password reset failed.'));
    }
  }

  /// ✅ Backward-compatible name (some screens call this)
  Future<void> resetPasswordWithResetToken({
    required String email,
    required String resetToken,
    required String newPassword,
  }) {
    return resetPassword(
      email: email,
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }

  // ---------------------------
  // VERIFICATION
  // ---------------------------
  Future<void> requestVerificationCode({
    required String email,
    String purpose = 'email_verify',
    String channel = 'email',
  }) async {
    final res = await _api.verificationRequest(
      channel: channel,
      destination: email.trim().toLowerCase(),
      purpose: purpose.trim(),
    );

    if (res['ok'] == false) {
      throw Exception(_msg(res, fallback: 'Could not send verification code.'));
    }
  }

  Future<Map<String, dynamic>> confirmVerificationCode({
    required String email,
    required String code,
    String purpose = 'email_verify',
    String channel = 'email',
  }) async {
    final res = await _api.verificationConfirm(
      channel: channel,
      destination: email.trim().toLowerCase(),
      purpose: purpose.trim(),
      code: code.trim(),
    );

    if (res['ok'] == false) {
      throw Exception(_msg(res, fallback: 'Invalid verification code.'));
    }

    return res;
  }
}

class LoginOutcome {
  LoginOutcome._({this.requiresOtp = false, this.email, this.user});

  final bool requiresOtp;
  final String? email;
  final UserModel? user;

  factory LoginOutcome.requiresOtp({required String email}) =>
      LoginOutcome._(requiresOtp: true, email: email);

  factory LoginOutcome.success({required UserModel user}) =>
      LoginOutcome._(requiresOtp: false, user: user);
}

class ResetVerifyResult {
  ResetVerifyResult({required this.resetToken, required this.expiresAt});
  final String resetToken;
  final String expiresAt;
}
