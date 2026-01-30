import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';

class DocumentDetailScreen extends StatelessWidget {
  const DocumentDetailScreen({
    super.key,
    required this.docId,
    required this.userName,
    required this.docType,
    required this.status,
  });

  final String docId;
  final String userName;
  final String docType;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Document Detail',
        subtitle: 'Preview + approve/reject',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$userName • $docType',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.verified, status: status),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: const Center(child: Text('Preview (image/pdf)')),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Approve',
            onPressed: () =>
                ToastService.show(context, 'Approved (demo)', success: true),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await DialogService.confirm(
                context,
                title: 'Reject document?',
                message: 'Reason required in real flow.',
                confirmText: 'Reject',
                danger: true,
              );
              if (ok && context.mounted) {
                ToastService.show(context, 'Rejected (demo)', success: true);
              }
            },
            icon: const Icon(Icons.block_rounded),
            label: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
