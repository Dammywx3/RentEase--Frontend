import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/form_field.dart';
import '../../../shared/widgets/primary_button.dart';

class RequestPayoutScreen extends StatefulWidget {
  const RequestPayoutScreen({super.key});

  @override
  State<RequestPayoutScreen> createState() => _RequestPayoutScreenState();
}

class _RequestPayoutScreenState extends State<RequestPayoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController(text: '50000');

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ToastService.show(context, 'Payout requested (demo)', success: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Request Payout',
        subtitle: 'Withdraw to bank',
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppFormField(
              controller: _amount,
              label: 'Amount (NGN)',
              hint: 'e.g. 50000',
              validator: (v) => Validators.requiredField(v),
              prefixIcon: Icons.payments_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Confirm request', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
