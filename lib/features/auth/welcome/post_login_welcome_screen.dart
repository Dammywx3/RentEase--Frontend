import 'package:flutter/material.dart';

import '../../../core/constants/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

// ✅ correct relative path: welcome/ -> ui/register/
import '../ui/register/choose_account_type_screen.dart';

class PostLoginWelcomeScreen extends StatelessWidget {
  const PostLoginWelcomeScreen({
    super.key,
    required this.fullName,
    required this.role,
    this.lastLogin,
    this.brandName = 'RentEase',
    this.brandIcon = Icons.home_rounded,
  });

  final String fullName;
  final UserRole role;
  final DateTime? lastLogin;

  // ✅ brand (remove HomeStead hardcode)
  final String brandName;
  final IconData brandIcon;

  void _go(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(role.toRoute());
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);
    final textMuted = AppColors.textMuted(context);

    final now = lastLogin ?? DateTime.now();
    final timeText =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
                _BrandMark(name: brandName, icon: brandIcon),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Welcome, ${_firstName(fullName)} 👋',
                  style: AppTypography.h1(context).copyWith(color: textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  role.welcomeLine,
                  style: AppTypography.body(context).copyWith(color: textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                _GlassCard(
                  child: Column(
                    children: [
                      _RolePill(role: role),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        role.welcomeLine,
                        style: AppTypography.h3(context).copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ✅ Role image card (PNG) — now fills the card
                      Container(
  height: 150,
  width: double.infinity,
  decoration: BoxDecoration(
    color: AppColors.surface(context).withValues(alpha: 0.70),
    borderRadius: BorderRadius.circular(AppRadii.xl),
    border: Border.all(
      color: AppColors.border(context).withValues(alpha: 0.70),
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(AppRadii.xl),
    child: _RoleImage(role: role),
  ),
),

                      const SizedBox(height: AppSpacing.lg),
                      _PrimaryButton(
                        text: role.primaryCta,
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
                          style: AppTypography.body(context).copyWith(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: AppColors.divider(context).withValues(alpha: 0.70),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Last login: Today $timeText',
                        style: AppTypography.caption(context).copyWith(
                          color: AppColors.textMuted(context),
                          fontWeight: FontWeight.w700,
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

  static String _firstName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? 'Michael' : parts.first;
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.name, required this.icon});
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.brandGreen, size: 26),
        const SizedBox(width: AppSpacing.sm),
        Text(
          name,
          style: AppTypography.h3(context).copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RoleImage extends StatelessWidget {
  const _RoleImage({required this.role});
  final UserRole role;

  String _roleAsset() {
    // ✅ Change this to assets/image/... if your folder is singular.
    switch (role) {
      case UserRole.tenant:
        return 'assets/images/tenant.png';
      case UserRole.agent:
        return 'assets/images/agent.png';
      case UserRole.landlord:
        return 'assets/images/landlord.png';
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
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fill the entire card
    return SizedBox.expand(
      child: Image.asset(
        _roleAsset(),
        fit: BoxFit.contain, // fills the box (may crop a little)
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) {
          // ✅ fallback so you never get a red screen
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
    final border = AppColors.border(context).withValues(alpha: 0.70);
    final bg = AppColors.surface(context).withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border),
      ),
      child: Text(
        role.pillLabel,
        style: AppTypography.caption(context).copyWith(
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
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