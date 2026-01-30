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
  final String status; // open / in_progress / on_hold / resolved / cancelled

  final String? title;
  final String? category;
  final String? dateLabel;
  final String? address;
  final String? priority;
  final String? description;
  final bool? permissionToEnter;

  bool get _canCancel => status.trim().toLowerCase() == 'open';

  double get _surfaceA => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _borderA => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final safeTitle = (title ?? 'Maintenance Request').trim();
    final safeAddr = (address ?? '').trim();

    final safeCategory = (category ?? '').trim();
    final safeDate = (dateLabel ?? '').trim();
    final safePriority = (priority ?? '').trim();
    final safeDesc = (description ?? '—').trim();

    return Stack(
      children: [
        // ✅ Fix: gradient behind the entire screen (safe-area + top bar)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.pageBgGradient(context),
            ),
          ),
        ),
        AppScaffold(
          backgroundColor: Colors.transparent,
          safeAreaTop: true,
          safeAreaBottom: false,
          topBar: AppTopBar(
            title: safeTitle,
            subtitle: safeAddr.isEmpty ? null : safeAddr,
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
            actions: const [],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
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
                            _MetaChip(icon: Icons.category_rounded, text: safeCategory),
                          if (safeDate.isNotEmpty)
                            _MetaChip(icon: Icons.event_rounded, text: safeDate),
                          if (safePriority.isNotEmpty)
                            _MetaChip(icon: Icons.flag_rounded, text: safePriority),
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

                // Photos
                Container(
                  height: AppSizes.listThumbSize + AppSpacing.xxxl + AppSpacing.lg,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    color: AppColors.surface(context).withValues(alpha: _surfaceA),
                    border: Border.all(color: AppColors.overlay(context, _borderA)),
                    boxShadow: AppShadows.soft(
                      context,
                      blur: AppSpacing.xxxl,
                      y: AppSpacing.lg,
                      alpha: AppSpacing.xs / AppSpacing.xxxl,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Photos',
                      style: t.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                const _SectionTitle('Description'),
                _Card(child: Text(safeDesc, style: t.textTheme.bodyMedium)),

                const SizedBox(height: AppSpacing.lg),

                const _SectionTitle('Status timeline'),
                _Card(child: _Timeline(status: status)),

                const SizedBox(height: AppSpacing.lg),

                const _SectionTitle('Visit / access'),
                _Card(
                  child: _kv(
                    'Permission to enter if not home',
                    (permissionToEnter ?? false) ? 'Yes' : 'No',
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ToastService.show(
                          context,
                          'Chat/call landlord/agent (wire later)',
                          success: true,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Chat'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ToastService.show(
                          context,
                          'Call (wire later)',
                          success: true,
                        ),
                        icon: const Icon(Icons.call_rounded),
                        label: const Text('Call'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                SizedBox(
                  width: double.infinity,
                  height: AppSizes.pillButtonHeight + AppSpacing.sm,
                  child: FilledButton(
                    onPressed: _canCancel ? () => _confirmCancel(context) : null,
                    child: Text(_canCancel ? 'Cancel Request' : 'Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _kv(String k, String v) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: AppSpacing.s10),
        Text(v),
      ],
    );
  }
}

/* ---------------- UI ---------------- */

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Text(
        text,
        style: t.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  double get _surfaceA => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _borderA => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        color: AppColors.surface(context).withValues(alpha: _surfaceA),
        border: Border.all(color: AppColors.overlay(context, _borderA)),
      ),
      child: child,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  double get _surfaceA => AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md);
  double get _borderA => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240), // ✅ hard stop prevents overflow
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s7,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          color: AppColors.surface(context).withValues(alpha: _surfaceA),
          border: Border.all(color: AppColors.overlay(context, _borderA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpacing.xl, color: muted),
            const SizedBox(width: AppSpacing.s6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w900,
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
    final t = Theme.of(context);
    final keys = StatusBadgeMap.timelineStatuses(StatusDomain.maintenance);

    if (keys.isEmpty) {
      return Text(
        '—',
        style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
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

        final done = i <= currentIdx && raw != 'cancelled' && current != 'cancelled';
        final isCancelled = current == 'cancelled';

        final bg = isCancelled
            ? AppColors.textMuted(context).withValues(alpha: 0.18)
            : done
                ? AppColors.brandGreen.withValues(alpha: 0.18)
                : AppColors.surface(context).withValues(alpha: 0.18);

        final border = isCancelled
            ? AppColors.textMuted(context).withValues(alpha: 0.22)
            : done
                ? AppColors.brandGreen.withValues(alpha: 0.22)
                : AppColors.overlay(context, 0.10);

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260), // ✅ prevents overflow
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              color: bg,
              border: Border.all(color: border),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        );
      }),
    );
  }
}