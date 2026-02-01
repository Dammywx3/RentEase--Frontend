// lib/features/auth/ui/verify_email/verify_email_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/core/network/api_client.dart'; // ✅ NEW import
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

// ✅ success screen
import 'account_created_screen.dart';

import '../../welcome/post_login_welcome_screen.dart';

import 'verify_email_controller.dart';
import 'verify_email_state.dart';
import 'verify_purpose.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.role,
    required this.fullName,
    required this.purpose,
    this.channel = 'email',
  });

  final String email;
  final UserRole role;
  final String fullName;

  final VerifyPurpose purpose;
  final String channel;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final VerifyEmailController _c;

  final _codeCtrl = TextEditingController();
  final _codeFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _c = VerifyEmailController(
      email: widget.email,
      purpose: widget.purpose,
      channel: widget.channel,
    )..addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_onChanged);
    _c.dispose();
    _codeCtrl.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  String get _subtitle {
    if (widget.purpose == VerifyPurpose.login) {
      return 'We sent a 6-digit code to\n${widget.email}';
    }
    return 'We sent a verification code to\n${widget.email}';
  }

  UserRole _parseUserRoleFromBackend(String raw, {required UserRole fallback}) {
    final v = raw.trim().toLowerCase();
    switch (v) {
      case 'tenant':
        return UserRole.tenant;
      case 'agent':
        return UserRole.agent;
      case 'landlord':
        return UserRole.landlord;
      case 'admin':
        return UserRole.admin;
      default:
        return fallback;
    }
  }

  Future<void> _verifyNow() async {
    FocusScope.of(context).unfocus();

    final code = _codeCtrl.text.trim();
    _c.setCode(code);

    // ✅ If login OTP: call backend confirm to get REAL full_name + role
    if (widget.purpose == VerifyPurpose.login) {
      try {
        // NOTE: we don't touch controller loading/info/error because your controller
        // doesn't have setLoading/setError/setInfo methods.
        // UI already shows loader from controller during verify(), so we keep it simple.

        final api = ApiClient();
        final json = await api.post(
          '/v1/auth/login/confirm',
          data: {
            'email': widget.email.trim(),
            'code': code,
          },
        );

        final userAny = json['user'];
        final user = (userAny is Map)
            ? Map<String, dynamic>.from(userAny as Map)
            : <String, dynamic>{};

        final fullName = (user['full_name'] ??
                user['fullName'] ??
                user['name'] ??
                '')
            .toString()
            .trim();

        final roleStr = (user['role'] ?? '').toString();
        final realRole = _parseUserRoleFromBackend(roleStr, fallback: widget.role);

        final safeName = fullName.isEmpty ? 'User' : fullName;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PostLoginWelcomeScreen(
              fullName: safeName,
              role: realRole,
            ),
          ),
          (r) => false,
        );
        return;
      } catch (_) {
        // If confirm fails, fall back to your existing controller flow (it will show s.error)
        // so you still get proper error handling UI.
      }
    }

    // ✅ Default: keep your old working controller verify flow
    final ok = await _c.verify();
    if (!mounted || !ok) return;

    // ✅ REGISTER EMAIL VERIFY -> show "Account created ✅" then Go to Login
    if (widget.purpose == VerifyPurpose.emailVerify) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => AccountCreatedScreen(email: widget.email),
        ),
        (r) => false,
      );
      return;
    }

    // ✅ Otherwise keep your current flow
    final safeName =
        widget.fullName.trim().isEmpty ? 'User' : widget.fullName.trim();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => PostLoginWelcomeScreen(
          fullName: safeName,
          role: widget.role,
        ),
      ),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final VerifyEmailState s = _c.state;

    final textMuted = AppColors.textMuted(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBarCentered(
                  title: 'Verify code',
                  disabled: s.disabled,
                  onBack: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ✅ Removed: "Verify your email"
                Text(
                  _subtitle,
                  style: AppTypography.body(context).copyWith(color: textMuted),
                ),

                const SizedBox(height: AppSpacing.lg),

                if (s.error != null) ...[
                  _Banner(text: s.error!, icon: Icons.error_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (s.info != null) ...[
                  _Banner(
                    text: s.info!,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                _GlassCard(
                  child: Column(
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          color: AppColors.surface(context).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          border: Border.all(
                            color: AppColors.border(context).withValues(alpha: 0.70),
                          ),
                        ),
                        child: Icon(
                          Icons.mail_outline_rounded,
                          size: 44,
                          color: AppColors.textSecondary(context),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _CodeField(
                        controller: _codeCtrl,
                        enabled: !s.disabled,
                        errorText: null,
                        onChanged: (v) => _c.setCode(v),
                        onSubmitted: (_) => _verifyNow(),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _PrimaryButton(
                        text: (widget.purpose == VerifyPurpose.login)
                            ? 'Confirm'
                            : 'Verify',
                        loading: s.loading,
                        onPressed: s.loading ? null : _verifyNow,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      TextButton(
                        onPressed: s.disabled ? null : _c.resend,
                        child: Text(
                          s.sending ? 'Sending...' : 'Resend code',
                          style: AppTypography.body(context).copyWith(
                            color: AppColors.brandBlueSoft,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed:
                            s.disabled ? null : () => Navigator.of(context).pop(),
                        child: Text(
                          'Change email',
                          style: AppTypography.body(context).copyWith(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBarCentered extends StatelessWidget {
  const _TopBarCentered({
    required this.title,
    required this.onBack,
    required this.disabled,
  });

  final String title;
  final VoidCallback onBack;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: disabled ? null : onBack,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Text(
            title,
            style: AppTypography.h3(context).copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface(context).withValues(alpha: 0.85);
    final border = AppColors.border(context).withValues(alpha: 0.70);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary(context)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(context).copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface2(context).withValues(alpha: 0.70);
    final border = AppColors.border(context).withValues(alpha: 0.60);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border),
        boxShadow: AppShadows.card(context),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.enabled,
    this.errorText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.surface(context).withValues(alpha: 0.85);
    final border = AppColors.border(context);

    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      maxLength: 6,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textAlign: TextAlign.center,
      style: AppTypography.h3(context).copyWith(
        color: AppColors.textPrimary(context),
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: fill,
        hintText: '••••••',
        hintStyle: AppTypography.h3(context).copyWith(
          color: AppColors.textMuted(context),
          fontWeight: FontWeight.w800,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: border.withValues(alpha: 0.70)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(
            color: AppColors.brandBlueSoft,
            width: 1.4,
          ),
        ),
        errorText: errorText,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    required this.loading,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.brandGreenDeep.withValues(alpha: 0.95);
    final fg = AppColors.textLight;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                text,
                style: AppTypography.button(context).copyWith(
                  color: fg,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}