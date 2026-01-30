import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/services/toast_service.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../upload_media/upload_media_screen.dart';

class MediaStep extends StatefulWidget {
  const MediaStep({super.key});

  @override
  State<MediaStep> createState() => MediaStepState();
}

class MediaStepState extends State<MediaStep> {
  int mediaCount = 0;

  bool validateAndSave() => true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Uploaded: $mediaCount item(s)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Upload media',
          onPressed: () async {
            final added = await Navigator.of(context).push<int>(
              MaterialPageRoute(builder: (_) => const UploadMediaScreen()),
            );
            if (!context.mounted) return;
            if (added != null) {
              setState(() => mediaCount += added);
              ToastService.show(
                context,
                'Added $added media file(s)',
                success: true,
              );
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'MVP: shows UI only. Later: upload endpoint + reorder + delete.',
        ),
      ],
    );
  }
}
