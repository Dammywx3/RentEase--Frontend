import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/ui/states/empty_state.dart';
import '../../../shared/widgets/card_widgets/payment_card.dart';
import 'payment_detail_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _tab = 'All';

  final _items = const [
    _PayRow(
      id: 'p1',
      purpose: 'Rent Payment',
      amount: 'NGN 1,200,000',
      date: 'Jan 12, 2026',
      status: 'successful',
    ),
    _PayRow(
      id: 'p2',
      purpose: 'Deposit',
      amount: 'NGN 250,000',
      date: 'Jan 11, 2026',
      status: 'pending',
    ),
    _PayRow(
      id: 'p3',
      purpose: 'Rent Payment',
      amount: 'NGN 1,200,000',
      date: 'Dec 10, 2025',
      status: 'failed',
    ),
  ];

  List<_PayRow> get _filtered {
    if (_tab == 'All') return _items;
    return _items.where((x) => x.status == _tab.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Payments',
        subtitle: 'History & receipts',
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TabChip(
                  label: 'All',
                  active: _tab == 'All',
                  onTap: () => setState(() => _tab = 'All'),
                ),
                _TabChip(
                  label: 'pending',
                  active: _tab == 'pending',
                  onTap: () => setState(() => _tab = 'pending'),
                ),
                _TabChip(
                  label: 'successful',
                  active: _tab == 'successful',
                  onTap: () => setState(() => _tab = 'successful'),
                ),
                _TabChip(
                  label: 'failed',
                  active: _tab == 'failed',
                  onTap: () => setState(() => _tab = 'failed'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    title: 'No payments yet',
                    message: 'Your payment history will appear here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: items.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final x = items[i];
                      return PaymentCard(
                        purposeText: x.purpose,
                        amountText: x.amount,
                        dateText: x.date,
                        status: x.status,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PaymentDetailScreen(
                                paymentId: x.id,
                                status: x.status,
                              ),
                            ),
                          );
                        },
                        primaryActionText: x.status == 'failed'
                            ? 'Retry'
                            : 'View',
                        onPrimaryAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PaymentDetailScreen(
                                paymentId: x.id,
                                status: x.status,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _PayRow {
  const _PayRow({
    required this.id,
    required this.purpose,
    required this.amount,
    required this.date,
    required this.status,
  });
  final String id;
  final String purpose;
  final String amount;
  final String date;
  final String status;
}
