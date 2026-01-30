import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/status_badge.dart';

class PaymentDetailScreen extends StatelessWidget {
  const PaymentDetailScreen({super.key, required this.paymentId, required this.status});

  final String paymentId;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Payment Detail', subtitle: 'Receipt & reference'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment #$paymentId', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.payment, status: status),
          const SizedBox(height: AppSpacing.lg),
          const Text('MVP breakdown:\n• Purpose: Rent\n• Amount: NGN 1,200,000\n• Ref: PAY-10113-2481'),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded), label: const Text('Download receipt (demo)')),
        ],
      ),
    );
  }
}
