// lib/features/tenant/more/more_screen.dart
import "package:flutter/material.dart";

import "../profile/settings_screen.dart";
import "../maintenance/maintenance_screen.dart";
import "../renting_tools/renting_tools_screen.dart";
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

  final String userName;
  final String userEmail;
  final String versionText;
  final String screenTitle;

  // ---------- Explore-aligned Alpha Helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        appBar: AppTopBar(
          title: screenTitle,
          subtitle: "Manage your account & tools",
        ),
        scroll: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.sm,
          AppSpacing.screenH,
          AppSizes.screenBottomPad,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileCard(
              name: userName,
              email: userEmail,
              alphaSurface: _alphaSurfaceStrong,
              alphaBorder: _alphaBorderSoft,
              alphaShadow: _alphaShadowSoft,
              onViewProfile: () => _toast(context, "Profile (wire later)"),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              "Tools",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),

            _MenuSection(
              alphaSurface: _alphaSurfaceSoft,
              alphaBorder: _alphaBorderSoft,
              alphaShadow: _alphaShadowSoft,
              children: [
                _MenuRow(
                  icon: Icons.account_balance_wallet_rounded,
                  iconBg: AppColors.brandBlueSoft,
                  // ✅ FIX 1: brandBlueDeep -> brandBlueSoft
                  iconFg: AppColors.brandBlueSoft, 
                  title: "Payment Hub",
                  subtitle: "Wallet • Methods • Transactions",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PaymentHubScreen()),
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
                          builder: (_) => const RentingToolsScreen()),
                    );
                  },
                ),
                _MenuRow(
                  icon: Icons.description_rounded,
                  iconBg: AppColors.brandBlueSoft,
                   // ✅ FIX 1: brandBlueDeep -> brandBlueSoft
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
                          builder: (_) => const MaintenanceScreen()),
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
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            
            Text(
              "General",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),

            _MenuSection(
              alphaSurface: _alphaSurfaceSoft,
              alphaBorder: _alphaBorderSoft,
              alphaShadow: _alphaShadowSoft,
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
                  icon: Icons.gavel_rounded,
                  iconBg: AppColors.brandBlueSoft,
                  // ✅ FIX 1: brandBlueDeep -> brandBlueSoft
                  iconFg: AppColors.brandBlueSoft,
                  title: "Legal",
                  onTap: () => _toast(context, "Legal (wire later)"),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            _MenuSection(
              alphaSurface: _alphaSurfaceSoft,
              alphaBorder: _alphaBorderSoft,
              alphaShadow: _alphaShadowSoft,
              children: [
                _MenuRow(
                  icon: Icons.manage_accounts_rounded,
                  iconBg: AppColors.tenantIconBgGray,
                  iconFg: AppColors.tenantGray600,
                  title: "Account",
                  subtitle: "Security • Profile • KYC",
                  onTap: () => _toast(context, "Account (wire later)"),
                ),
                _MenuRow(
                  icon: Icons.power_settings_new_rounded,
                  iconBg: AppColors.tenantIconBgSand,
                  iconFg: AppColors.tenantGray600,
                  title: "Log out",
                  onTap: () => _toast(context, "Logout (wire later)"),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            Center(
              child: Text(
                versionText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          AppColors.textMuted(context).withValues(alpha: 0.65),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
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
    required this.alphaSurface,
    required this.alphaBorder,
    required this.alphaShadow,
  });

  final String name;
  final String email;
  final VoidCallback onViewProfile;

  final double alphaSurface;
  final double alphaBorder;
  final double alphaShadow;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      alphaSurface: alphaSurface,
      alphaBorder: alphaBorder,
      alphaShadow: alphaShadow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  // ✅ FIX 2: AppSizes.s44 -> AppSpacing.s44
                  height: AppSpacing.s44,
                  width: AppSpacing.s44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandGreenDeep.withValues(alpha: 0.1),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.brandGreenDeep),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary(context),
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted(context)
                                  .withValues(alpha: 0.85),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: _OutlinePillButton(
                text: "View Profile",
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
  const _MenuSection({
    required this.children,
    required this.alphaSurface,
    required this.alphaBorder,
    required this.alphaShadow,
  });

  final List<_MenuRow> children;
  final double alphaSurface;
  final double alphaBorder;
  final double alphaShadow;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      alphaSurface: alphaSurface,
      alphaBorder: alphaBorder,
      alphaShadow: alphaShadow,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted(context)
                                  .withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted(context).withValues(alpha: 0.5),
                size: AppSpacing.lg,
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
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

    return Container(
      height: AppSizes.iconButtonBox,
      width: AppSizes.iconButtonBox, 
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: Icon(icon, color: fg, size: AppSpacing.lg),
    );
  }
}

class _OutlinePillButton extends StatelessWidget {
  const _OutlinePillButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alphaSurface =
        AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder =
        AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return Material(
      color: AppColors.surface(context).withValues(alpha: alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.overlay(context, alphaBorder)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
      ),
    );
  }
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({
    required this.child,
    required this.alphaSurface,
    required this.alphaBorder,
    required this.alphaShadow,
  });

  final Widget child;
  final double alphaSurface;
  final double alphaBorder;
  final double alphaShadow;

  @override
  Widget build(BuildContext context) {
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: child,
        ),
      ),
    );
  }
}