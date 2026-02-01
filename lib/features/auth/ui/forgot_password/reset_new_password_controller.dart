import 'package:flutter/material.dart';
import 'package:rentease_frontend/features/auth/data/auth_di.dart';
import 'reset_new_password_state.dart';

class ResetNewPasswordController extends ChangeNotifier {
  ResetNewPasswordController({
    required String email,
    required String resetToken,
  }) : _state = ResetNewPasswordState.initial(email: email, code: resetToken);

  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final passFocus = FocusNode();
  final confirmFocus = FocusNode();

  ResetNewPasswordState _state;
  ResetNewPasswordState get state => _state;

  @override
  void dispose() {
    passCtrl.dispose();
    confirmCtrl.dispose();
    passFocus.dispose();
    confirmFocus.dispose();
    super.dispose();
  }

  String _prettyErr(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

  void onTyping() {
    if (_state.error != null || _state.info != null) {
      _state = _state.copyWith(clearError: true, clearInfo: true);
      notifyListeners();
    }
  }

  void toggleObscure1() {
    _state = _state.copyWith(obscure1: !_state.obscure1);
    notifyListeners();
  }

  void toggleObscure2() {
    _state = _state.copyWith(obscure2: !_state.obscure2);
    notifyListeners();
  }

  String? _validate() {
    final p1 = passCtrl.text;
    final p2 = confirmCtrl.text;

    if (p1.trim().isEmpty) return 'Enter a new password.';
    if (p1.length < 8) return 'Password must be at least 8 characters.';
    if (p2.trim().isEmpty) return 'Confirm your password.';
    if (p1 != p2) return 'Passwords do not match.';
    return null;
  }

  /// ✅ Step 3 backend: reset with resetToken
  Future<bool> submit() async {
    if (_state.disabled) return false;

    final err = _validate();
    if (err != null) {
      _state = _state.copyWith(error: err, clearInfo: true);
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(loading: true, clearError: true, clearInfo: true);
    notifyListeners();

    try {
      await AuthDI.authRepo.resetPassword(
        email: _state.email,
        resetToken: _state.code, // NOTE: state.code holds resetToken now
        newPassword: passCtrl.text,
      );

      _state = _state.copyWith(
        loading: false,
        info: 'Password updated successfully.',
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
