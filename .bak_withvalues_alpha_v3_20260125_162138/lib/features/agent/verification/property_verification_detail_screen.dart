import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';

class PropertyVerificationDetailScreen extends StatelessWidget {
  const PropertyVerificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const status = 'pending';

    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Property Verification',
        subtitle: 'Status + notes',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property: Modern 2 Bedroom Apartment',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          const StatusBadge(domain: StatusDomain.verified, status: status),
          const SizedBox(height: AppSpacing.lg),
          const Text('Notes: Awaiting on-site verification (demo).'),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Mark verified',
            onPressed: () =>
                ToastService.show(context, 'Verified (demo)', success: true),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => ToastService.show(
              context,
              'Reject with reason (demo)',
              success: true,
            ),
            icon: const Icon(Icons.block_rounded),
            label: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
