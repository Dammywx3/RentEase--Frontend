import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/card_widgets/payment_card.dart';
import 'payment_detail_screen.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _Row(id: 'ph1', purpose: 'Rent Payment', amount: 'NGN 1,200,000', date: 'Jan 12, 2026', status: 'successful'),
      _Row(id: 'ph2', purpose: 'Deposit', amount: 'NGN 250,000', date: 'Jan 11, 2026', status: 'pending'),
      _Row(id: 'ph3', purpose: 'Rent Payment', amount: 'NGN 1,200,000', date: 'Dec 10, 2025', status: 'failed'),
    ];

    return AppScaffold(
      topBar: const AppTopBar(title: 'Payment History', subtitle: 'Successful / pending / failed'),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) {
          final x = items[i];
          return PaymentCard(
            purposeText: x.purpose,
            amountText: x.amount,
            dateText: x.date,
            status: x.status,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentDetailScreen(paymentId: x.id, status: x.status))),
            primaryActionText: 'View',
            onPrimaryAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentDetailScreen(paymentId: x.id, status: x.status))),
          );
        },
      ),
    );
  }
}

class _Row {
  const _Row({required this.id, required this.purpose, required this.amount, required this.date, required this.status});
  final String id;
  final String purpose;
  final String amount;
  final String date;
  final String status;
}
