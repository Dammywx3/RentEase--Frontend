import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key, required this.appId, required this.title, required this.status});

  final String appId;
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    return AppScaffold(
      topBar: const AppTopBar(title: 'Application Detail', subtitle: 'Docs + timeline'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          Text('Status: $status'),
          const SizedBox(height: AppSpacing.lg),

          Text('Documents', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => ToastService.show(context, 'Open doc (demo)', success: true),
            icon: const Icon(Icons.description_rounded),
            label: const Text('ID Card'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => ToastService.show(context, 'Open doc (demo)', success: true),
            icon: const Icon(Icons.description_rounded),
            label: const Text('Proof of income'),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (s == 'pending') ...[
            PrimaryButton(
              label: 'Approve',
              onPressed: () => ToastService.show(context, 'Approved (demo)', success: true),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Reject',
              onPressed: () async {
                final ok = await DialogService.confirm(
                  context,
                  title: 'Reject application?',
                  message: 'Reason is required in real flow.',
                  confirmText: 'Reject',
                  danger: true,
                );
                if (ok && context.mounted) ToastService.show(context, 'Rejected (demo)', success: true);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => ToastService.show(context, 'Request more info (demo)', success: true),
              icon: const Icon(Icons.mark_chat_unread_rounded),
              label: const Text('Request more info'),
            ),
          ] else ...[
            PrimaryButton(
              label: 'Send deposit/rent request',
              onPressed: () => ToastService.show(context, 'Pushed to payments (demo)', success: true),
            ),
          ],
        ],
      ),
    );
  }
}
