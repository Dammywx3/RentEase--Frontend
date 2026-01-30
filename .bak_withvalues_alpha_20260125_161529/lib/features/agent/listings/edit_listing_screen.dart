import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/form_field.dart';
import '../../../shared/widgets/primary_button.dart';

class EditListingScreen extends StatefulWidget {
  const EditListingScreen({super.key, required this.listingId});
  final String listingId;

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController(text: 'Modern 2 Bedroom Apartment');
  final _price = TextEditingController(text: '1200000');
  final _location = TextEditingController(text: 'Lekki, Lagos');

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _location.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ToastService.show(context, 'Listing updated (demo)', success: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Edit Listing',
        subtitle: 'Update listing details',
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
            AppFormField(
              controller: _price,
              label: 'Price (NGN)',
              hint: '1200000',
              validator: (v) => Validators.requiredField(v),
              prefixIcon: Icons.payments_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
