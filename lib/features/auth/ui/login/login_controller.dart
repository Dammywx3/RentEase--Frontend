// lib/features/auth/ui/login/login_controller.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/features/auth/data/auth_di.dart';

import 'login_state.dart';

class LoginController extends ChangeNotifier {
  LoginController() {
    emailCtrl.addListener(_syncFromControllers);
    passCtrl.addListener(_syncFromControllers);
  }

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  LoginState _state = LoginState.initial();
  LoginState get state => _state;

  static final RegExp _emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  void _syncFromControllers() {
    _state = _state.copyWith(
      email: emailCtrl.text.trim(),
      password: passCtrl.text,
      error: null,
    );
    notifyListeners();
  }

  void toggleObscure() {
    _state = _state.copyWith(obscure: !_state.obscure);
    notifyListeners();
  }

  void setError(String? msg) {
    _state = _state.copyWith(error: msg);
    notifyListeners();
  }

  String _prettyErr(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

  bool validateForm() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    if (email.isEmpty) {
      setError('Enter your email address.');
      return false;
    }
    if (!_emailRx.hasMatch(email)) {
      setError('Enter a valid email address.');
      return false;
    }
    if (pass.isEmpty) {
      setError('Enter your password.');
      return false;
    }
    if (pass.length < 8) {
      setError('Password must be at least 8 characters.');
      return false;
    }

    setError(null);
    return true;
  }

  /// ✅ Returns either:
  /// - requiresOtp (email only)
  /// - success (fullName + role)
  Future<LoginOutcomeUI?> login() async {
    if (!validateForm()) return null;

    _state = _state.copyWith(loading: true, error: null);
    notifyListeners();

    try {
      final out = await AuthDI.authRepo.login(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      if (out.requiresOtp) {
        return LoginOutcomeUI.requiresOtp(
          email: out.email ?? emailCtrl.text.trim(),
        );
      }

      final user = out.user;
      if (user == null) {
        return LoginOutcomeUI.success(
          fullName: 'User',
          role: UserRole.tenant,
        );
      }

      final fullName = (user.fullName ?? '').trim();
      final role = user.role ?? UserRole.tenant;

      return LoginOutcomeUI.success(
        fullName: fullName.isEmpty ? 'User' : fullName,
        role: role,
      );
    } catch (e) {
      final msg = _prettyErr(e);
      setError(msg.isEmpty ? 'Login failed. Try again.' : msg);
      return null;
    } finally {
      _state = _state.copyWith(loading: false);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailCtrl.removeListener(_syncFromControllers);
    passCtrl.removeListener(_syncFromControllers);

    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }
}

class LoginOutcomeUI {
  LoginOutcomeUI._({
    required this.requiresOtp,
    required this.email,
    this.fullName,
    this.role,
  });

  final bool requiresOtp;
  final String email;

  // only for success
  final String? fullName;
  final UserRole? role;

  factory LoginOutcomeUI.requiresOtp({required String email}) =>
      LoginOutcomeUI._(requiresOtp: true, email: email);

  factory LoginOutcomeUI.success({
    required String fullName,
    required UserRole role,
  }) =>
      LoginOutcomeUI._(
        requiresOtp: false,
        email: '',
        fullName: fullName,
        role: role,
      );
}