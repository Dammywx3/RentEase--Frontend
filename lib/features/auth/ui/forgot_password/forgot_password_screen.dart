// lib/features/auth/ui/forgot_password/forgot_password_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_sizes.dart';

import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';

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

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

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

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: null,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH, // Standard Horizontal Padding
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(
                  title: 'Forgot password',
                  disabled: s.loading,
                  onBack: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Enter your email and we’ll send you a 6-digit code.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textMuted,
                        fontWeight: FontWeight.w700,
                      ),
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

                // --- Main Frost Card ---
                _FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email address',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        _Field(
                          controller: _c.emailCtrl,
                          focusNode: _c.emailFocus,
                          hint: 'damilare.vic@email.com',
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
                            onPressed: s.loading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(
                              'Back to sign in',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textMuted(context),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

/* --------------------------------------------------------------------------
   UI COMPONENTS (Matched to Design System)
   -------------------------------------------------------------------------- */

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
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: disabled ? null : onBack,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Matches Explore/Login logic
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaShadow = AppSpacing.xs / AppSpacing.xxxl;

    return Material(
      color: AppColors.surface(context).withValues(alpha: alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: alphaShadow,
          ),
        ),
        child: child,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.04), // Subtle input background
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, 0.08)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
        cursorColor: AppColors.brandGreenDeep,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted(context).withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
          prefixIcon: prefixIcon == null
              ? null
              : Icon(
                  prefixIcon,
                  color: AppColors.textMuted(context),
                  size: 20,
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
    final disabled = loading || onPressed == null;

    return Material(
      color: disabled
          ? AppColors.overlay(context, 0.1)
          : AppColors.brandGreenDeep.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: Center(
            child: loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.textLight,
                    ),
                  )
                : Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: disabled
                              ? AppColors.textMuted(context)
                              : AppColors.textLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}