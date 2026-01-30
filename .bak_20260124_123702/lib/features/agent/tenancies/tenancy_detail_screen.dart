import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

class TenancyDetailScreen extends StatelessWidget {
  const TenancyDetailScreen({super.key, required this.tenancyId, required this.title, required this.status});

  final String tenancyId;
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Tenancy Detail', subtitle: 'Lease + payments summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          Text('Status: $status'),
          const SizedBox(height: AppSpacing.lg),

          Text('Lease & docs', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(onPressed: () => ToastService.show(context, 'Open lease PDF (demo)', success: true), icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('Lease Agreement.pdf')),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: 'Schedule inspection',
            onPressed: () => ToastService.show(context, 'Inspection scheduled (demo)', success: true),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'End tenancy',
            onPressed: () async {
              final ok = await DialogService.confirm(
                context,
                title: 'End tenancy?',
                message: 'This will notify tenant and start end process.',
                confirmText: 'End tenancy',
                danger: true,
              );
              if (ok && context.mounted) ToastService.show(context, 'End process started (demo)', success: true);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => ToastService.show(context, 'Archive (demo)', success: true),
            icon: const Icon(Icons.archive_rounded),
            label: const Text('Archive'),
          ),
        ],
      ),
    );
  }
}
