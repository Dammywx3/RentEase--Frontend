import 'package:flutter/material.dart';

import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../status_badge.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.title,
    required this.location,
    required this.priceText,
    required this.status,
    this.meta,
    this.onTap,
    this.primaryActionText,
    this.onPrimaryAction,
  });

  final String title;
  final String location;
  final String priceText;
  final String status;
  final String? meta;
  final VoidCallback? onTap;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;

  double _alphaSurfaceStrong() =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs); // 32/36
  double _alphaBorderSoft() =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs); // 4/36
  double _alphaShadowSoft() => AppSpacing.xs / AppSpacing.xxxl; // 4/32

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface(
            context,
          ).withValues(alpha: _alphaSurfaceStrong()),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: AppColors.overlay(context, _alphaBorderSoft()),
          ),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: _alphaShadowSoft(),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(
                  domain: StatusDomain.listing,
                  status: status,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _MetaLine(icon: Icons.location_on_rounded, text: location),
            const SizedBox(height: AppSpacing.xs),
            _MetaLine(icon: Icons.payments_rounded, text: priceText),
            if (meta != null && meta!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              _MetaLine(icon: Icons.info_outline_rounded, text: meta!),
            ],
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
    final muted = AppColors.textMuted(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: muted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: muted,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
