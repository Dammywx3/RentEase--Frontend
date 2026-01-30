import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/primary_button.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  String _type = 'ID Card';

  void _upload() {
    ToastService.show(context, 'Uploaded (demo)', success: true);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Upload Document',
        subtitle: 'KYC / verification',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Document type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            value: _type,
            items: const [
              DropdownMenuItem(value: 'ID Card', child: Text('ID Card')),
              DropdownMenuItem(value: 'Passport', child: Text('Passport')),
              DropdownMenuItem(
                value: 'Utility Bill',
                child: Text('Utility Bill'),
              ),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'ID Card'),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () =>
                ToastService.show(context, 'Pick file (demo)', success: true),
            icon: const Icon(Icons.attach_file_rounded),
            label: const Text('Choose file'),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Upload', onPressed: _upload),
        ],
      ),
    );
  }
}
