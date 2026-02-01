// lib/features/auth/ui/verify_email/verify_email_controller.dart

import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/features/auth/data/auth_di.dart';
import 'package:rentease_frontend/shared/models/user_model.dart';

import 'verify_email_state.dart';
import 'verify_purpose.dart';

class VerifyEmailController extends ChangeNotifier {
  VerifyEmailController({
    required String email,
    required VerifyPurpose purpose,
    required String channel,
  }) : _state = VerifyEmailState(
          email: email.trim().toLowerCase(),
          purpose: purpose,
          channel: channel.trim().isEmpty ? 'email' : channel.trim(),
        );

  VerifyEmailState _state;
  VerifyEmailState get state => _state;

  void setCode(String v) {
    _state = _state.copyWith(
      code: v.trim(),
      error: null,
      info: null,
    );
    notifyListeners();
  }

  String _prettyErr(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

  bool _validateCode() {
    final code = state.code.trim();
    if (code.isEmpty) {
      _state = _state.copyWith(error: 'Enter the verification code.', info: null);
      notifyListeners();
      return false;
    }
    if (code.length < 6) {
      _state = _state.copyWith(error: 'Code must be 6 digits.', info: null);
      notifyListeners();
      return false;
    }
    return true;
  }

  /// ✅ Returns true if verification succeeded.
  /// - If purpose == login: confirms login OTP and stores token.
  /// - Else: confirms verification code (email/phone).
  Future<bool> verify() async {
    if (!_validateCode()) return false;

    _state = _state.copyWith(loading: true, error: null, info: null);
    notifyListeners();

    try {
      if (state.purpose == VerifyPurpose.login) {
        // ✅ IMPORTANT: login OTP uses /v1/auth/login/confirm
        final UserModel user = await AuthDI.authRepo.confirmLoginOtp(
          email: state.email,
          code: state.code.trim(),
        );

        // Optional: you can stash role/name somewhere else; screen already has args.
        final role = user.role ?? UserRole.tenant;

        _state = _state.copyWith(
          loading: false,
          info: 'Login confirmed as ${role.name}.',
          error: null,
        );
        notifyListeners();
        return true;
      }

      // ✅ Normal verification confirm endpoint
      await AuthDI.authRepo.confirmVerificationCode(
        email: state.email,
        code: state.code.trim(),
        purpose: state.purpose.backendValue,
        channel: state.channel,
      );

      _state = _state.copyWith(
        loading: false,
        info: 'Verified successfully.',
        error: null,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        loading: false,
        error: _prettyErr(e).isEmpty ? 'Verification failed.' : _prettyErr(e),
        info: null,
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> resend() async {
    _state = _state.copyWith(sending: true, error: null, info: null);
    notifyListeners();

    try {
      // ✅ Works for login too (resend code) as long as backend supports purpose=login
      await AuthDI.authRepo.requestVerificationCode(
        email: state.email,
        purpose: state.purpose.backendValue,
        channel: state.channel,
      );

      _state = _state.copyWith(
        sending: false,
        info: 'Code sent. Check ${state.channel}.',
        error: null,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        sending: false,
        error: _prettyErr(e).isEmpty ? 'Could not resend code.' : _prettyErr(e),
        info: null,
      );
      notifyListeners();
    }
  }
}