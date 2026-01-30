import 'package:flutter/material.dart';
import '../../../../core/constants/status_badge_map.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../shared/widgets/status_badge.dart';
import 'upload_document_screen.dart';

class DocumentDetailScreen extends StatelessWidget {
  const DocumentDetailScreen({
    super.key,
    required this.docId,
    required this.type,
    required this.status,
  });

  final String docId;
  final String type;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Document Detail',
        subtitle: 'Preview & status',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.verified, status: status),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: const Center(child: Text('Preview (image/pdf)')),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UploadDocumentScreen()),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Resubmit'),
          ),
        ],
      ),
    );
  }
}
