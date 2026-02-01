import 'package:flutter/material.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import 'transactions_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({
    super.key,
    this.title = 'Wallet',
    required this.wallet,
    this.recent = const [],
    this.enablePayRent = false,
    this.disablePayRentReason,
  });

  final String title;
  final WalletVM wallet;
  final List<WalletTxnPreviewVM> recent;

  final bool enablePayRent;
  final String? disablePayRentReason;

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final hasEscrow = (wallet.escrowBalanceText ?? '').trim().isNotEmpty;
    final payRentDisabled = !enablePayRent;

    return Stack(
      children: [
        // ✅ Fix: gradient behind EVERYTHING (top safe-area, cards, bottom)
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
            title: title,
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
            centerTitle: true,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenV,
              AppSpacing.s10,
              AppSpacing.screenV,
              AppSizes.screenBottomPad,
            ),
            children: [
              _WalletHeaderCard(
                availableBalanceText: wallet.availableBalanceText,
                lastUpdatedText: wallet.lastUpdatedText,
                escrowBalanceText: hasEscrow ? wallet.escrowBalanceText : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.add_rounded,
                      title: 'Add Money',
                      subtitle: 'Top-up',
                      onTap: () => _push(context, const AddMoneyScreen()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.outbond_rounded,
                      title: 'Withdraw',
                      subtitle: 'To bank',
                      onTap: () => _push(context, const WithdrawScreen()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.home_work_rounded,
                      title: 'Pay Rent',
                      subtitle: enablePayRent ? 'Pay now' : 'Unavailable',
                      disabled: payRentDisabled,
                      // ✅ still tappable when disabled (so user sees why)
                      allowTapWhenDisabled: true,
                      onTap: () {
                        if (payRentDisabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                disablePayRentReason ?? 'No active tenancy',
                              ),
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pay rent flow (wire later)'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Only Transactions shortcut (Payment Methods removed)
              _FrostCard(
                child: Column(
                  children: [
                    _ShortcutRow(
                      icon: Icons.receipt_long_rounded,
                      title: 'Transactions',
                      subtitle: 'History, receipts',
                      trailingText: wallet.lastTxnPreview,
                      onTap: () => _push(context, const TransactionsScreen()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              _SectionHeader(
                title: 'Recent transactions',
                trailing: _LinkText(
                  text: 'See all',
                  onTap: () => _push(context, const TransactionsScreen()),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              if (recent.isEmpty)
                _FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 40,
                          color: AppColors.textMuted(
                            context,
                          ).withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No recent activity',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary(context),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Top-up or pay to see transactions here.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted(
                                  context,
                                ).withValues(alpha: 0.9),
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
                      for (int i = 0; i < recent.length; i++) ...[
                        _TxnPreviewRow(vm: recent[i]),
                        if (i != recent.length - 1)
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

/// Simple internal Add Money screen (so your button opens something real)
class AddMoneyScreen extends StatelessWidget {
  const AddMoneyScreen({super.key});

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
            title: 'Add Money',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top up your wallet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Connect this to Paystack/Flutterwave later.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted(
                            context,
                          ).withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Top-up flow (wire gateway later)',
                                ),
                              ),
                            );
                          },
                          child: const Text('Continue'),
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

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

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
            title: 'Withdraw',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Withdraw to bank',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Connect this to your payout/bank details later.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted(
                            context,
                          ).withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Withdraw flow (wire later)'),
                              ),
                            );
                          },
                          child: const Text('Continue'),
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

/// ---------------- VMs ----------------
class WalletVM {
  const WalletVM({
    required this.availableBalanceText,
    required this.lastUpdatedText,
    this.escrowBalanceText,
    this.lastTxnPreview,
  });

  final String availableBalanceText;
  final String lastUpdatedText;
  final String? escrowBalanceText;
  final String? lastTxnPreview;
}

class WalletTxnPreviewVM {
  const WalletTxnPreviewVM({
    required this.title,
    required this.subTitle,
    required this.amountText,
    required this.isIncoming,
    required this.statusText,
  });

  final String title;
  final String subTitle;
  final String amountText;
  final bool isIncoming;
  final String statusText;
}

/// ---------------- UI pieces ----------------
class _WalletHeaderCard extends StatelessWidget {
  const _WalletHeaderCard({
    required this.availableBalanceText,
    required this.lastUpdatedText,
    this.escrowBalanceText,
  });

  final String availableBalanceText;
  final String lastUpdatedText;
  final String? escrowBalanceText;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available balance',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted(context).withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              availableBalanceText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.update_rounded,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    lastUpdatedText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted(
                        context,
                      ).withValues(alpha: 0.9),
                    ),
                  ),
                ),
                if (escrowBalanceText != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _Pill(
                    text: 'Escrow: $escrowBalanceText',
                    icon: Icons.lock_rounded,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.disabled = false,
    this.allowTapWhenDisabled = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  final bool disabled;

  /// ✅ Some actions should still be clickable to show the reason (Pay Rent).
  final bool allowTapWhenDisabled;

  @override
  Widget build(BuildContext context) {
    final fg = disabled
        ? AppColors.textMuted(context).withValues(alpha: 0.45)
        : AppColors.textPrimary(context);

    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: (disabled && !allowTapWhenDisabled) ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.overlay(context, 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 36,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.overlay(context, 0.06),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.overlay(context, 0.05)),
                ),
                child: Icon(icon, color: fg, size: 20),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted(
                    context,
                  ).withValues(alpha: disabled ? 0.45 : 0.88),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText;
  final VoidCallback onTap;

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
              _IconChip(
                icon: icon,
                bg: AppColors.tenantPanel,
                fg: AppColors.brandBlueSoft,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted(
                          context,
                        ).withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingText != null && trailingText!.trim().isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.overlay(context, 0.03),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(color: AppColors.overlay(context, 0.05)),
                  ),
                  child: Text(
                    trailingText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.xs),
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

class _TxnPreviewRow extends StatelessWidget {
  const _TxnPreviewRow({required this.vm});
  final WalletTxnPreviewVM vm;

  @override
  Widget build(BuildContext context) {
    final amountColor = vm.isIncoming
        ? AppColors.brandGreenDeep
        : AppColors.tenantDangerDeep;
    final statusTint = _statusTint(vm.statusText);

    return Padding(
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
                  vm.subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted(context).withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatusPill(text: vm.statusText, tint: statusTint),
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
    );
  }

  Color _statusTint(String s) {
    final v = s.toLowerCase().trim();
    if (v.contains('success')) return AppColors.brandGreenDeep;
    if (v.contains('fail')) return AppColors.tenantDangerDeep;
    return AppColors.tenantIconBgSand;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.brandBlueSoft,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.03),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted(context)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.tint});
  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
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
