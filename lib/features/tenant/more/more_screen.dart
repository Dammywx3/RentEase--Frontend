import "package:flutter/material.dart";

import "../profile/settings_screen.dart";
import "../maintenance/maintenance_screen.dart";
import "../renting_tools/renting_tools_screen.dart";

// ✅ ADD: Payment Hub import (tenant/more -> tenant/payments)
import "../payments/payments_hub_screen.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_sizes.dart";

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    this.userName = "Michael Johnson",
    this.userEmail = "michael.j@email.com",
    this.versionText = "v1.0.0",
    this.screenTitle = "More",
  });

  /// You can later pass real data from your auth/user state
  final String userName;
  final String userEmail;
  final String versionText;

  /// ✅ Only the screen name is allowed in the AppTopBar
  final String screenTitle;

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.transparent,
      safeAreaTop: true,
      safeAreaBottom: false,

      topBar: AppTopBar(title: screenTitle, centerTitle: true),

      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.s10,
            AppSpacing.screenV,
            AppSizes.screenBottomPad,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileCard(
                name: userName,
                email: userEmail,
                onViewProfile: () => _toast(context, "Profile (wire later)"),
              ),

              const SizedBox(height: AppSpacing.lg),

              _MenuSection(
                children: [
                  // ✅ FIX: Payments -> Payment Hub and navigate
                  _MenuRow(
                    icon: Icons.account_balance_wallet_rounded,
                    iconBg: AppColors.tenantPanel,
                    iconFg: AppColors.brandBlueSoft,
                    title: "Payment Hub",
                    subtitle: "Wallet • Methods • Transactions",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaymentHubScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuRow(
                    icon: Icons.construction_rounded,
                    iconBg: AppColors.tenantIconBgGreen,
                    iconFg: AppColors.brandGreenDeep,
                    title: "Renting Tools",
                    subtitle: "Tenancies • Applications • Viewings",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RentingToolsScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuRow(
                    icon: Icons.description_rounded,
                    iconBg: AppColors.tenantPanel,
                    iconFg: AppColors.brandBlueSoft,
                    title: "Documents",
                    onTap: () => _toast(context, "Documents (wire later)"),
                  ),
                  _MenuRow(
                    icon: Icons.build_rounded,
                    iconBg: AppColors.tenantIconBgGreen,
                    iconFg: AppColors.brandGreenDeep,
                    title: "Maintenance",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MaintenanceScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuRow(
                    icon: Icons.help_outline_rounded,
                    iconBg: AppColors.tenantIconBgSand,
                    iconFg: AppColors.tenantGray600,
                    title: "Support",
                    onTap: () => _toast(context, "Support (wire later)"),
                  ),
                  _MenuRow(
                    icon: Icons.settings_rounded,
                    iconBg: AppColors.tenantIconBgGray,
                    iconFg: AppColors.tenantGray600,
                    title: "Settings",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              _MenuSection(
                children: [
                  _MenuRow(
                    icon: Icons.card_giftcard_rounded,
                    iconBg: AppColors.tenantIconBgGreen,
                    iconFg: AppColors.brandGreenDeep,
                    title: "Invite Friends",
                    onTap: () => _toast(context, "Invite Friends (wire later)"),
                  ),
                  _MenuRow(
                    icon: Icons.star_rounded,
                    iconBg: AppColors.tenantIconBgSand,
                    iconFg: AppColors.tenantGray600,
                    title: "Subscription",
                    onTap: () => _toast(context, "Subscription (wire later)"),
                  ),
                  _MenuRow(
                    icon: Icons.description_rounded,
                    iconBg: AppColors.tenantPanel,
                    iconFg: AppColors.brandBlueSoft,
                    title: "Legal",
                    onTap: () => _toast(context, "Legal (wire later)"),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              _MenuSection(
                children: [
                  _MenuRow(
                    icon: Icons.card_giftcard_rounded,
                    iconBg: AppColors.tenantIconBgGreen,
                    iconFg: AppColors.brandGreenDeep,
                    title: "Invite Friends",
                    onTap: () => _toast(context, "Invite Friends (wire later)"),
                  ),
                  _MenuRow(
                    icon: Icons.power_settings_new_rounded,
                    iconBg: AppColors.tenantIconBgSand,
                    iconFg: AppColors.tenantGray600,
                    title: "Account",
                    onTap: () => _toast(context, "Account (wire later)"),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.screenH),

              Center(
                child: Text(
                  versionText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted(context).withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.onViewProfile,
  });

  final String name;
  final String email;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted(context).withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.s10),
            Align(
              alignment: Alignment.centerLeft,
              child: _OutlinePillButton(
                text: "View Profile  ›",
                onTap: onViewProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.children});

  final List<_MenuRow> children;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.overlay(context, 0.06),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              _IconChip(icon: icon, bg: iconBg, fg: iconFg),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted(
                            context,
                          ).withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted(context).withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.bg, required this.fg});

  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: Icon(icon, color: fg, size: 20),
    );
  }
}

class _OutlinePillButton extends StatelessWidget {
  const _OutlinePillButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
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
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: AppColors.surface(context).withValues(alpha: 0.55),
          ),
          boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: child,
        ),
      ),
    );
  }
}
