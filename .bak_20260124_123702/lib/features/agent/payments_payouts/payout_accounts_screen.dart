import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';

class PayoutAccountsScreen extends StatelessWidget {
  const PayoutAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Payout Accounts', subtitle: 'Add your bank account'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Accounts (demo)\n• Access Bank • 1234567890'),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Add bank account',
            onPressed: () => ToastService.show(context, 'Add account flow (demo)', success: true),
          ),
        ],
      ),
    );
  }
}
