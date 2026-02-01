// lib/features/auth/ui/forgot_password/reset_verify_code_controller.dart
import 'package:flutter/material.dart';
import 'package:rentease_frontend/features/auth/data/auth_di.dart';
import 'reset_verify_code_state.dart';

class ResetVerifyCodeController extends ChangeNotifier {
  ResetVerifyCodeController({required String email})
      : _state = ResetVerifyCodeState.initial(email: email) {
    codeCtrl.addListener(() {
      // keep state in sync while typing
      _state = _state.copyWith(
        code: codeCtrl.text.trim(),
        clearError: true,
        clearInfo: true,
      );
      notifyListeners();
    });
  }

  final codeCtrl = TextEditingController();
  final codeFocus = FocusNode();

  ResetVerifyCodeState _state;
  ResetVerifyCodeState get state => _state;

  @override
  void dispose() {
    codeCtrl.dispose();
    codeFocus.dispose();
    super.dispose();
  }

  String _prettyErr(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

  /// ✅ REQUIRED BY YOUR SCREEN: onChanged: _c.setCode
  void setCode(String v) {
    _state = _state.copyWith(
      code: v.trim(),
      clearError: true,
      clearInfo: true,
    );
    notifyListeners();
  }

  bool _isValidCode(String v) => RegExp(r'^\d{6}$').hasMatch(v.trim());

  bool validateCode() {
    final v = codeCtrl.text.trim();
    if (!_isValidCode(v)) {
      _state = _state.copyWith(
        error: 'Enter the 6-digit code.',
        clearInfo: true,
      );
      notifyListeners();
      return false;
    }
    _state = _state.copyWith(clearError: true);
    notifyListeners();
    return true;
  }

  /// ✅ REQUIRED BY YOUR SCREEN: final code = _c.getValidCodeOrNull();
  String? getValidCodeOrNull() {
    if (!validateCode()) return null;
    return codeCtrl.text.trim();
  }

  Future<bool> resend() async {
    if (_state.disabled) return false;

    _state = _state.copyWith(
      sending: true,
      clearError: true,
      clearInfo: true,
    );
    notifyListeners();

    try {
      await AuthDI.authRepo.requestPasswordReset(email: _state.email);
      _state = _state.copyWith(
        sending: false,
        info: 'Code sent again. Check your email.',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        sending: false,
        error: _prettyErr(e),
      );
      notifyListeners();
      return false;
    }
  }
}