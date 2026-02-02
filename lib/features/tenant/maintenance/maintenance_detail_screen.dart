// lib/features/tenant/maintenance/maintenance_detail_screen.dart
import 'package:flutter/material.dart';

import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/status_badge.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({
    super.key,
    required this.requestId,
    required this.status,
    this.title,
    this.category,
    this.dateLabel,
    this.address,
    this.priority,
    this.description,
    this.permissionToEnter,
  });

  final String requestId;
  final String status;

  final String? title;
  final String? category;
  final String? dateLabel;
  final String? address;
  final String? priority;
  final String? description;
  final bool? permissionToEnter;

  bool get _canCancel => status.trim().toLowerCase() == 'open';

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final safeTitle = (title ?? 'Maintenance Request').trim();
    final safeAddr = (address ?? '').trim();

    final safeCategory = (category ?? '').trim();
    final safeDate = (dateLabel ?? '').trim();
    final safePriority = (priority ?? '').trim();
    final safeDesc = (description ?? '—').trim();

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: AppTopBar(
          title: safeTitle,
          subtitle: safeAddr.isEmpty ? null : safeAddr,
          leadingIcon: Icons.arrow_back_rounded,
          onLeadingTap: () => Navigator.of(context).maybePop(),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH, // Standard horizontal spacing
            AppSpacing.sm,
            AppSpacing.screenH, // Standard horizontal spacing
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row (chips + badge)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        if (safeCategory.isNotEmpty)
                          _MetaChip(
                            icon: Icons.category_rounded,
                            text: safeCategory,
                          ),
                        if (safeDate.isNotEmpty)
                          _MetaChip(
                            icon: Icons.event_rounded,
                            text: safeDate,
                          ),
                        if (safePriority.isNotEmpty)
                          _MetaChip(
                            icon: Icons.flag_rounded,
                            text: safePriority,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(
                    domain: StatusDomain.maintenance,
                    status: status,
                    compact: false,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Photos Placeholder
              _FrostCard(
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library_rounded,
                          color: AppColors.textMuted(context),
                          size: 32,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No photos attached',
                          style: t.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              const _SectionTitle('Description'),
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    safeDesc,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              const _SectionTitle('Status timeline'),
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _Timeline(status: status),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              const _SectionTitle('Visit / access'),
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _kv(
                    context,
                    'Permission to enter if not home',
                    (permissionToEnter ?? false) ? 'Yes' : 'No',
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(
                    child: _SecondaryPillButton(
                      text: 'Chat',
                      icon: Icons.chat_bubble_outline_rounded,
                      onTap: () => ToastService.show(
                        context,
                        'Chat/call landlord/agent (wire later)',
                        success: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SecondaryPillButton(
                      text: 'Call',
                      icon: Icons.call_rounded,
                      onTap: () => ToastService.show(
                        context,
                        'Call (wire later)',
                        success: true,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              _PrimaryButton(
                text: _canCancel ? 'Cancel Request' : 'Update Request',
                onPressed:
                    _canCancel ? () => _confirmCancel(context) : null, // or update logic
                isDestructive: _canCancel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel request?'),
        content: const Text('This will stop the maintenance process.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ToastService.show(context, 'Request cancelled', success: true);
              Navigator.of(context).pop();
            },
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted(context),
                ),
          ),
        ),
        const SizedBox(width: AppSpacing.s10),
        Text(
          v,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary(context),
              ),
        ),
      ],
    );
  }
}

/* ---------------- UI Components ---------------- */

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
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
    // Standard Explore logic
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaShadow = AppSpacing.xs / AppSpacing.xxxl;

    return Material(
      color: AppColors.surface(context).withValues(alpha: alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        width: double.infinity,
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
        child: child,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
    final muted = AppColors.textMuted(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          color: AppColors.surface(context).withValues(alpha: alphaSurface),
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: muted),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final String status;

  int get _stepIndex {
    final keys = StatusBadgeMap.timelineStatuses(StatusDomain.maintenance);
    final s = status.trim().toLowerCase();
    final idx = keys.indexOf(s);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final keys = StatusBadgeMap.timelineStatuses(StatusDomain.maintenance);

    if (keys.isEmpty) {
      return Text(
        '—',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textMuted(context),
            ),
      );
    }

    final current = status.trim().toLowerCase();
    final currentIdx = _stepIndex;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(keys.length, (i) {
        final raw = keys[i];
        final label = StatusBadgeMap.labelFor(StatusDomain.maintenance, raw);

        final done =
            i <= currentIdx && raw != 'cancelled' && current != 'cancelled';
        final isCancelled = current == 'cancelled';

        // Colors
        final alphaBg = AppSpacing.lg / (AppSpacing.xxxl + AppSpacing.lg);
        final activeColor = isCancelled
            ? AppColors.danger
            : (done ? AppColors.brandGreen : AppColors.textMuted(context));

        final bg = activeColor.withValues(alpha: done ? alphaBg : 0.1);
        final border = activeColor.withValues(alpha: 0.2);
        final textC =
            done ? AppColors.textPrimary(context) : AppColors.textMuted(context);

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            color: bg,
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textC,
                ),
          ),
        );
      }),
    );
  }
}

class _SecondaryPillButton extends StatelessWidget {
  const _SecondaryPillButton({
    required this.text,
    required this.onTap,
    this.icon,
  });

  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    
    return Material(
      color: AppColors.surface(context).withValues(alpha: alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          height: AppSizes.pillButtonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: AppColors.overlay(context, 0.15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textPrimary(context)),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.danger : AppColors.brandGreenDeep;
    
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.95),
          foregroundColor: AppColors.textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg), // Rounded rect for primary actions
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}