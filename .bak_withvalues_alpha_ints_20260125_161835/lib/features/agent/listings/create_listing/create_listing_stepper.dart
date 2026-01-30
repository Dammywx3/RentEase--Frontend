import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'steps/basics_step.dart';
import 'steps/pricing_step.dart';
import 'steps/media_step.dart';
import 'steps/publish_step.dart';

class CreateListingStepper extends StatefulWidget {
  const CreateListingStepper({super.key});

  @override
  State<CreateListingStepper> createState() => _CreateListingStepperState();
}

class _CreateListingStepperState extends State<CreateListingStepper> {
  int _index = 0;

  final basicsKey = GlobalKey<BasicsStepState>();
  final pricingKey = GlobalKey<PricingStepState>();
  final mediaKey = GlobalKey<MediaStepState>();

  void _next() {
    if (_index == 0 && !(basicsKey.currentState?.validateAndSave() ?? false))
      return;
    if (_index == 1 && !(pricingKey.currentState?.validateAndSave() ?? false))
      return;
    if (_index == 2 && !(mediaKey.currentState?.validateAndSave() ?? false))
      return;

    if (_index < 3) setState(() => _index++);
  }

  void _back() {
    if (_index > 0) setState(() => _index--);
  }

  void _publish() {
    ToastService.show(context, 'Listing submitted (demo)', success: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      BasicsStep(key: basicsKey),
      PricingStep(key: pricingKey),
      MediaStep(key: mediaKey),
      const PublishStep(),
    ];

    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Create Listing',
        subtitle: 'Basics → Pricing → Media → Publish',
      ),
      child: Column(
        children: [
          _StepperHeader(index: _index),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: steps[_index]),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _index == 0 ? null : _back,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  label: _index == 3 ? 'Publish' : 'Next',
                  onPressed: _index == 3 ? _publish : _next,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperHeader extends StatelessWidget {
  const _StepperHeader({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final labels = const ['Basics', 'Pricing', 'Media', 'Publish'];

    return Row(
      children: List.generate(labels.length, (i) {
        final active = i == index;
        final done = i < index;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: active
                    ? Theme.of(context).colorScheme.primary.withAlpha(22)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: done
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: done ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
