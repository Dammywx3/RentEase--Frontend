// lib/features/auth/welcome/post_login_welcome_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_sizes.dart';

import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';
import 'package:rentease_frontend/features/auth/ui/register/choose_account_type_screen.dart';

class PostLoginWelcomeScreen extends StatelessWidget {
  const PostLoginWelcomeScreen({
    super.key,
    required this.fullName,
    required this.role,
    this.lastLogin,
  });

  final String fullName;
  final UserRole role;
  final DateTime? lastLogin;

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  void _go(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(role.toRoute());
  }

  String _greeting(DateTime now) {
    final h = now.hour;
    if (h >= 5 && h < 12) return 'Good morning';
    if (h >= 12 && h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(String name) {
    final n = name.trim();
    if (n.isEmpty) return 'User';
    final parts = n.split(RegExp(r'\s+'));
    return parts.isEmpty ? 'User' : parts.first;
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);
    final textMuted = AppColors.textMuted(context);

    final now = lastLogin ?? DateTime.now();
    final timeText =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final nameToShow = _firstName(fullName);
    final greet = _greeting(now);

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
              children: [
                const SizedBox(height: AppSpacing.md),

                Text(
                  '$greet, $nameToShow 👋',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        fontSize: 24, // Explicit size override
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  role.welcomeLine,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textMuted,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                _FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        _RolePill(role: role),
                        const SizedBox(height: AppSpacing.md),

                        Text(
                          role.welcomeLine,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface(context)
                                .withValues(alpha: _alphaSurfaceStrong),
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                            border: Border.all(
                              color: AppColors.overlay(
                                  context, _alphaBorderSoft),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                            child: _RoleImage(role: role),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        _PrimaryButton(
                          text: (role == UserRole.tenant)
                              ? 'Explore'
                              : role.primaryCta,
                          onPressed: () => _go(context),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChooseAccountTypeScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Switch account type',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary(context),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          height: 1,
                          width: double.infinity,
                          color: AppColors.divider(context)
                              .withValues(alpha: 0.70),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Text(
                          'Last login: Today $timeText',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
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

class _RoleImage extends StatelessWidget {
  const _RoleImage({required this.role});
  final UserRole role;

  String _roleAsset() {
    switch (role) {
      case UserRole.tenant:
        return 'assets/images/tenant.png';
      case UserRole.agent:
        return 'assets/images/agent.png';
      case UserRole.landlord:
        return 'assets/images/landlord.png';
      case UserRole.admin:
        return 'assets/images/admin.png';
    }
  }

  IconData _fallbackIcon() {
    switch (role) {
      case UserRole.tenant:
        return Icons.key_rounded;
      case UserRole.agent:
        return Icons.apartment_rounded;
      case UserRole.landlord:
        return Icons.assignment_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        _roleAsset(),
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) {
          return Center(
            child: Icon(
              _fallbackIcon(),
              size: 54,
              color: AppColors.textSecondary(context),
            ),
          );
        },
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    // Matches Verified pill style in Explore
    final alphaSurface = AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.pill), // Pill shape
        border: Border.all(
          color: AppColors.overlay(context, AppSpacing.xs / AppSpacing.xxxl),
        ),
      ),
      child: Text(
        role.pillLabel.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
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
        child: child,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed});

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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
              ),
        ),
      ),
    );
  }
}