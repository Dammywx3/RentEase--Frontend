import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/constants/status_badge_map.dart';

import '../../../core/theme/app_colors.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';

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
  final String
  status; // open / in_progress / resolved / rejected (match your badge map)
  final String? title;
  final String? category;
  final String? dateLabel;
  final String? address;
  final String? priority;
  final String? description;
  final bool? permissionToEnter;

  bool get _canCancel => status == 'open';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final safeTitle = (title ?? 'Maintenance Request').trim();
    final safeCategory = (category ?? 'Other').trim();
    final safeDate = (dateLabel ?? '—').trim();
    final safeAddr = (address ?? '—').trim();
    final safePriority = (priority ?? 'Normal').trim();
    final safeDesc =
        (description ??
                'Describe what is wrong (wire to backend later). Photos and scheduling will appear here once connected.')
            .trim();

    return AppScaffold(
      topBar: AppTopBar(title: safeTitle, subtitle: safeAddr),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    runSpacing: 6,
                    children: [
                      _MetaChip(
                        icon: Icons.category_rounded,
                        text: safeCategory,
                      ),
                      _MetaChip(icon: Icons.event_rounded, text: safeDate),
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

            // Photo area (safe height -> no overflow)
            Container(
              height: 210,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: t.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                border: Border.all(color: AppColors.overlay(context, 0.06)),
              ),
              child: Center(
                child: Text(
                  'Photo(s) (wire later)',
                  style: t.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('Description'),
            _Card(child: Text(safeDesc, style: t.textTheme.bodyMedium)),

            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('Status timeline'),
            _Card(child: _Timeline(status: status)),

            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('Visit / access'),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv(
                    'Appointment',
                    status == 'in_progress'
                        ? 'Scheduled (demo)'
                        : 'Not scheduled',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _kv(
                    'Permission to enter if not home',
                    (permissionToEnter ?? false) ? 'Yes' : 'No',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Optional actions
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

            if (_canCancel)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => _confirmCancel(context),
                  child: const Text('Cancel Request'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: null,
                  child: Text(
                    status == 'resolved'
                        ? 'Completed'
                        : status == 'rejected'
                        ? 'Rejected'
                        : 'In Progress',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel request?'),
        content: const Text('This will stop the maintenance process (demo).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ToastService.show(
                context,
                'Request cancelled (demo)',
                success: true,
              );
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
          child: Text(k, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 10),
        Text(v),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: child,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final muted = t.textTheme.bodySmall?.color?.withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: muted),
          const SizedBox(width: 6),
          Text(
            text,
            style: t.textTheme.bodySmall?.copyWith(
              color: muted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final String status;

  int get _step {
    if (status == 'open') return 0;
    if (status == 'in_progress') return 3;
    if (status == 'resolved') return 4;
    if (status == 'rejected') return 0; // show early state
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final labels = const [
      'Submitted',
      'Assigned',
      'Scheduled',
      'In progress',
      'Completed',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(labels.length, (i) {
            final done = i <= _step && status != 'rejected';
            final isRejected = status == 'rejected';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isRejected
                    ? Colors.redAccent.withValues(alpha: 0.10)
                    : done
                    ? Colors.green.withValues(alpha: 0.12)
                    : t.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                border: Border.all(
                  color: isRejected
                      ? Colors.redAccent.withValues(alpha: 0.35)
                      : done
                      ? Colors.green.withValues(alpha: 0.25)
                      : AppColors.overlay(context, 0.06),
                ),
              ),
              child: Text(
                labels[i],
                style: t.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          }),
        ),
        if (status == 'rejected') ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Rejected (demo)',
            style: t.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
            ),
          ),
        ],
      ],
    );
  }
}
