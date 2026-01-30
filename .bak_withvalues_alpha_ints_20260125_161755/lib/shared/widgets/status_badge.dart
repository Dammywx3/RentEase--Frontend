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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final spec = StatusBadgeMap.forStatus(domain, status);

    Color bg;
    Color fg;

    switch (spec.tone) {
      case BadgeTone.success:
        bg = (isDark ? AppColors.brandGreen : AppColors.brandGreen).withAlpha(
          isDark ? 40 : 28,
        );
        fg = AppColors.brandGreen;
        break;
      case BadgeTone.warning:
        bg = (isDark ? AppColors.brandOrange : AppColors.brandOrange).withAlpha(
          isDark ? 45 : 28,
        );
        fg = AppColors.brandOrange;
        break;
      case BadgeTone.danger:
        bg = (isDark ? AppColors.danger : AppColors.danger).withAlpha(
          isDark ? 45 : 26,
        );
        fg = AppColors.danger;
        break;
      case BadgeTone.info:
        bg = (isDark ? AppColors.brandBlueSoft : AppColors.brandBlue).withAlpha(
          isDark ? 40 : 22,
        );
        fg = isDark ? AppColors.brandBlueSoft : AppColors.brandBlue;
        break;
      case BadgeTone.neutral:
        bg = (isDark ? AppColors.textMutedLight : AppColors.textMutedDark)
            .withAlpha(isDark ? 28 : 18);
        fg = isDark ? AppColors.textMutedLight : AppColors.textMutedDark;
        break;
    }

    final padH = compact ? AppSpacing.sm : AppSpacing.md;
    final padV = compact ? 6.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: fg.withAlpha(isDark ? 80 : 60)),
      ),
      child: Text(
        spec.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
