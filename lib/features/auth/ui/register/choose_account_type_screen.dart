// lib/features/auth/ui/register/choose_account_type_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_sizes.dart';

import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';
import 'register_screen.dart';

class ChooseAccountTypeScreen extends StatefulWidget {
  const ChooseAccountTypeScreen({super.key});

  @override
  State<ChooseAccountTypeScreen> createState() =>
      _ChooseAccountTypeScreenState();
}

class _ChooseAccountTypeScreenState extends State<ChooseAccountTypeScreen> {
  UserRole? _selected = UserRole.tenant;

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  void _continue() {
    final role = _selected;
    if (role == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: AppSpacing.sm),

                _TopBarCentered(
                  title: 'Choose account type',
                  onBack: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.xl),

                _RoleCard(
                  role: UserRole.tenant,
                  selected: _selected == UserRole.tenant,
                  onTap: () => setState(() => _selected = UserRole.tenant),
                  alphaSurface: _alphaSurfaceStrong,
                  alphaBorder: _alphaBorderSoft,
                ),
                const SizedBox(height: AppSpacing.md),
                _RoleCard(
                  role: UserRole.agent,
                  selected: _selected == UserRole.agent,
                  onTap: () => setState(() => _selected = UserRole.agent),
                  alphaSurface: _alphaSurfaceStrong,
                  alphaBorder: _alphaBorderSoft,
                ),
                const SizedBox(height: AppSpacing.md),
                _RoleCard(
                  role: UserRole.landlord,
                  selected: _selected == UserRole.landlord,
                  onTap: () => setState(() => _selected = UserRole.landlord),
                  alphaSurface: _alphaSurfaceStrong,
                  alphaBorder: _alphaBorderSoft,
                ),

                const SizedBox(height: AppSpacing.lg),
                _PrimaryButton(
                  text: 'Continue',
                  onPressed: _selected == null ? null : _continue,
                ),
                const SizedBox(height: AppSpacing.md),

                Text(
                  'You can change this later (admin may review).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted(context),
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
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
   UI COMPONENTS
   -------------------------------------------------------------------------- */

class _TopBarCentered extends StatelessWidget {
  const _TopBarCentered({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

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
              onTap: onBack,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textSecondary(context),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
    required this.alphaSurface,
    required this.alphaBorder,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;
  final double alphaSurface;
  final double alphaBorder;

  @override
  Widget build(BuildContext context) {
    // Selection styling
    final selectedBorderColor = AppColors.brandBlueSoft;
    final selectedBgTint = AppColors.brandBlueSoft.withValues(alpha: 0.08);

    final bg = selected
        ? AppColors.surface(context).withValues(alpha: alphaSurface + 0.1)
        : AppColors.surface(context).withValues(alpha: alphaSurface);

    final borderColor = selected
        ? selectedBorderColor
        : AppColors.overlay(context, alphaBorder);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(
            color: borderColor,
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: AppSpacing.xs / AppSpacing.xxxl,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 78,
              decoration: BoxDecoration(
                color: AppColors.surface(context).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: AppColors.overlay(context, alphaBorder),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.lg - 2),
                child: _RoleAssetIcon(role: role),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    role.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: selected ? selectedBgTint : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? selectedBorderColor
                      : AppColors.overlay(context, alphaBorder),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: selectedBorderColor,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleAssetIcon extends StatelessWidget {
  const _RoleAssetIcon({required this.role});
  final UserRole role;

  String _assetForRole() {
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox.expand(
        child: Image.asset(
          _assetForRole(),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Center(
              child: Icon(
                _fallbackIcon(),
                size: 34,
                color: AppColors.textSecondary(context),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled
              ? AppColors.overlay(context, 0.1)
              : AppColors.brandGreenDeep.withValues(alpha: 0.95),
          foregroundColor: AppColors.textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
        child: Text(
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
    );
  }
}