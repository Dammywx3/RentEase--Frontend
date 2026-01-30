import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/primary_button.dart';

import 'package:rentease_frontend/core/theme/app_spacing.dart';

class CardPaymentScreen extends StatelessWidget {
  const CardPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Card Payment',
        subtitle: 'Secure card checkout',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MVP UI only — wire tokenized checkout (Paystack/Squad).'),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Pay now',
            onPressed: () => ToastService.show(
              context,
              'Processing... (demo)',
              success: true,
            ),
          ),
        ],
      ),
    );
  }
}
