import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

import 'register_screen.dart';

class ChooseAccountTypeScreen extends StatefulWidget {
  const ChooseAccountTypeScreen({super.key});

  @override
  State<ChooseAccountTypeScreen> createState() =>
      _ChooseAccountTypeScreenState();
}

class _ChooseAccountTypeScreenState extends State<ChooseAccountTypeScreen> {
  UserRole? _selected = UserRole.tenant;

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

                // ✅ back + centered screen name (no brand)
                _TopBarCentered(
                  title: 'Choose account type',
                  onBack: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.xl),

                _RoleCard(
                  role: UserRole.tenant,
                  selected: _selected == UserRole.tenant,
                  onTap: () => setState(() => _selected = UserRole.tenant),
                ),
                const SizedBox(height: AppSpacing.md),
                _RoleCard(
                  role: UserRole.agent,
                  selected: _selected == UserRole.agent,
                  onTap: () => setState(() => _selected = UserRole.agent),
                ),
                const SizedBox(height: AppSpacing.md),
                _RoleCard(
                  role: UserRole.landlord,
                  selected: _selected == UserRole.landlord,
                  onTap: () => setState(() => _selected = UserRole.landlord),
                ),

                const SizedBox(height: AppSpacing.lg),
                _PrimaryButton(
                  text: 'Continue',
                  onPressed: _selected == null ? null : _continue,
                ),
                const SizedBox(height: AppSpacing.md),

                Text(
                  'You can change this later (admin may review).',
                  style: AppTypography.caption(context).copyWith(
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
            child: IconButton(
              onPressed: onBack,
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface2(context).withValues(alpha: 0.70);
    final baseBorder = AppColors.border(context).withValues(alpha: 0.60);

    final selectedBorder = AppColors.brandBlueSoft.withValues(alpha: 0.75);
    final selectedTint = AppColors.overlay(context, 0.06);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? bg.withValues(alpha: 0.78) : bg,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: selected ? selectedBorder : baseBorder),
          boxShadow: AppShadows.card(context),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 78,
              decoration: BoxDecoration(
                color: AppColors.surface(context).withValues(alpha: 0.80),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: baseBorder),
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
                    style: AppTypography.h3(context).copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    role.description,
                    style: AppTypography.body(context).copyWith(
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
                color: selected ? selectedTint : AppColors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? selectedBorder : baseBorder,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AppColors.textPrimary(context),
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