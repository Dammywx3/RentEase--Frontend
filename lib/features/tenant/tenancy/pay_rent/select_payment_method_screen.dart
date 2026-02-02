import 'package:flutter/material.dart';

import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';

import 'confirm_payment_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  const SelectPaymentMethodScreen({
    super.key,
    required this.title,
    required this.amountNgn,
    required this.includeServiceCharge,
  });

  final String title;
  final int amountNgn;
  final bool includeServiceCharge;

  @override
  State<SelectPaymentMethodScreen> createState() =>
      _SelectPaymentMethodScreenState();
}

enum _Method { card, bank, wallet }

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  _Method _method = _Method.card;

  // ✅ Explore-style computed alphas (no magic numbers)
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buf.write(",");
      }
    }
    return "₦$buf";
  }

  String get _methodLabel {
    switch (_method) {
      case _Method.card:
        return "Card •••• 1234";
      case _Method.bank:
        return "Bank Transfer";
      case _Method.wallet:
        return "Wallet";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        appBar: const AppTopBar(title: 'Select Payment Method'),
        scroll: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.sm,
                  AppSpacing.screenH,
                  AppSizes.screenBottomPad,
                ),
                children: [
                  _SectionHeader(title: 'Choose a method'),
                  const SizedBox(height: AppSpacing.sm),

                  _SelectTile(
                    title: "Card",
                    subtitle: "•••• 1234",
                    leading: Icons.credit_card_rounded,
                    selected: _method == _Method.card,
                    onTap: () => setState(() => _method = _Method.card),
                    alphaSurfaceStrong: _alphaSurfaceStrong,
                    alphaSurfaceSoft: _alphaSurfaceSoft,
                    alphaBorderSoft: _alphaBorderSoft,
                    alphaShadowSoft: _alphaShadowSoft,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SelectTile(
                    title: "Bank Transfer",
                    subtitle: "Transfer to RentEase account",
                    leading: Icons.account_balance_rounded,
                    selected: _method == _Method.bank,
                    onTap: () => setState(() => _method = _Method.bank),
                    alphaSurfaceStrong: _alphaSurfaceStrong,
                    alphaSurfaceSoft: _alphaSurfaceSoft,
                    alphaBorderSoft: _alphaBorderSoft,
                    alphaShadowSoft: _alphaShadowSoft,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SelectTile(
                    title: "Wallet",
                    subtitle: "Balance: ₦0",
                    leading: Icons.account_balance_wallet_rounded,
                    selected: _method == _Method.wallet,
                    onTap: () => setState(() => _method = _Method.wallet),
                    alphaSurfaceStrong: _alphaSurfaceStrong,
                    alphaSurfaceSoft: _alphaSurfaceSoft,
                    alphaBorderSoft: _alphaBorderSoft,
                    alphaShadowSoft: _alphaShadowSoft,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _SectionHeader(title: 'Add new method'),
                  const SizedBox(height: AppSpacing.sm),

                  _GhostTile(
                    icon: Icons.credit_card_rounded,
                    text: "Add Card",
                    alphaSurfaceStrong: _alphaSurfaceStrong,
                    alphaBorderSoft: _alphaBorderSoft,
                    alphaShadowSoft: _alphaShadowSoft,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _GhostTile(
                    icon: Icons.account_balance_rounded,
                    text: "Add Bank Transfer",
                    alphaSurfaceStrong: _alphaSurfaceStrong,
                    alphaBorderSoft: _alphaBorderSoft,
                    alphaShadowSoft: _alphaShadowSoft,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _GhostTile(
                    icon: Icons.account_balance_wallet_rounded,
                    text: "Add Wallet",
                    alphaSurfaceStrong: _alphaSurfaceStrong,
                    alphaBorderSoft: _alphaBorderSoft,
                    alphaShadowSoft: _alphaShadowSoft,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _GhostTile(
                    icon: Icons.add_rounded,
                    text: "New method",
                    alphaSurfaceStrong: _alphaSurfaceStrong,
                    alphaBorderSoft: _alphaBorderSoft,
                    alphaShadowSoft: _alphaShadowSoft,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // ✅ Sticky bottom CTA (Explore-style surface + border + shadow)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.md,
                  AppSpacing.screenH,
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface(context).withValues(
                    alpha: _alphaSurfaceStrong,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.overlay(context, _alphaBorderSoft),
                    ),
                  ),
                  boxShadow: AppShadows.soft(
                    context,
                    blur: AppSpacing.xxxl,
                    y: -AppSpacing.s2.toDouble(),
                    alpha: _alphaShadowSoft,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConfirmPaymentScreen(
                            title: widget.title,
                            amountNgn: widget.amountNgn,
                            includeServiceCharge: widget.includeServiceCharge,
                            methodLabel: _methodLabel,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Pay ${_fmt(widget.amountNgn)}",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary(context),
          ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.onTap,
    required this.alphaSurfaceStrong,
    required this.alphaSurfaceSoft,
    required this.alphaBorderSoft,
    required this.alphaShadowSoft,
  });

  final String title;
  final String subtitle;
  final IconData leading;
  final bool selected;
  final VoidCallback onTap;

  final double alphaSurfaceStrong;
  final double alphaSurfaceSoft;
  final double alphaBorderSoft;
  final double alphaShadowSoft;

  @override
  Widget build(BuildContext context) {
    final bgAlpha = selected ? alphaSurfaceStrong : alphaSurfaceSoft;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: bgAlpha),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: alphaShadowSoft,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: AppSizes.iconButtonBox,
              width: AppSizes.iconButtonBox,
              decoration: BoxDecoration(
                color: AppColors.overlay(
                  context,
                  AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md),
                ),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: AppColors.overlay(
                    context,
                    AppSpacing.xs / AppSpacing.xxxl,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                leading,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted(context)
                              .withValues(alpha: 0.92),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: selected ? AppColors.brandBlueSoft : AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostTile extends StatelessWidget {
  const _GhostTile({
    required this.icon,
    required this.text,
    required this.alphaSurfaceStrong,
    required this.alphaBorderSoft,
    required this.alphaShadowSoft,
    required this.onTap,
  });

  final IconData icon;
  final String text;

  final double alphaSurfaceStrong;
  final double alphaBorderSoft;
  final double alphaShadowSoft;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: alphaSurfaceStrong),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
          boxShadow: AppShadows.soft(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: alphaShadowSoft,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary(context)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(context),
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}