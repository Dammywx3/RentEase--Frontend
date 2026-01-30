import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../status_badge.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.propertyTitle,
    required this.submittedDateText,
    required this.status,
    this.onTap,
    this.primaryActionText,
    this.onPrimaryAction,
  });

  final String propertyTitle;
  final String submittedDateText;
  final String status;
  final VoidCallback? onTap;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: isDark ? AppShadows.softDark : AppShadows.softLight,
          border: Border.all(
            color: (isDark ? AppColors.dividerDark : AppColors.dividerLight).withAlpha(190),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    propertyTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(domain: StatusDomain.purchaseStatus, status: status, compact: true),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _MetaLine(icon: Icons.calendar_month_rounded, text: 'Submitted: $submittedDateText'),

            if (primaryActionText != null && onPrimaryAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: onPrimaryAction,
                  child: Text(primaryActionText!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.color?.withAlpha(190);

    return Row(
      children: [
        Icon(icon, size: 18, color: muted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
