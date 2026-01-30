import 'package:flutter/material.dart';
import '../../../../core/constants/status_badge_map.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../core/ui/states/empty_state.dart';
import '../../../../shared/widgets/status_badge.dart';
import 'document_detail_screen.dart';
import 'upload_document_screen.dart';

class DocumentsListScreen extends StatelessWidget {
  const DocumentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const docs = [
      _DocRow(id: 'd1', type: 'ID Card', status: 'pending', date: 'Jan 15, 2026'),
      _DocRow(id: 'd2', type: 'Utility Bill', status: 'verified', date: 'Dec 28, 2025'),
    ];

    return AppScaffold(
      topBar: AppTopBar(
        title: 'Documents',
        subtitle: 'Upload & track review',
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UploadDocumentScreen())),
            icon: const Icon(Icons.upload_file_rounded),
          ),
        ],
      ),
      child: docs.isEmpty
          ? const EmptyState(title: 'No documents', message: 'Upload your first document to begin verification.')
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                final d = docs[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.description_rounded)),
                  title: Text(d.type, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                  subtitle: Text('Uploaded: ${d.date}'),
                  trailing: StatusBadge(domain: StatusDomain.verified, status: d.status, compact: true),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DocumentDetailScreen(docId: d.id, type: d.type, status: d.status)),
                  ),
                );
              },
            ),
    );
  }
}

class _DocRow {
  const _DocRow({required this.id, required this.type, required this.status, required this.date});
  final String id;
  final String type;
  final String status;
  final String date;
}
