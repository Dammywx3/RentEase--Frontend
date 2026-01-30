import 'package:flutter/material.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    this.items = const [],
  });

  final List<TransactionItemVM> items;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'All';

  List<String> get _filters => const ['All', 'Incoming', 'Outgoing', 'Rent', 'Fees'];

  List<TransactionItemVM> get _data {
    if (widget.items.isNotEmpty) return widget.items;

    return const [
      TransactionItemVM(
        title: 'Wallet Top-up',
        dateTimeText: 'Today • 5:25pm',
        status: 'Success',
        amountText: '+ ₦25,000',
        isIncoming: true,
        category: 'Incoming',
      ),
      TransactionItemVM(
        title: 'Rent Payment',
        dateTimeText: 'Yesterday • 10:02am',
        status: 'Pending',
        amountText: '- ₦50,000',
        isIncoming: false,
        category: 'Rent',
      ),
      TransactionItemVM(
        title: 'Withdrawal',
        dateTimeText: 'Jan 10 • 3:18pm',
        status: 'Failed',
        amountText: '- ₦15,000',
        isIncoming: false,
        category: 'Outgoing',
      ),
    ];
  }

  List<TransactionItemVM> get _filtered {
    if (_filter == 'All') return _data;
    return _data.where((x) {
      if (_filter == 'Incoming') return x.isIncoming;
      if (_filter == 'Outgoing') return !x.isIncoming;
      return x.category.toLowerCase() == _filter.toLowerCase();
    }).toList();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fix: gradient behind EVERYTHING (safe-area included)
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.pageBgGradient(context),
            ),
          ),
        ),
        AppScaffold(
          backgroundColor: Colors.transparent,
          safeAreaTop: true,
          safeAreaBottom: false,
          topBar: AppTopBar(
            title: 'Transactions',
            centerTitle: true,
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenV,
              AppSpacing.s10,
              AppSpacing.screenV,
              AppSizes.screenBottomPad,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _toast('Filter options (wire later)'),
                    icon: Icon(Icons.tune_rounded, color: AppColors.textSecondary(context)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final t = _filters[i];
                    final selected = t == _filter;
                    return _FilterPill(
                      text: t,
                      selected: selected,
                      onTap: () => setState(() => _filter = t),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              if (_filtered.isEmpty)
                _FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 42,
                          color: AppColors.textMuted(context).withValues(alpha: 0.70),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No transactions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary(context),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Your payment history will appear here.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted(context).withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _FrostCard(
                  child: Column(
                    children: [
                      for (int i = 0; i < _filtered.length; i++) ...[
                        _TxnRow(
                          vm: _filtered[i],
                          onTap: () => _toast('Transaction details (wire later)'),
                        ),
                        if (i != _filtered.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.overlay(context, 0.06),
                          ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class TransactionItemVM {
  const TransactionItemVM({
    required this.title,
    required this.dateTimeText,
    required this.status,
    required this.amountText,
    required this.isIncoming,
    required this.category,
  });

  final String title;
  final String dateTimeText;
  final String status;
  final String amountText;
  final bool isIncoming;
  final String category;
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.brandBlueSoft.withValues(alpha: 0.20)
        : AppColors.surface(context).withValues(alpha: 0.55);

    final border = selected
        ? AppColors.brandBlueSoft.withValues(alpha: 0.60)
        : AppColors.overlay(context, 0.08);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: border),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.vm, required this.onTap});

  final TransactionItemVM vm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountColor = vm.isIncoming ? AppColors.brandGreenDeep : AppColors.tenantDangerDeep;
    final statusTint = _statusTint(vm.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              _IconChip(
                icon: Icons.receipt_long_rounded,
                bg: AppColors.tenantPanel,
                fg: AppColors.brandBlueSoft,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vm.dateTimeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted(context).withValues(alpha: 0.85),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StatusPill(text: vm.status, tint: statusTint),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                vm.amountText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: amountColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusTint(String s) {
    final v = s.toLowerCase().trim();
    if (v.contains('success')) return AppColors.brandGreenDeep;
    if (v.contains('fail')) return AppColors.tenantDangerDeep;
    return AppColors.tenantIconBgSand;
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.tint});
  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.bg, required this.fg});

  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: Icon(icon, color: fg, size: 20),
    );
  }
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.surface(context).withValues(alpha: 0.55)),
          boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: child,
        ),
      ),
    );
  }
}