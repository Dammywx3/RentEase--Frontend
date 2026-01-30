import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

import 'package:rentease_frontend/app/router/app_router.dart';

class ResetNewPasswordScreen extends StatefulWidget {
  const ResetNewPasswordScreen({
    super.key,
    required this.email,
    this.brandName = 'RentEase',
    this.brandIcon = Icons.home_rounded,
  });

  final String email;
  final String brandName;
  final IconData brandIcon;

  @override
  State<ResetNewPasswordScreen> createState() => _ResetNewPasswordScreenState();
}

class _ResetNewPasswordScreenState extends State<ResetNewPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  bool _success = false;

  String? _passError;
  String? _confirmError;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _ruleLen => _passCtrl.text.trim().length >= 8;
  bool get _ruleNumber => RegExp(r'[0-9]').hasMatch(_passCtrl.text);
  bool get _ruleUpper => RegExp(r'[A-Z]').hasMatch(_passCtrl.text);
  bool get _ruleSymbol => RegExp(r'[^A-Za-z0-9]').hasMatch(_passCtrl.text);

  void _validate() {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    setState(() {
      _passError = pass.isEmpty
          ? 'Enter a new password.'
          : (!_ruleLen ? 'Use at least 8 characters.' : null);

      _confirmError = confirm.isEmpty
          ? 'Confirm your password.'
          : (confirm != pass ? 'Passwords do not match.' : null);
    });
  }

  Future<void> _reset() async {
    _validate();
    if (_passError != null || _confirmError != null) return;

    setState(() => _loading = true);
    try {
      // TODO: backend reset password: POST /auth/reset-password {email, newPassword, codeToken}
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      setState(() => _success = true);
    } finally {
      if (mounted) setState(() => _loading = false);
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
              children: [
                const SizedBox(height: AppSpacing.sm),

                SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: (_loading || _success) ? null : () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                      _BrandMarkSmall(
                        name: widget.brandName,
                        icon: widget.brandIcon,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                if (_success) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password updated',
                      style: AppTypography.h1(context).copyWith(color: textPrimary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your password has been updated successfully.',
                      style: AppTypography.body(context).copyWith(color: textMuted),
                    ),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Create new password',
                      style: AppTypography.h1(context).copyWith(color: textPrimary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Set a new password for\n${widget.email}',
                      style: AppTypography.body(context).copyWith(color: textMuted),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

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
                          hintText: '••••••••',
                          obscureText: _obscure,
                          enabled: !_loading,
                          errorText: _passError,
                          onChanged: (_) => _validate(),
                          suffixIcon: _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          onSuffixTap: () => setState(() => _obscure = !_obscure),
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
                          hintText: '••••••••',
                          obscureText: _obscure,
                          enabled: !_loading,
                          errorText: _confirmError,
                          onChanged: (_) => _validate(),
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        _PrimaryButton(
                          text: 'Reset password',
                          loading: _loading,
                          onPressed: _loading ? null : _reset,
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

class _BrandMarkSmall extends StatelessWidget {
  const _BrandMarkSmall({required this.name, required this.icon});
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.brandGreen, size: 22),
        const SizedBox(width: AppSpacing.xs),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.h4(context).copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.obscureText = true,
    this.enabled = true,
    this.errorText,
    this.suffixIcon,
    this.onSuffixTap,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  final bool obscureText;
  final bool enabled;
  final String? errorText;

  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.surface(context).withValues(alpha: 0.85);
    final border = AppColors.border(context);

    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      onChanged: onChanged,
      style: AppTypography.body(context).copyWith(
        color: AppColors.textPrimary(context),
        fontWeight: FontWeight.w700,
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
          borderSide: BorderSide(color: AppColors.brandBlueSoft, width: 1.4),
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
    final c = ok ? AppColors.brandGreen : muted.withValues(alpha: 0.9);
    return Row(
      children: [
        Icon(ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 18, color: c),
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