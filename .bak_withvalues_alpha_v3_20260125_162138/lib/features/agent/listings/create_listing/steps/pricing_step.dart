import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/form_field.dart';

class PricingStep extends StatefulWidget {
  const PricingStep({super.key});

  @override
  State<PricingStep> createState() => PricingStepState();
}

class PricingStepState extends State<PricingStep> {
  final _formKey = GlobalKey<FormState>();
  final _price = TextEditingController();
  final _deposit = TextEditingController();
  String _currency = 'NGN';

  @override
  void dispose() {
    _price.dispose();
    _deposit.dispose();
    super.dispose();
  }

  bool validateAndSave() => _formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Currency', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            value: _currency,
            items: const [
              DropdownMenuItem(value: 'NGN', child: Text('NGN')),
              DropdownMenuItem(value: 'USD', child: Text('USD')),
            ],
            onChanged: (v) => setState(() => _currency = v ?? 'NGN'),
          ),
          const SizedBox(height: AppSpacing.lg),

          AppFormField(
            controller: _price,
            label: 'Annual rent',
            hint: 'e.g. 1200000',
            validator: (v) => Validators.requiredField(v),
            prefixIcon: Icons.payments_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppFormField(
            controller: _deposit,
            label: 'Deposit (optional)',
            hint: 'e.g. 250000',
            validator: (v) => null,
            prefixIcon: Icons.savings_rounded,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
