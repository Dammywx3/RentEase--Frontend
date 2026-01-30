import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/primary_button.dart';

class BankTransferScreen extends StatelessWidget {
  const BankTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Bank Transfer',
        subtitle: 'Pay using bank transfer',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank: RentEase Demo Bank\nAccount: 1234567890\nReference: PAY-10113-2481',
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: "I've paid",
            onPressed: () => ToastService.show(
              context,
              'Marked as paid (pending verification)',
              success: true,
            ),
          ),
        ],
      ),
    );
  }
}
