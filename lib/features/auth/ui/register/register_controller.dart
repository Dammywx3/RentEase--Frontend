import 'package:flutter/material.dart';
import 'package:rentease_frontend/core/config/env.dart';
import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/features/auth/data/auth_di.dart';

class RegisterController extends ChangeNotifier {
  RegisterController({required this.role});
  final UserRole role;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  String? error;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  bool _isEmail(String v) =>
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$').hasMatch(v);

  void validate() {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    if (name.length < 2) {
      error = 'Enter your full name.';
    } else if (email.isEmpty || !_isEmail(email)) {
      error = 'Enter a valid email.';
    } else if (pass.length < 8) {
      error = 'Password must be at least 8 characters.';
    } else if (Env.organizationId.trim().isEmpty) {
      error = 'Missing ORGANIZATION_ID. Set it in .env or dart-define.';
    } else {
      error = null;
    }
    notifyListeners();
  }

  Future<bool> register() async {
    validate();
    if (error != null) return false;

    loading = true;
    error = null;
    notifyListeners();

    try {
      await AuthDI.authRepo.register(
        fullName: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        password: passCtrl.text,
        role: role,
        organizationId: Env.organizationId.trim(),
      );

      // Send email verification OTP
      await AuthDI.authRepo.requestVerificationCode(
        email: emailCtrl.text.trim(),
        purpose: 'email_verify',
        channel: 'email',
      );

      return true;
    } catch (e) {
      error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
