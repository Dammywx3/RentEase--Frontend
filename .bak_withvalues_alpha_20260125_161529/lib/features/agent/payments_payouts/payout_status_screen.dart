import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/card_widgets/payout_card.dart';
import 'payout_detail_screen.dart';

class PayoutStatusScreen extends StatelessWidget {
  const PayoutStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _Row(
        id: 'po1',
        amount: 'NGN 50,000',
        date: 'Jan 13, 2026',
        status: 'processing',
      ),
      _Row(
        id: 'po2',
        amount: 'NGN 120,000',
        date: 'Jan 05, 2026',
        status: 'paid',
      ),
      _Row(
        id: 'po3',
        amount: 'NGN 30,000',
        date: 'Dec 22, 2025',
        status: 'failed',
      ),
    ];

    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Payouts',
        subtitle: 'Pending → processing → paid',
      ),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount: items.length,
        separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) {
          final x = items[i];
          return PayoutCard(
            amountText: x.amount,
            dateText: x.date,
            status: x.status,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    PayoutDetailScreen(payoutId: x.id, status: x.status),
              ),
            ),
            primaryActionText: 'View',
            onPrimaryAction: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    PayoutDetailScreen(payoutId: x.id, status: x.status),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Row {
  const _Row({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
  });
  final String id;
  final String amount;
  final String date;
  final String status;
}
