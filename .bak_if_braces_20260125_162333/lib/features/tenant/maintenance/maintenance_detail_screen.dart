import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
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

  bool get canCancel =>
      status == 'open' || status == 'in_progress' || status == 'on_hold';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Request Detail',
        subtitle: 'Timeline & updates',
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

          Text(
            'Updates',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _UpdateItem('Open', 'We received your request.'),
          const _UpdateItem('In progress', 'Assigned to a technician (demo).'),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: 'Add update',
            onPressed: () => ToastService.show(
              context,
              'Add update modal (demo)',
              success: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: canCancel
                ? () async {
                    final ok = await DialogService.confirm(
                      context,
                      title: 'Cancel request?',
                      message: 'This will stop the maintenance process.',
                      confirmText: 'Cancel',
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
                  }
                : null,
            icon: const Icon(Icons.cancel_rounded),
            label: Text(canCancel ? 'Cancel request' : 'Cancel (disabled)'),
          ),
        ],
      ),
    );
  }
}

class _UpdateItem extends StatelessWidget {
  const _UpdateItem(this.title, this.body);
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
