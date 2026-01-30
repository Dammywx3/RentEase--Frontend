import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';

class PublishStep extends StatelessWidget {
  const PublishStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Publish',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Confirm details and publish.\n\nMVP: this step is UI-ready. Wire publish endpoint later.',
        ),
        const SizedBox(height: AppSpacing.lg),
        const _Bullet('Validate required fields'),
        const _Bullet('Validate enum values'),
        const _Bullet('Upload rules (type/size)'),
        const _Bullet('Status transitions (draft → pending/active)'),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
