import 'package:flutter/material.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import 'wallet_screen.dart';
import 'payment_methods_screen.dart';
import 'transactions_screen.dart';

class PaymentHubScreen extends StatelessWidget {
  const PaymentHubScreen({
    super.key,
    this.balancePreviewText = '₦—',
    this.defaultMethodPreviewText = '—',
    this.lastTransactionPreviewText = '—',
    this.showProofOfPayment = true,
  });

  final String balancePreviewText;
  final String defaultMethodPreviewText;
  final String lastTransactionPreviewText;
  final bool showProofOfPayment;

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Full-screen gradient (no cut-off)
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
          topBar: const AppTopBar(
            title: 'Payments',
            centerTitle: true,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenV,
              AppSpacing.s10,
              AppSpacing.screenV,
              AppSizes.screenBottomPad,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Removed the big top card (wallet image + "Payments Hub")
                // ✅ Replace with a clean section label + subtle helper text
                Text(
                  'Manage payments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Wallet, payment methods, receipts and history.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted(context).withValues(alpha: 0.85),
                      ),
                ),
                const SizedBox(height: AppSpacing.md),

                _FrostCard(
                  child: Column(
                    children: [
                      _HubRow(
                        icon: Icons.account_balance_wallet_rounded,
                        iconBg: AppColors.tenantPanel,
                        iconFg: AppColors.brandBlueSoft,
                        title: 'Wallet',
                        subtitle: 'Balance, add money, withdraw',
                        trailingText: balancePreviewText,
                        onTap: () {
                          _push(
                            context,
                            WalletScreen(
                              wallet: const WalletVM(
                                availableBalanceText: '₦—',
                                lastUpdatedText: 'Last updated: —',
                                escrowBalanceText: null,
                                lastTxnPreview: '—',
                              ),
                              recent: const [],
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, thickness: 1, color: AppColors.overlay(context, 0.06)),
                      _HubRow(
                        icon: Icons.credit_card_rounded,
                        iconBg: AppColors.tenantIconBgGreen,
                        iconFg: AppColors.brandGreenDeep,
                        title: 'Payment Methods',
                        subtitle: 'Cards, bank transfer',
                        trailingText: defaultMethodPreviewText,
                        onTap: () => _push(context, const PaymentMethodsScreen()),
                      ),
                      Divider(height: 1, thickness: 1, color: AppColors.overlay(context, 0.06)),
                      _HubRow(
                        icon: Icons.receipt_long_rounded,
                        iconBg: AppColors.tenantIconBgSand,
                        iconFg: AppColors.tenantGray600,
                        title: 'Transactions',
                        subtitle: 'History, receipts',
                        trailingText: lastTransactionPreviewText,
                        onTap: () => _push(context, const TransactionsScreen()),
                      ),
                      if (showProofOfPayment) ...[
                        Divider(height: 1, thickness: 1, color: AppColors.overlay(context, 0.06)),
                        _HubRow(
                          icon: Icons.cloud_upload_rounded,
                          iconBg: AppColors.tenantIconBgGray,
                          iconFg: AppColors.tenantGray600,
                          title: 'Proof of Payment',
                          subtitle: 'Upload / view receipts',
                          onTap: () => _push(context, const ProofOfPaymentScreen()),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProofOfPaymentScreen extends StatelessWidget {
  const ProofOfPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: 'Proof of Payment',
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
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload_rounded, size: 44, color: AppColors.textMuted(context)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Upload receipts',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'You can connect this to your receipt upload later.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted(context).withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ---------------- UI helpers ---------------- */

class _HubRow extends StatelessWidget {
  const _HubRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
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
              _IconChip(icon: icon, bg: iconBg, fg: iconFg),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted(context).withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
              if (trailingText != null && trailingText!.trim().isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: Text(
                    trailingText!,
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
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted(context).withValues(alpha: 0.75),
              ),
            ],
          ),
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