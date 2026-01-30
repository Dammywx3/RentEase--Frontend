import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/constants/status_badge_map.dart';

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
  });

  final String requestId;
  final String status;

  // Optional extras (safe defaults)
  final String? title;
  final String? category;
  final String? dateLabel;
  final String? address;
  final String? priority;

  bool get _canCancel {
    // Allow cancel only if still open (you can extend to allow in_progress too)
    return status == 'open';
  }

  List<_Step> _stepsForStatus() {
    // Submitted → Assigned → Scheduled → In progress → Completed
    int idx = 0;
    if (status == 'open') idx = 0;
    if (status == 'in_progress') idx = 3;
    if (status == 'resolved') idx = 4;
    if (status == 'rejected') idx = 0;

    final steps = const [
      _Step('Submitted'),
      _Step('Assigned'),
      _Step('Scheduled'),
      _Step('In Progress'),
      _Step('Completed'),
    ];

    return List.generate(steps.length, (i) {
      final done = i < idx;
      final active = i == idx && status != 'rejected';
      return _Step(steps[i].label, done: done, active: active);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = title ?? 'Maintenance Request';
    final cat = category ?? 'Other';
    final when = dateLabel ?? '—';
    final where = address ?? '—';
    final pr = priority ?? 'Normal';

    final isRejected = status == 'rejected';

    return AppScaffold(
      topBar: AppTopBar(title: t, subtitle: cat),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top meta row
          Row(
            children: [
              Expanded(
                child: Text(
                  where,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withValues(alpha: 0.60),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              StatusBadge(domain: StatusDomain.maintenance, status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              _MetaChip(icon: Icons.event_rounded, text: when),
              const SizedBox(width: AppSpacing.sm),
              _MetaChip(icon: Icons.flag_rounded, text: pr),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Photo section (optional)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _H('Photos'),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.75),
                    alignment: Alignment.center,
                    child: Text(
                      'Photo preview (wire later)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _H('Description'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Pipe under kitchen sink is leaking and causing water damage. Need it repaired asap. (demo)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _H('Status'),
                const SizedBox(height: AppSpacing.sm),
                if (isRejected)
                  Text(
                    'This request was rejected. (wire reason later)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.85),
                    ),
                  )
                else
                  _Timeline(steps: _stepsForStatus()),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Appointment: Not scheduled (demo)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          if (_canCancel)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final ok = await DialogService.confirm(
                    context,
                    title: 'Cancel request?',
                    message: 'This will stop the maintenance process.',
                    confirmText: 'Cancel request',
                    danger: true,
                  );
                  if (ok && context.mounted) {
                    ToastService.show(
                      context,
                      'Cancelled (demo)',
                      success: true,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Cancel Request'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => ToastService.show(
                  context,
                  'Chat/Call landlord/agent (wire later)',
                  success: true,
                ),
                child: const Text('Contact landlord/agent'),
              ),
            ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/* ---------------- UI helpers ---------------- */

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

class _H extends StatelessWidget {
  const _H(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black.withValues(alpha: 0.60)),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _Step {
  const _Step(this.label, {this.done = false, this.active = false});
  final String label;
  final bool done;
  final bool active;
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.steps});
  final List<_Step> steps;

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    final muted = Colors.black.withValues(alpha: 0.25);

    return Column(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final dotColor = s.done || s.active ? activeColor : muted;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                height: 18,
                width: 18,
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: s.done ? 0.95 : 0.20),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: dotColor.withValues(alpha: 0.55)),
                ),
                child: s.done
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withValues(
                      alpha: s.done || s.active ? 0.90 : 0.55,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
