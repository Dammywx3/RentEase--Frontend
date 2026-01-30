import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import 'documents/upload_document_screen.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const status = 'pending';

    return AppScaffold(
      topBar: const AppTopBar(title: 'Verification', subtitle: 'KYC status'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          const StatusBadge(domain: StatusDomain.verified, status: status),
          const SizedBox(height: AppSpacing.lg),
          const Text('Upload your ID or documents to complete verification.'),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Upload document',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UploadDocumentScreen())),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => ToastService.show(context, 'Support (demo)', success: true),
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Contact support'),
          ),
        ],
      ),
    );
  }
}
