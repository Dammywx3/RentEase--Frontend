import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

import 'package:rentease_frontend/app/router/app_router.dart';

// ✅ correct relative path (register -> welcome)
import '../../welcome/post_login_welcome_screen.dart';

// NEW: purpose
import 'verify_purpose.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.role,
    required this.fullName,

    // NEW: why are we verifying?
    this.purpose = VerifyPurpose.register,

    // ✅ remove HomeStead hardcode
    this.brandName = 'RentEase',
    this.brandIcon = Icons.home_rounded,
  });

  final String email;
  final UserRole role;
  final String fullName;

  final VerifyPurpose purpose;

  final String brandName;
  final IconData brandIcon;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _validate() {
    final v = _codeCtrl.text.trim();
    setState(() {
      _error = v.length == 6 ? null : 'Enter the 6-digit code.';
    });
  }

  Future<void> _verify() async {
    _validate();
    if (_error != null) return;

    setState(() => _loading = true);

    try {
      // TODO:
      // - if purpose == register: verify email code for new account
      // - if purpose == login: verify login OTP code
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      // ✅ routing based on purpose
      if (widget.purpose == VerifyPurpose.register) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PostLoginWelcomeScreen(
              fullName: widget.fullName.trim().isEmpty ? 'User' : widget.fullName.trim(),
              role: widget.role,
            ),
          ),
          (r) => false,
        );
        return;
      }

      // purpose == login
      // after OTP, go to correct shell
      final target = switch (widget.role) {
        UserRole.tenant => AppRoutes.tenant,
        UserRole.agent => AppRoutes.agent,
        UserRole.landlord => AppRoutes.landlord,
      };

      Navigator.of(context).pushNamedAndRemoveUntil(target, (r) => false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _subtitle {
    if (widget.purpose == VerifyPurpose.login) {
      return 'We sent a 6-digit code to\n${widget.email}';
    }
    return 'We sent a verification code to\n${widget.email}';
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

                // ✅ Clean top row: back + perfectly centered brand
                SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _loading ? null : () => Navigator.of(context).pop(),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Verify your email',
                    style: AppTypography.h1(context).copyWith(color: textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _subtitle,
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
                          Icons.mail_outline_rounded,
                          size: 44,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _CodeField(
                        controller: _codeCtrl,
                        errorText: _error,
                        onChanged: (_) => _validate(),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      _PrimaryButton(
                        text: 'Verify',
                        loading: _loading,
                        onPressed: _loading ? null : _verify,
                      ),

                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Resend code (todo)')),
                                );
                              },
                        child: Text(
                          'Resend code',
                          style: AppTypography.body(context).copyWith(
                            color: AppColors.brandBlueSoft,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _loading ? null : () => Navigator.of(context).pop(),
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

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.surface(context).withValues(alpha: 0.85);
    final border = AppColors.border(context);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      onChanged: onChanged,
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
          borderSide: BorderSide(color: AppColors.brandBlueSoft, width: 1.4),
        ),
        errorText: errorText,
      ),
      textAlign: TextAlign.center,
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