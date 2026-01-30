import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/form_field.dart';
import '../../../shared/widgets/primary_button.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();

  String _category = 'Plumbing';
  String _priority = 'Medium';

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ToastService.show(context, 'Request created (demo)', success: true);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Create Request',
        subtitle: 'Describe the issue',
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Category',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: const [
                DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                DropdownMenuItem(
                  initialValue: 'Electrical',
                  child: Text('Electrical'),
                ),
                DropdownMenuItem(value: 'General', child: Text('General')),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'Plumbing'),
            ),
            const SizedBox(height: AppSpacing.lg),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Priority',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'High', child: Text('High')),
              ],
              onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
            ),
            const SizedBox(height: AppSpacing.lg),

            AppFormField(
              controller: _title,
              label: 'Title',
              hint: 'e.g. Leaking tap in kitchen',
              validator: (v) => Validators.requiredField(v),
              prefixIcon: Icons.build_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _desc,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(
                hintText: 'Describe the issue...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              validator: (v) => Validators.requiredField(v),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Submit request', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
