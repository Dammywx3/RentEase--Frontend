import 'package:flutter/material.dart';

import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';

import 'payment_success_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_sizes.dart';

class ConfirmPaymentScreen extends StatefulWidget {
  const ConfirmPaymentScreen({
    super.key,
    required this.title,
    required this.amountNgn,
    required this.includeServiceCharge,
    required this.methodLabel,
  });

  final String title;
  final int amountNgn;
  final bool includeServiceCharge;
  final String methodLabel;

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  bool _full = true;

  // --- Explore-style alpha helpers (no hardcoded opacity) ---
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

  int get _fee => widget.includeServiceCharge ? 0 : 0; // demo
  int get _total => widget.amountNgn + _fee;

  void _confirmPay() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          receiptId: "6300121679",
          title: widget.title,
          amountNgn: _total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.pageBgGradient(context),
      ),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        appBar: const AppTopBar(
          title: 'Confirm Payment',
        ),
        scroll: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.sm,
          AppSpacing.screenH,
          AppSizes.screenBottomPad,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),

            // Summary card
            _GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenV),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rent",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RowLine(
                      left: "Tenancy:",
                      right: _fmt(widget.amountNgn),
                    ),
                    const SizedBox(height: AppSpacing.s10),
                    _RowLine(left: "Tenancy", right: widget.title),
                    const SizedBox(height: AppSpacing.s10),
                    _RowLine(left: "Fees:", right: _fmt(_fee)),
                    const SizedBox(height: AppSpacing.s10),
                    _RowLine(left: "Total:", right: _fmt(_total)),
                    const SizedBox(height: AppSpacing.s10),
                    _RowLine(
                      left: "Method:",
                      right: widget.methodLabel,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              "Choose what to pay",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.s10),

            _Choice(
              label: "Full rent (${_fmt(widget.amountNgn)})",
              selected: _full,
              onTap: () => setState(() => _full = true),
            ),
            const SizedBox(height: AppSpacing.s10),
            _Choice(
              label: "Part payment",
              selected: !_full,
              onTap: () => setState(() => _full = false),
            ),

            const SizedBox(height: AppSpacing.lg),

            // CTA
            SizedBox(
              width: double.infinity,
              child: Material(
                color: AppColors.brandGreenDeep.withValues(alpha: _alphaSurfaceSoft),
                borderRadius: BorderRadius.circular(AppRadii.button),
                child: InkWell(
                  onTap: _confirmPay,
                  borderRadius: BorderRadius.circular(AppRadii.button),
                  child: Container(
                    height: AppSizes.pillButtonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                      border: Border.all(
                        color: AppColors.overlay(context, _alphaBorderSoft),
                      ),
                      boxShadow: AppShadows.soft(
                        context,
                        blur: AppSpacing.xxxl,
                        y: AppSpacing.xl,
                        alpha: _alphaShadowSoft,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Confirm & Pay",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Small note (optional, consistent muted text)
            Text(
              "You can review details above before confirming.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted(context).withValues(alpha: 0.92),
                  ),
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _RowLine extends StatelessWidget {
  const _RowLine({required this.left, required this.right});
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted(context),
                ),
          ),
        ),
        Expanded(
          child: Text(
            right,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  // Explore-style alpha helpers
  double get _alphaSelected => AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md);
  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.brandBlueSoft.withValues(alpha: _alphaSelected)
        : AppColors.surface(context).withValues(alpha: _alphaSurfaceSoft);

    final border = selected
        ? AppColors.brandBlueSoft.withValues(alpha: _alphaSelected)
        : AppColors.overlay(context, _alphaBorderSoft);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                ),
              ),
              _CheckBox(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.selected});
  final bool selected;

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    final fill = selected
        ? AppColors.brandBlueSoft
        : Colors.transparent;

    final stroke = selected
        ? AppColors.brandBlueSoft
        : AppColors.overlay(context, _alphaBorderSoft);

    return Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadii.xxs),
        border: Border.all(color: stroke),
      ),
      child: selected
          ? const Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.white,
            )
          : null,
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: _alphaSurfaceStrong),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, _alphaBorderSoft)),
        boxShadow: AppShadows.lift(
          context,
          blur: AppSpacing.xxxl,
          y: AppSpacing.xl,
          alpha: _alphaShadowSoft,
        ),
      ),
      child: child,
    );
  }
}