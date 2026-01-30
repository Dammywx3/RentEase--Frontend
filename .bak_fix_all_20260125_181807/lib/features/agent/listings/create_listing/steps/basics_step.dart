import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/form_field.dart';

class BasicsStep extends StatefulWidget {
  const BasicsStep({super.key});

  @override
  State<BasicsStep> createState() => BasicsStepState();
}

class BasicsStepState extends State<BasicsStep> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  String _type = 'Apartment';

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    super.dispose();
  }

  bool validateAndSave() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppFormField(
            controller: _title,
            label: 'Title',
            hint: 'e.g. Modern 2 Bedroom Apartment',
            validator: (v) => Validators.requiredField(v),
            prefixIcon: Icons.title_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppFormField(
            controller: _location,
            label: 'Location',
            hint: 'e.g. Lekki, Lagos',
            validator: (v) => Validators.requiredField(v),
            prefixIcon: Icons.location_on_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Property type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            initialValue: _type,
            items: const [
              DropdownMenuItem(value: 'Apartment', child: Text('Apartment')),
              DropdownMenuItem(value: 'Duplex', child: Text('Duplex')),
              DropdownMenuItem(value: 'Studio', child: Text('Studio')),
              DropdownMenuItem(value: 'Land', child: Text('Land')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'Apartment'),
          ),
        ],
      ),
    );
  }
}
