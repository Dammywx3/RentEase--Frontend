import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../../shared/services/toast_service.dart';
import '../../../../../shared/widgets/primary_button.dart';

class UploadMediaScreen extends StatefulWidget {
  const UploadMediaScreen({super.key});

  @override
  State<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends State<UploadMediaScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Upload Media',
        subtitle: 'Images / videos',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MVP UI only. Later: pick files, upload progress, reorder, remove.',
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () {
              setState(() => selected = 3);
              ToastService.show(
                context,
                'Selected 3 files (demo)',
                success: true,
              );
            },
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Choose files'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Selected: $selected file(s)'),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Done',
            onPressed: () =>
                Navigator.of(context).pop(selected == 0 ? 1 : selected),
          ),
        ],
      ),
    );
  }
}
