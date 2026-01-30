import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/status_badge.dart';

class PayoutDetailScreen extends StatelessWidget {
  const PayoutDetailScreen({super.key, required this.payoutId, required this.status});

  final String payoutId;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Payout Detail', subtitle: 'Status & reference'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payout #$payoutId', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.payout, status: status),
          const SizedBox(height: AppSpacing.lg),
          const Text('MVP breakdown:\n• Amount: NGN 50,000\n• Bank: Access Bank\n• Ref: PO-10113-2481'),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded), label: const Text('Download receipt (demo)')),
        ],
      ),
    );
  }
}
