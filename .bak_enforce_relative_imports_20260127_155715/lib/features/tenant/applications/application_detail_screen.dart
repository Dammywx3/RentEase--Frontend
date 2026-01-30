import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/constants/status_badge_map.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({
    super.key,
    required this.appId,
    required this.title,
    required this.status,
  });

  final String appId;
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Application Detail',
        subtitle: 'Review timeline & actions',
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
          StatusBadge(domain: StatusDomain.purchaseStatus, status: status),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _TimelineItem(
            title: 'Submitted',
            subtitle: 'Your application was submitted',
          ),
          _TimelineItem(title: 'Status', subtitle: 'Current: $status'),
          const SizedBox(height: AppSpacing.lg),

          if (s == 'approved') ...[
            PrimaryButton(
              label: 'Pay Deposit',
              onPressed: () => ToastService.show(
                context,
                'Push to Payments (wire later)',
                success: true,
              ),
            ),
          ] else if (s == 'pending') ...[
            PrimaryButton(
              label: 'Withdraw',
              onPressed: () async {
                final ok = await DialogService.confirm(
                  context,
                  title: 'Withdraw application?',
                  message: 'This action cannot be undone.',
                  confirmText: 'Withdraw',
                  danger: true,
                );
                if (ok && context.mounted) {
                  ToastService.show(context, 'Withdrawn (demo)', success: true);
                  Navigator.of(context).pop();
                }
              },
            ),
          ] else if (s == 'rejected') ...[
            PrimaryButton(
              label: 'Browse similar',
              onPressed: () => ToastService.show(
                context,
                'Browse similar (demo)',
                success: true,
              ),
            ),
          ] else ...[
            PrimaryButton(
              label: 'Message',
              onPressed: () => ToastService.show(
                context,
                'Message (Phase 2)',
                success: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 18),
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
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
