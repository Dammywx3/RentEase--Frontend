import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/primary_button.dart';

class WalletPaymentScreen extends StatelessWidget {
  const WalletPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Wallet Payment', subtitle: 'Use available balance'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wallet balance: NGN 80,000 (demo)'),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Confirm payment',
            onPressed: () => ToastService.show(context, 'Insufficient balance (demo)', success: false),
          ),
        ],
      ),
    );
  }
}
