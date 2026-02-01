import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:rentease_frontend/features/auth/data/auth_di.dart';
import 'forgot_password_state.dart';

class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController({String prefillEmail = ''})
    : _state = ForgotPasswordState.initial(prefillEmail: prefillEmail) {
    emailCtrl.text = _state.email;
  }

  final emailCtrl = TextEditingController();
  final emailFocus = FocusNode();

  ForgotPasswordState _state;
  ForgotPasswordState get state => _state;

  static final RegExp _emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    emailCtrl.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  String _prettyErr(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

  void setEmail(String v) {
    // keep state in sync + clear banners while typing
    _state = _state.copyWith(
      email: v.trim(),
      clearError: true,
      clearInfo: true,
    );
    notifyListeners();
  }

  String? _validateEmail() {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) return 'Enter your email address.';
    if (!_emailRx.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }

  /// Returns true when code request succeeded
  Future<bool> sendResetCode() async {
    if (_state.disabled) return false;

    final err = _validateEmail();
    if (err != null) {
      _state = _state.copyWith(error: err, clearInfo: true);
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(loading: true, clearError: true, clearInfo: true);
    notifyListeners();

    try {
      final email = emailCtrl.text.trim();

      await AuthDI.authRepo.requestPasswordReset(email: email);

      _state = _state.copyWith(
        loading: false,
        email: email,
        info: 'Code sent. Check your email.',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(loading: false, error: _prettyErr(e));
      notifyListeners();
      return false;
    }
  }
}
