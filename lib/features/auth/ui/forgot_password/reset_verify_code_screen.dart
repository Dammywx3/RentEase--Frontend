// lib/features/auth/ui/forgot_password/reset_verify_code_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/features/auth/data/auth_di.dart';

import 'reset_verify_code_controller.dart';
import 'reset_verify_code_state.dart';

class ResetVerifyCodeScreen extends StatefulWidget {
  const ResetVerifyCodeScreen({super.key, required this.email});
  final String email;

  @override
  State<ResetVerifyCodeScreen> createState() => _ResetVerifyCodeScreenState();
}

class _ResetVerifyCodeScreenState extends State<ResetVerifyCodeScreen> {
  late final ResetVerifyCodeController _c;

  // ✅ Local banners (so we don't need _c.setError)
  String? _localError;
  String? _localInfo;

  @override
  void initState() {
    super.initState();
    _c = ResetVerifyCodeController(email: widget.email)..addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_onChanged);
    _c.dispose();
    super.dispose();
  }

  void _clearLocalBanners() {
    if (_localError != null || _localInfo != null) {
      setState(() {
        _localError = null;
        _localInfo = null;
      });
    }
  }

  String _prettyErr(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

  Future<void> _goNext() async {
    FocusScope.of(context).unfocus();

    _clearLocalBanners();

    // Validate code locally first (uses your controller)
    final code = _c.getValidCodeOrNull();
    if (code == null) return;

    try {
      // ✅ verify reset code -> returns resetToken
      final result = await AuthDI.authRepo.verifyPasswordResetCode(
        email: _c.state.email,
        code: code,
      );

      if (!mounted) return;

      Navigator.of(context).pushNamed(
        AppRoutes.resetNewPassword,
        arguments: {
          'email': _c.state.email,
          'resetToken': result.resetToken,
        },
      );
    } catch (e) {
      if (!mounted) return;
      final msg = _prettyErr(e);
      setState(() {
        _localError = msg.isEmpty ? 'Invalid code. Try again.' : msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ResetVerifyCodeState s = _c.state;

    final textPrimary = AppColors.textPrimary(context);
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
                // ✅ No brand: back + centered screen name
                _TopBarCentered(
                  title: 'Verify code',
                  disabled: s.disabled,
                  onBack: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Enter reset code',
                  style: AppTypography.h1(context).copyWith(color: textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'We sent a 6-digit code to\n${s.email}',
                  style: AppTypography.body(context).copyWith(color: textMuted),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ✅ Show local/controller banners
                if (_localError != null) ...[
                  _Banner(text: _localError!, icon: Icons.error_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (_localInfo != null) ...[
                  _Banner(text: _localInfo!, icon: Icons.check_circle_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (s.error != null) ...[
                  _Banner(text: s.error!, icon: Icons.error_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (s.info != null) ...[
                  _Banner(text: s.info!, icon: Icons.check_circle_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],

                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _c.codeCtrl,
                        focusNode: _c.codeFocus,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        enabled: !s.disabled,
                        onChanged: (v) {
                          _clearLocalBanners();
                          _c.setCode(v);
                        },
                        onSubmitted: (_) => _goNext(),
                        style: AppTypography.h3(context).copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.surface(context).withValues(alpha: 0.85),
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
                            borderSide: BorderSide(color: AppColors.border(context)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            borderSide: BorderSide(
                              color: AppColors.border(context).withValues(alpha: 0.70),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            borderSide: const BorderSide(
                              color: AppColors.brandBlueSoft,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Row(
                        children: [
                          TextButton(
                            onPressed: s.disabled
                                ? null
                                : () async {
                                    _clearLocalBanners();
                                    await _c.resend();
                                    if (!mounted) return;
                                    setState(() {
                                      _localInfo = 'Code sent.';
                                    });
                                  },
                            child: Text(
                              s.sending ? 'Sending...' : 'Resend code',
                              style: AppTypography.body(context).copyWith(
                                color: AppColors.brandBlueSoft,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: s.disabled ? null : () => Navigator.of(context).pop(),
                            child: Text(
                              'Change email',
                              style: AppTypography.body(context).copyWith(
                                color: AppColors.textMuted(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      _PrimaryButton(
                        text: 'Continue',
                        loading: s.loading,
                        onPressed: s.disabled ? null : _goNext,
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

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface2(context).withValues(alpha: 0.70);
    final border = AppColors.border(context).withValues(alpha: 0.60);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border),
        boxShadow: AppShadows.card(context),
      ),
      child: child,
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