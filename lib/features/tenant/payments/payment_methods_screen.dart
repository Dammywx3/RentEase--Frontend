import 'package:flutter/material.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({
    super.key,
    this.cards = const [],
    this.defaultMethodLabel = '—',
    this.showBankTransfer = true,
    this.virtualAccountName = '—',
    this.virtualAccountNumber = '—',
    this.virtualBankName = '—',
    this.onAddCard,
    this.onLinkBank,
    this.onSetDefault,
    this.onRemoveCard,
    this.onCopyAccountNumber,
    this.onCopyBankName,
  });

  /// You can pass real values later
  final List<PaymentCardVM> cards;
  final String defaultMethodLabel;

  final bool showBankTransfer;
  final String virtualAccountName;
  final String virtualAccountNumber;
  final String virtualBankName;

  final VoidCallback? onAddCard;
  final VoidCallback? onLinkBank;

  final ValueChanged<PaymentCardVM>? onSetDefault;
  final ValueChanged<PaymentCardVM>? onRemoveCard;

  final VoidCallback? onCopyAccountNumber;
  final VoidCallback? onCopyBankName;

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fix: ensure gradient sits BEHIND the entire page (including safe areas)
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
            title: 'Payment Methods',
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
              // ✅ Header row inside body (since AppTopBar doesn't support trailing)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your methods',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                  ),
                  _TopAddButton(
                    text: 'Add',
                    onTap: onAddCard ?? () => _toast(context, 'Add card (wire later)'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Cards
              _FrostCard(
                child: Column(
                  children: [
                    if (cards.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Icon(
                              Icons.credit_card_rounded,
                              size: 40,
                              color: AppColors.textMuted(context).withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'No cards yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary(context),
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Add a card to pay faster.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted(context).withValues(alpha: 0.9),
                                  ),
                            ),
                          ],
                        ),
                      )
                    else
                      for (int i = 0; i < cards.length; i++) ...[
                        _CardTile(
                          vm: cards[i],
                          isDefault: cards[i].label == defaultMethodLabel,
                          onSetDefault: onSetDefault == null
                              ? () => _toast(context, 'Set default (wire later)')
                              : () => onSetDefault!(cards[i]),
                          onRemove: onRemoveCard == null
                              ? () => _toast(context, 'Remove (wire later)')
                              : () => onRemoveCard!(cards[i]),
                        ),
                        if (i != cards.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.overlay(context, 0.06),
                          ),
                      ],
                  ],
                ),
              ),

              if (showBankTransfer) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Bank transfer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay by bank transfer',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Use the virtual account below.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted(context).withValues(alpha: 0.9),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        _KeyValueRow(label: 'Account name', value: virtualAccountName),
                        const SizedBox(height: AppSpacing.sm),

                        _CopyRow(
                          label: 'Account number',
                          value: virtualAccountNumber,
                          onCopy: onCopyAccountNumber ?? () => _toast(context, 'Copied account number'),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        _CopyRow(
                          label: 'Bank',
                          value: virtualBankName,
                          onCopy: onCopyBankName ?? () => _toast(context, 'Copied bank name'),
                        ),

                        const SizedBox(height: AppSpacing.md),
                        _OutlineActionButton(
                          text: 'Link bank (optional)',
                          onTap: onLinkBank ?? () => _toast(context, 'Link bank (wire later)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ],
    );
  }
}

class PaymentCardVM {
  const PaymentCardVM({
    required this.label,
    required this.masked,
    required this.expiry,
    this.brandIcon = Icons.credit_card_rounded,
  });

  final String label; // e.g. "Visa"
  final String masked; // e.g. "•••• 1234"
  final String expiry; // e.g. "12/28"
  final IconData brandIcon;
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.vm,
    required this.isDefault,
    required this.onSetDefault,
    required this.onRemove,
  });

  final PaymentCardVM vm;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final baseBorder = AppColors.overlay(context, 0.06);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: baseBorder),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.overlay(context, 0.06),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.overlay(context, 0.05)),
              ),
              child: Icon(vm.brandIcon, color: AppColors.textSecondary(context)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // ✅ Fix: avoid overflow on small screens
                      Expanded(
                        child: Text(
                          '${vm.label} ${vm.masked}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const _Badge(text: 'Default'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Exp ${vm.expiry}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted(context).withValues(alpha: 0.9),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'default') onSetDefault();
                if (v == 'remove') onRemove();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'default', child: Text('Set as default')),
                PopupMenuItem(value: 'remove', child: Text('Remove')),
              ],
              icon: Icon(Icons.more_vert_rounded, color: AppColors.textMuted(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.05),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary(context),
            ),
      ),
    );
  }
}

class _TopAddButton extends StatelessWidget {
  const _TopAddButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.60),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 18, color: AppColors.navy),
              const SizedBox(width: AppSpacing.xs),
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted(context).withValues(alpha: 0.9),
                ),
          ),
        ),
        // ✅ Fix: avoid overflow on long account names/bank names
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
          ),
        ),
      ],
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _KeyValueRow(label: label, value: value)),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: onCopy,
          icon: Icon(Icons.copy_rounded, color: AppColors.textMuted(context)),
        ),
      ],
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.overlay(context, 0.08)),
            color: AppColors.surface(context).withValues(alpha: 0.50),
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
            ),
          ),
        ),
      ),
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
          border: Border.all(
            color: AppColors.surface(context).withValues(alpha: 0.55),
          ),
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