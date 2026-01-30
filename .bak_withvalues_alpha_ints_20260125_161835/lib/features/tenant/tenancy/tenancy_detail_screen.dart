import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

class TenancyDetailScreen extends StatelessWidget {
  const TenancyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Tenancy Detail',
        subtitle: 'Timeline & actions',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lease Documents',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => ToastService.show(
              context,
              'Open lease PDF (demo)',
              success: true,
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('Lease Agreement.pdf'),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'End Tenancy',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Request end tenancy',
            onPressed: () => ToastService.show(
              context,
              'End tenancy form (demo)',
              success: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Cancel request',
            onPressed: () async {
              final ok = await DialogService.confirm(
                context,
                title: 'Cancel end request?',
                message: 'Your tenancy will remain active.',
                confirmText: 'Cancel request',
                danger: true,
              );
              if (ok && context.mounted) {
                ToastService.show(context, 'Cancelled (demo)', success: true);
              }
            },
          ),
        ],
      ),
    );
  }
}
