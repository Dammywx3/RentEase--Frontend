import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/status_badge.dart';

class ViewingDetailScreen extends StatelessWidget {
  const ViewingDetailScreen({
    super.key,
    required this.viewingId,
    required this.title,
    required this.status,
  });

  final String viewingId;
  final String title;
  final String status;

  bool get canApproveReject => status == 'pending';
  bool get canReschedule => status == 'pending' || status == 'approved';
  bool get canComplete => status == 'approved';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Viewing Detail',
        subtitle: 'Actions depend on status',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.viewing, status: status),
          const SizedBox(height: AppSpacing.lg),

          const Text(
            'Info (demo)\n• Mode: In-person\n• Requested: Jan 25 • 2:00 PM\n• Notes: Please call on arrival',
          ),
          const SizedBox(height: AppSpacing.lg),

          if (canApproveReject) ...[
            PrimaryButton(
              label: 'Approve',
              onPressed: () =>
                  ToastService.show(context, 'Approved (demo)', success: true),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Reject',
              onPressed: () async {
                final ok = await DialogService.confirm(
                  context,
                  title: 'Reject viewing?',
                  message: 'Reason required in real flow.',
                  confirmText: 'Reject',
                  danger: true,
                );
                if (ok && context.mounted) {
                  ToastService.show(context, 'Rejected (demo)', success: true);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          OutlinedButton.icon(
            onPressed: canReschedule
                ? () => ToastService.show(
                    context,
                    'Reschedule proposal (demo)',
                    success: true,
                  )
                : null,
            icon: const Icon(Icons.schedule_rounded),
            label: Text(canReschedule ? 'Reschedule' : 'Reschedule (disabled)'),
          ),
          const SizedBox(height: AppSpacing.md),

          OutlinedButton.icon(
            onPressed: canComplete
                ? () => ToastService.show(
                    context,
                    'Marked completed (demo)',
                    success: true,
                  )
                : null,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              canComplete ? 'Mark completed' : 'Mark completed (disabled)',
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          OutlinedButton.icon(
            onPressed: () async {
              final ok = await DialogService.confirm(
                context,
                title: 'Cancel viewing?',
                message: 'This will notify the tenant.',
                confirmText: 'Cancel',
                danger: true,
              );
              if (ok && context.mounted) {
                ToastService.show(context, 'Cancelled (demo)', success: true);
              }
            },
            icon: const Icon(Icons.cancel_rounded),
            label: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
