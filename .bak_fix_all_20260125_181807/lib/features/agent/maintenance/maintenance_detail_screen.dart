import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/bottom_sheet_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({
    super.key,
    required this.requestId,
    required this.status,
  });

  final String requestId;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Request Detail',
        subtitle: 'Assign contractor & updates',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket #$requestId',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.maintenance, status: status),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: 'Assign contractor',
            onPressed: () => ToastService.show(
              context,
              'Assign contractor (demo)',
              success: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _openStatus(context),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Change status'),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _Item('open', 'Request received'),
          const _Item('in_progress', 'Assigned to contractor'),
          const _Item('resolved', 'Issue fixed (demo)'),
        ],
      ),
    );
  }

  void _openStatus(BuildContext context) {
    BottomSheetService.show(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set status',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.md),
          _Btn('open', () => _set(context, 'open')),
          _Btn('in_progress', () => _set(context, 'in_progress')),
          _Btn('on_hold', () => _set(context, 'on_hold')),
          _Btn('resolved', () => _set(context, 'resolved')),
          _Btn('cancelled', () => _set(context, 'cancelled')),
        ],
      ),
    );
  }

  void _set(BuildContext context, String s) {
    Navigator.of(context).pop();
    ToastService.show(context, 'Status → $s (demo)', success: true);
  }
}

class _Btn extends StatelessWidget {
  const _Btn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(onPressed: onTap, child: Text(label)),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.title, this.body);
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fiber_manual_record_rounded, size: 14),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
