// lib/features/auth/ui/forgot_password/reset_new_password_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/features/auth/data/auth_di.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

class ResetNewPasswordScreen extends StatefulWidget {
  const ResetNewPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  final String email;
  final String resetToken;

  @override
  State<ResetNewPasswordScreen> createState() => _ResetNewPasswordScreenState();
}

class _ResetNewPasswordScreenState extends State<ResetNewPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscure1 = true;
  bool _obscure2 = true;

  bool _loading = false;
  bool _success = false;

  String? _bannerError;
  String? _bannerInfo;

  // Field-level errors (to show under inputs)
  String? _passError;
  String? _confirmError;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // Rules (for checklist UI)
  bool get _ruleLen => _passCtrl.text.trim().length >= 8;
  bool get _ruleNumber => RegExp(r'[0-9]').hasMatch(_passCtrl.text);
  bool get _ruleUpper => RegExp(r'[A-Z]').hasMatch(_passCtrl.text);
  bool get _ruleSymbol => RegExp(r'[^A-Za-z0-9]').hasMatch(_passCtrl.text);

  void _clearBanners() {
    if (_bannerError != null || _bannerInfo != null) {
      setState(() {
        _bannerError = null;
        _bannerInfo = null;
      });
    }
  }

  void _validate() {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    setState(() {
      _passError = pass.trim().isEmpty
          ? 'Enter a new password.'
          : (!_ruleLen ? 'Use at least 8 characters.' : null);

      _confirmError = confirm.trim().isEmpty
          ? 'Confirm your password.'
          : (confirm != pass ? 'Passwords do not match.' : null);
    });
  }

  String _prettyErr(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

  Future<void> _submit() async {
    _validate();
    if (_passError != null || _confirmError != null) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _bannerError = null;
      _bannerInfo = null;
    });

    try {
      await AuthDI.authRepo.resetPasswordWithResetToken(
        email: widget.email,
        resetToken: widget.resetToken,
        newPassword: _passCtrl.text,
      );

      if (!mounted) return;

      setState(() {
        _success = true;
        _bannerInfo = 'Password updated successfully.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bannerError = _prettyErr(e).isEmpty ? 'Unable to update password.' : _prettyErr(e);
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
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
                // ✅ Top bar: back + centered title (NO brand)
                _TopBarCentered(
                  title: _success ? 'Password updated' : 'New password',
                  disabled: _loading,
                  onBack: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.xl),

                if (_bannerError != null) ...[
                  _Banner(text: _bannerError!, icon: Icons.error_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (_bannerInfo != null && !_success) ...[
                  _Banner(text: _bannerInfo!, icon: Icons.check_circle_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],

                if (_success) ...[
                  Text(
                    'Password updated',
                    style: AppTypography.h1(context).copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your password has been updated successfully.',
                    style: AppTypography.body(context).copyWith(color: textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
                            Icons.check_circle_outline_rounded,
                            size: 44,
                            color: AppColors.brandGreen,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _PrimaryButton(
                          text: 'Go to Sign in',
                          loading: false,
                          onPressed: _goToLogin,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    'Set a new password',
                    style: AppTypography.h1(context).copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Create a strong password for\n${widget.email}',
                    style: AppTypography.body(context).copyWith(color: textMuted),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New password',
                          style: AppTypography.label(context).copyWith(color: textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _PasswordField(
                          controller: _passCtrl,
                          focusNode: _passFocus,
                          enabled: !_loading,
                          hintText: 'Minimum 8 characters',
                          obscureText: _obscure1,
                          errorText: _passError,
                          textInputAction: TextInputAction.next,
                          suffixIcon: _obscure1
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onSuffixTap: _loading
                              ? null
                              : () => setState(() => _obscure1 = !_obscure1),
                          onChanged: (_) {
                            _clearBanners();
                            _validate();
                          },
                          onSubmitted: (_) => _confirmFocus.requestFocus(),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _RulesChecklist(
                          lenOk: _ruleLen,
                          numOk: _ruleNumber,
                          upperOk: _ruleUpper,
                          symbolOk: _ruleSymbol,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          'Confirm password',
                          style: AppTypography.label(context).copyWith(color: textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _PasswordField(
                          controller: _confirmCtrl,
                          focusNode: _confirmFocus,
                          enabled: !_loading,
                          hintText: 'Re-enter password',
                          obscureText: _obscure2,
                          errorText: _confirmError,
                          textInputAction: TextInputAction.done,
                          suffixIcon: _obscure2
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onSuffixTap: _loading
                              ? null
                              : () => setState(() => _obscure2 = !_obscure2),
                          onChanged: (_) {
                            _clearBanners();
                            _validate();
                          },
                          onSubmitted: (_) => _submit(),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        _PrimaryButton(
                          text: _loading ? 'Updating...' : 'Update password',
                          loading: _loading,
                          onPressed: _loading ? null : _submit,
                        ),

                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed: _loading ? null : _goToLogin,
                            child: Text(
                              'Back to Sign in',
                              style: AppTypography.body(context).copyWith(
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
    this.obscureText = true,
    this.errorText,
    this.suffixIcon,
    this.onSuffixTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;

  final ValueChanged<String> onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  final bool enabled;
  final bool obscureText;
  final String? errorText;

  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.surface(context).withValues(alpha: 0.85);
    final border = AppColors.border(context);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: AppTypography.body(context).copyWith(
        color: AppColors.textPrimary(context),
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        hintText: hintText,
        hintStyle: AppTypography.body(context).copyWith(
          color: AppColors.textMuted(context),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textMuted(context)),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                onPressed: onSuffixTap,
                icon: Icon(suffixIcon, color: AppColors.textMuted(context)),
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

class _RulesChecklist extends StatelessWidget {
  const _RulesChecklist({
    required this.lenOk,
    required this.numOk,
    required this.upperOk,
    required this.symbolOk,
  });

  final bool lenOk;
  final bool numOk;
  final bool upperOk;
  final bool symbolOk;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RuleRow(ok: lenOk, text: 'At least 8 characters', muted: muted),
        const SizedBox(height: 6),
        _RuleRow(ok: numOk, text: 'Contains a number', muted: muted),
        const SizedBox(height: 6),
        _RuleRow(ok: upperOk, text: 'Contains an uppercase letter', muted: muted),
        const SizedBox(height: 6),
        _RuleRow(ok: symbolOk, text: 'Contains a symbol', muted: muted),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.ok, required this.text, required this.muted});

  final bool ok;
  final String text;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final c = ok ? AppColors.brandGreen : muted.withValues(alpha: 0.92);

    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 18,
          color: c,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption(context).copyWith(
              color: c,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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