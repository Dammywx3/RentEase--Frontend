import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import 'payout_accounts_screen.dart';
import 'request_payout_screen.dart';
import 'payout_status_screen.dart';
import 'payment_history_screen.dart';

class WalletSummaryScreen extends StatelessWidget {
  const WalletSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Wallet', subtitle: 'Balance + payouts'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Balance', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Text('NGN 320,500', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: AppSpacing.sm),
                Text('Escrow (display-only for now)', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Text('NGN 80,000', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: 'Request payout',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RequestPayoutScreen())),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PayoutAccountsScreen())),
                  icon: const Icon(Icons.account_balance_rounded),
                  label: const Text('Payout accounts'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PayoutStatusScreen())),
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Payout status'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Payment history'),
          ),
          const SizedBox(height: AppSpacing.md),

          OutlinedButton.icon(
            onPressed: () => ToastService.show(context, 'Inflow/outflow ledger (Phase 2)', success: true),
            icon: const Icon(Icons.list_alt_rounded),
            label: const Text('Wallet transactions'),
          ),
        ],
      ),
    );
  }
}
