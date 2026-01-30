import 'package:flutter/material.dart';

import '../../core/constants/status_badge_map.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.domain,
    required this.status,
    this.compact = false,
  });

  final StatusDomain domain;
  final String status;
  final bool compact;

  double _bgAlpha(bool isDark) {
    // token-only: light slightly softer, dark slightly stronger
    return isDark
        ? (AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm)) // 8/40 = 0.20
        : (AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.sm)); // 4/40 = 0.10
  }

  double _borderAlpha(bool isDark) {
    return isDark
        ? (AppSpacing.lg / (AppSpacing.xxxl + AppSpacing.lg)) // 16/48 = 0.33
        : (AppSpacing.md / (AppSpacing.xxxl + AppSpacing.lg)); // 12/48 = 0.25
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final spec = StatusBadgeMap.forStatus(domain, status);

    final bgA = _bgAlpha(isDark);
    final borderA = _borderAlpha(isDark);

    Color fg;
    Color bg;

    switch (spec.tone) {
      case BadgeTone.success:
        fg = AppColors.brandGreen;
        bg = fg.withValues(alpha: bgA);
        break;
      case BadgeTone.warning:
        fg = AppColors.brandOrange;
        bg = fg.withValues(alpha: bgA);
        break;
      case BadgeTone.danger:
        fg = AppColors.danger;
        bg = fg.withValues(alpha: bgA);
        break;
      case BadgeTone.info:
        fg = isDark ? AppColors.brandBlueSoft : AppColors.brandBlue;
        bg = fg.withValues(alpha: bgA);
        break;
      case BadgeTone.neutral:
        fg = AppColors.textMuted(context);
        bg = fg.withValues(alpha: bgA);
        break;
    }

    final padH = compact ? AppSpacing.sm : AppSpacing.md;
    final padV = compact ? AppSpacing.s6 : AppSpacing.sm;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: fg.withValues(alpha: borderA)),
      ),
      child: Text(
        spec.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
          letterSpacing: AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs), // token-only
        ),
      ),
    );
  }
}