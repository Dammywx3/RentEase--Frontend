// lib/features/auth/ui/forgot_password/reset_verify_code_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_sizes.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/features/auth/data/auth_di.dart';
import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';

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

  String? _localError;
  String? _localInfo;

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
    _c = ResetVerifyCodeController(email: widget.email)
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

    final code = _c.getValidCodeOrNull();
    if (code == null) return;

    try {
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
                _TopBarCentered(
                  title: 'Verify code',
                  disabled: s.disabled,
                  onBack: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Enter reset code',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'We sent a 6-digit code to\n${s.email}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),

                if (_localError != null) ...[
                  _Banner(
                      text: _localError!, icon: Icons.error_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (_localInfo != null) ...[
                  _Banner(
                      text: _localInfo!,
                      icon: Icons.check_circle_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (s.error != null) ...[
                  _Banner(text: s.error!, icon: Icons.error_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (s.info != null) ...[
                  _Banner(
                      text: s.info!, icon: Icons.check_circle_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],

                // --- Main Frost Card ---
                _FrostCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CodeField(
                        controller: _c.codeCtrl,
                        focusNode: _c.codeFocus,
                        enabled: !s.disabled,
                        onChanged: (v) {
                          _clearLocalBanners();
                          _c.setCode(v);
                        },
                        onSubmitted: (_) => _goNext(),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.brandBlueSoft,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: s.disabled
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(
                              'Change email',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textMuted(context),
                                    fontWeight: FontWeight.w900,
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

/* --------------------------------------------------------------------------
   UI COMPONENTS (Matched to Design System)
   -------------------------------------------------------------------------- */

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
    // Matches Explore logic
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
        padding: const EdgeInsets.all(AppSpacing.lg),
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

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.04),
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, 0.08)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: TextInputType.number,
        maxLength: 6,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
              letterSpacing: 8.0, // Space out the code digits
            ),
        cursorColor: AppColors.brandGreenDeep,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          hintText: '••••••',
          hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textMuted(context).withValues(alpha: 0.3),
                fontWeight: FontWeight.w900,
                letterSpacing: 8.0,
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