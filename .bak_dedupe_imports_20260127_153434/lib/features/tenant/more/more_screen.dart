import "package:flutter/material.dart";

import "../profile/settings_screen.dart";

import "../maintenance/maintenance_screen.dart";
import "../renting_tools/renting_tools_screen.dart";
import "../viewings/viewings_screen.dart";
import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';
import 'package:rentease_frontend/core/ui/scaffold/app_top_bar.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _bgTop = AppColors.lightBg;
  static const _bgBottom = AppColors.mist;
  static const _green = AppColors.brandGreenDeep;
  static const _blue = AppColors.brandBlueSoft;
  static const _muted = AppColors.textMutedLight;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'More'),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopHeader(),
                const SizedBox(height: 14),
                const _ProfileCard(),
                const SizedBox(height: 16),

                _MenuTile(
                  icon: Icons.account_balance_wallet_rounded,
                  iconBg: const Color(0xFFCFDBEA),
                  iconFg: _blue,
                  title: "Payments",
                  onTap: () {},
                ),
                const SizedBox(height: 10),

                _MenuTile(
                  icon: Icons.construction_rounded,
                  iconBg: const Color(0xFFD7E6DD),
                  iconFg: _green,
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
                const SizedBox(height: 10),

                _MenuTile(
                  icon: Icons.event_rounded,
                  iconBg: const Color(0xFFE7E3D1),
                  iconFg: const Color(0xFF6B6B6B),
                  title: "My Viewings",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ViewingsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),

                _MenuTile(
                  icon: Icons.description_rounded,
                  iconBg: const Color(0xFFCFDBEA),
                  iconFg: _blue,
                  title: "Documents",
                  onTap: () {},
                ),
                const SizedBox(height: 10),

                _MenuTile(
                  icon: Icons.build_rounded,
                  iconBg: const Color(0xFFD7E6DD),
                  iconFg: _green,
                  title: "Maintenance",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MaintenanceScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                _MenuTile(
                  icon: Icons.help_outline_rounded,
                  iconBg: const Color(0xFFE7E3D1),
                  iconFg: const Color(0xFF6B6B6B),
                  title: "Support",
                  onTap: () {},
                ),
                const SizedBox(height: 10),

                _MenuTile(
                  icon: Icons.settings_rounded,
                  iconBg: const Color(0xFFD9D9D9),
                  iconFg: const Color(0xFF6B6B6B),
                  title: "Settings",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 18),
                Center(
                  child: Text(
                    "HomeStead v1.0.0",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _muted.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w700,
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

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  static const _green = AppColors.brandGreenDeep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: AppColors.surface(context).withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 8),
                color: AppColors.overlay(context, 0.08),
              ),
            ],
          ),
          child: const Icon(Icons.location_on_rounded, color: _green, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          "HomeStead",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  static const _inactive = AppColors.textMutedLight;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Michael Johnson",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "michael.j@email.com",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _inactive.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: _OutlinePillButton(text: "View Profile  ›", onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
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
    return _FrostCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              _IconChip(icon: icon, bg: iconBg, fg: iconFg),
              const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(
                            0xFF6F7785,
                          ).withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMutedLight.withValues(alpha: 0.75),
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
        borderRadius: BorderRadius.circular(12),
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.surface(context).withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: AppColors.overlay(context, 0.08),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
