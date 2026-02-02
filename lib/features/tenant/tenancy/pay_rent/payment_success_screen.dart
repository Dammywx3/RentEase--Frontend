import "package:flutter/material.dart";

import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

import '../../../../core/utils/money_format.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.receiptId,
    required this.title,
    required this.amountNgn,
  });

  final String receiptId;
  final String title;
  final int amountNgn;

  // ---------- Explore-style computed alphas ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  String _fmtNow(BuildContext context) {
    final when = DateTime.now();
    final loc = MaterialLocalizations.of(context);

    // Ex: "Feb 2, 2026 • 10:45 AM"
    final date = loc.formatShortMonthDay(when);
    final time = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(when),
      alwaysUse24HourFormat: false,
    );
    return "$date • $time";
  }

  @override
  Widget build(BuildContext context) {
    final paidText = fmtMoneyCompact(amountNgn, currencyCode: 'NGN');

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
          topBar: const AppTopBar(title: 'Payment Success'),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
              AppSizes.screenBottomPad,
            ),
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ✅ Success icon (Explore-style surface + border + shadow)
              Center(
                child: Container(
                  height: AppSpacing.xxxl + AppSpacing.lg,
                  width: AppSpacing.xxxl + AppSpacing.lg,
                  decoration: BoxDecoration(
                    color: AppColors.brandGreenDeep.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.overlay(context, _alphaBorderSoft),
                    ),
                    boxShadow: AppShadows.lift(
                      context,
                      blur: AppSpacing.xxxl,
                      y: AppSpacing.xl,
                      alpha: _alphaShadowSoft,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.brandGreenDeep,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              Center(
                child: Text(
                  "Payment Successful",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Center(
                child: Text(
                  "Receipt ID: $receiptId",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted(context).withValues(alpha: 0.92),
                      ),
                ),
              ),

              const SizedBox(height: AppSpacing.s6),

              Center(
                child: Text(
                  _fmtNow(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted(context).withValues(alpha: 0.92),
                      ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ✅ Frost card summary (Explore style)
              _FrostCard(
                alphaSurface: _alphaSurfaceStrong,
                alphaBorder: _alphaBorderSoft,
                alphaShadow: _alphaShadowSoft,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Paid",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        paidText,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.brandGreenDeep,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary(context),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ✅ Buttons (Explore-like pill buttons)
              _PrimaryPillButton(
                text: "Download receipt",
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              _SecondaryPillButton(
                text: "View transactions",
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              _SecondaryPillButton(
                text: "Back to tenancy",
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),

              const SizedBox(height: AppSpacing.lg),

              Center(
                child: Text(
                  "Paid: $paidText • $title",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted(context).withValues(alpha: 0.92),
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

// ---------------- Explore-style UI helpers ----------------

class _FrostCard extends StatelessWidget {
  const _FrostCard({
    required this.child,
    required this.alphaSurface,
    required this.alphaBorder,
    required this.alphaShadow,
  });

  final Widget child;
  final double alphaSurface;
  final double alphaBorder;
  final double alphaShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.overlay(context, alphaBorder),
        ),
        boxShadow: AppShadows.lift(
          context,
          blur: AppSpacing.xxxl,
          y: AppSpacing.xl,
          alpha: alphaShadow,
        ),
      ),
      child: child,
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Material(
      color: disabled
          ? AppColors.tenantBorderMuted.withValues(alpha: 0.28)
          : AppColors.brandGreenDeep.withValues(alpha: 0.80),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          height: AppSizes.pillButtonHeight,
          width: double.infinity,
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: disabled ? AppColors.mutedMid : AppColors.white,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryPillButton extends StatelessWidget {
  const _SecondaryPillButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final a = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final b = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return Material(
      color: AppColors.surface(context).withValues(alpha: a),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: Container(
          height: AppSizes.pillButtonHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.button),
            border: Border.all(color: AppColors.overlay(context, b)),
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}