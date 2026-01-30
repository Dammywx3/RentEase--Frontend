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

  bool get canCancel => status == 'pending' || status == 'approved';
  bool get canReschedule => status == 'pending' || status == 'approved';
  bool get canComplete => status == 'approved';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Viewing Detail', subtitle: 'Actions depend on status'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.viewing, status: status),
          const SizedBox(height: AppSpacing.lg),

          Text('Notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          const Text('This screen is UI-ready. Wire approve/reschedule/cancel to backend endpoints.'),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: canReschedule ? 'Reschedule' : 'Reschedule (disabled)',
            onPressed: canReschedule
                ? () => ToastService.show(context, 'Reschedule flow (demo)', success: true)
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: canCancel ? 'Cancel' : 'Cancel (disabled)',
            onPressed: canCancel
                ? () async {
                    final ok = await DialogService.confirm(
                      context,
                      title: 'Cancel viewing?',
                      message: 'You can request another time later.',
                      confirmText: 'Cancel',
                      danger: true,
                    );
                    if (ok && context.mounted) {
                      ToastService.show(context, 'Cancelled (demo)', success: true);
                      Navigator.of(context).pop();
                    }
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: canComplete ? () => ToastService.show(context, 'Mark completed (demo)', success: true) : null,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(canComplete ? 'Mark completed' : 'Mark completed (disabled)'),
          ),
        ],
      ),
    );
  }
}
