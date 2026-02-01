// lib/features/auth/ui/verify_email/account_created_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

import 'package:rentease_frontend/app/router/app_router.dart';

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({
    super.key,
    required this.email,
  });

  final String email;

  void _goToLogin(BuildContext context) {
    final cleanEmail = email.trim();

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (r) => false,
      arguments: cleanEmail.isEmpty
          ? null
          : <String, dynamic>{
              'email': cleanEmail,
            },
    );
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
                const SizedBox(height: AppSpacing.sm),

                const _TopBarCentered(title: 'Account created'),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Account created ✅',
                  style: AppTypography.h1(context).copyWith(color: textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your email is verified. You can now sign in.',
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
                          size: 46,
                          color: AppColors.brandGreen,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _PrimaryButton(
                        text: 'Go to Login',
                        onPressed: () => _goToLogin(context),
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

class _TopBarCentered extends StatelessWidget {
  const _TopBarCentered({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

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
        child: Text(
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