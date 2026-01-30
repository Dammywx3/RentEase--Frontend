import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import 'payment_methods/bank_transfer_screen.dart';
import 'payment_methods/card_payment_screen.dart';
import 'payment_methods/wallet_payment_screen.dart';
import 'receipt/receipt_screen.dart';

class PaymentDetailScreen extends StatelessWidget {
  const PaymentDetailScreen({super.key, required this.paymentId, required this.status});

  final String paymentId;
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    return AppScaffold(
      topBar: const AppTopBar(title: 'Payment Detail', subtitle: 'Breakdown & actions'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment #$paymentId', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.payment, status: status),
          const SizedBox(height: AppSpacing.lg),

          const Text('Breakdown (demo)\n• Amount: NGN 250,000\n• Purpose: Deposit\n• Ref: 10113-2481-2026'),
          const SizedBox(height: AppSpacing.lg),

          if (s == 'successful') ...[
            PrimaryButton(
              label: 'View receipt',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReceiptScreen()));
              },
            ),
          ] else if (s == 'failed') ...[
            PrimaryButton(
              label: 'Retry payment',
              onPressed: () => ToastService.show(context, 'Choose payment method', success: true),
            ),
            const SizedBox(height: AppSpacing.md),
            _MethodRow(
              onCard: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CardPaymentScreen())),
              onWallet: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletPaymentScreen())),
              onBank: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BankTransferScreen())),
            ),
          ] else ...[
            PrimaryButton(
              label: 'Continue payment',
              onPressed: () => ToastService.show(context, 'Choose payment method', success: true),
            ),
            const SizedBox(height: AppSpacing.md),
            _MethodRow(
              onCard: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CardPaymentScreen())),
              onWallet: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletPaymentScreen())),
              onBank: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BankTransferScreen())),
            ),
          ],
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({required this.onCard, required this.onWallet, required this.onBank});
  final VoidCallback onCard;
  final VoidCallback onWallet;
  final VoidCallback onBank;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(onPressed: onCard, icon: const Icon(Icons.credit_card_rounded), label: const Text('Card')),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: onWallet, icon: const Icon(Icons.account_balance_wallet_rounded), label: const Text('Wallet')),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: onBank, icon: const Icon(Icons.account_balance_rounded), label: const Text('Bank Transfer')),
      ],
    );
  }
}
