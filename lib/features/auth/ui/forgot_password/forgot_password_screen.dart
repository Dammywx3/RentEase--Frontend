// lib/features/auth/ui/forgot_password/forgot_password_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

import 'forgot_password_controller.dart';
import 'forgot_password_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.prefillEmail});
  final String? prefillEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordController _c;

  @override
  void initState() {
    super.initState();
    _c = ForgotPasswordController(prefillEmail: widget.prefillEmail ?? '')
      ..addListener(_onChanged);
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

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();

    final ok = await _c.sendResetCode();
    if (!mounted || !ok) return;

    Navigator.of(context).pushNamed(
      AppRoutes.resetVerifyCode,
      arguments: {'email': _c.emailCtrl.text.trim()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordState s = _c.state;

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
                // ✅ Top bar: back + centered "Forgot password" (no brand)
                _TopBar(
                  title: 'Forgot password',
                  disabled: s.loading,
                  onBack: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ✅ Only this line (no "Reset your password")
                Text(
                  'Enter your email and we’ll send you a 6-digit code.',
                  style: AppTypography.body(context).copyWith(color: textMuted),
                ),

                const SizedBox(height: AppSpacing.lg),

                // banners
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email address',
                        style: AppTypography.label(context).copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      _Field(
                        controller: _c.emailCtrl,
                        focusNode: _c.emailFocus,
                        hint: 'jane.doe@email.com',
                        keyboardType: TextInputType.emailAddress,
                        enabled: !s.loading,
                        prefixIcon: Icons.mail_outline_rounded,
                        textInputAction: TextInputAction.done,
                        onChanged: _c.setEmail,
                        onSubmitted: (_) => _sendCode(),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _PrimaryButton(
                        text: s.loading ? 'Sending...' : 'Send reset code',
                        loading: s.loading,
                        onPressed: s.loading ? null : _sendCode,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Center(
                        child: TextButton(
                          onPressed:
                              s.loading ? null : () => Navigator.of(context).pop(),
                          child: Text(
                            'Back to sign in',
                            style: AppTypography.body(context).copyWith(
                              color: AppColors.textMuted(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
    required this.disabled,
  });

  final String title;
  final VoidCallback onBack;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);

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
              color: textPrimary,
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.enabled = true,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.surface(context).withValues(alpha: 0.85);
    final border = AppColors.border(context);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
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
        hintText: hint,
        hintStyle: AppTypography.body(context).copyWith(
          color: AppColors.textMuted(context),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: AppColors.textMuted(context)),
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