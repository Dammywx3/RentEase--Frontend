// lib/features/tenant/tenancy/tenancy_detail_screen.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

import 'pay_rent/pay_rent_sheet.dart';

class TenancyDetailScreen extends StatelessWidget {
  const TenancyDetailScreen({super.key, required this.tenancy});

  final TenancyVM tenancy;

  // ---- Explore-style alpha helpers (token-derived) ----
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurface =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  @override
  Widget build(BuildContext context) {
    final rawTitle = tenancy.title.trim();
    final title = rawTitle.isEmpty ? 'Tenancy Detail' : rawTitle;

    final subtitle = (tenancy.subtitle ?? '').trim().isEmpty
        ? 'Timeline & actions'
        : tenancy.subtitle!.trim();

    final hasLeaseDoc = (tenancy.leaseDocName ?? '').trim().isNotEmpty;
    final canPayRent = tenancy.nextRentAmountNgn != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.pageBgGradient(context),
      ),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: AppTopBar(
          title: title,
          subtitle: subtitle,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.sm,
            AppSpacing.screenH,
            AppSizes.screenBottomPad,
          ),
          children: [
            const _SectionTitle('Lease Documents'),
            const SizedBox(height: AppSpacing.sm),
            _SurfaceCard(
              child: Row(
                children: [
                  _IconBadge(
                    icon: Icons.picture_as_pdf_rounded,
                    enabled: hasLeaseDoc,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasLeaseDoc ? 'Lease document' : 'No document uploaded',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary(context),
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          hasLeaseDoc
                              ? tenancy.leaseDocName!.trim()
                              : 'Ask your landlord/agent to upload it.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted(context)
                                        .withValues(alpha: 0.92),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _InlineAction(
                    label: 'Open',
                    enabled: hasLeaseDoc,
                    onTap: hasLeaseDoc
                        ? () => ToastService.show(
                              context,
                              'Open lease doc (wire later)',
                              success: true,
                            )
                        : null,
                    alphaSurface: _alphaSurfaceStrong,
                    alphaBorder: _alphaBorderSoft,
                    alphaShadow: _alphaShadowSoft,
                  ),
                ],
              ),
              alphaSurface: _alphaSurface,
              alphaBorder: _alphaBorderSoft,
              alphaShadow: _alphaShadowSoft,
            ),

            const SizedBox(height: AppSpacing.lg),

            const _SectionTitle('Payments'),
            const SizedBox(height: AppSpacing.sm),
            _SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next rent payment',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    canPayRent
                        ? 'Amount is ready. Tap Pay rent to continue.'
                        : 'No upcoming rent amount set.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted(context)
                              .withValues(alpha: 0.92),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Pay rent',
                    onPressed: canPayRent
                        ? () {
                            PayRentSheet.open(
                              context,
                              title: tenancy.title,
                              amountNgn: tenancy.nextRentAmountNgn!,
                            );
                          }
                        : null,
                    fullWidth: true,
                  ),
                ],
              ),
              alphaSurface: _alphaSurface,
              alphaBorder: _alphaBorderSoft,
              alphaShadow: _alphaShadowSoft,
            ),

            const SizedBox(height: AppSpacing.lg),

            const _SectionTitle('End Tenancy'),
            const SizedBox(height: AppSpacing.sm),
            _SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request to end tenancy',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Submit an end request or cancel an existing request.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted(context)
                              .withValues(alpha: 0.92),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Request end tenancy',
                    onPressed: () => ToastService.show(
                      context,
                      'End tenancy form (wire later)',
                      success: true,
                    ),
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    label: 'Cancel request',
                    onPressed: () async {
                      final ok = await DialogService.confirm(
                        context,
                        title: 'Cancel end request?',
                        message: 'Your tenancy will remain active.',
                        confirmText: 'Cancel request',
                        danger: true,
                      );
                      if (ok && context.mounted) {
                        ToastService.show(context, 'Cancelled (demo)',
                            success: true);
                      }
                    },
                    fullWidth: true,
                  ),
                ],
              ),
              alphaSurface: _alphaSurface,
              alphaBorder: _alphaBorderSoft,
              alphaShadow: _alphaShadowSoft,
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/* ----------------- VM ----------------- */

class TenancyVM {
  const TenancyVM({
    required this.id,
    required this.title,
    this.subtitle,
    this.leaseDocName,
    this.nextRentAmountNgn,
  });

  final String id;
  final String title;
  final String? subtitle;

  final String? leaseDocName;
  final int? nextRentAmountNgn;
}

/* ----------------- UI ----------------- */

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary(context),
          ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, alphaBorder)),
        boxShadow: AppShadows.lift(
          context,
          blur: AppSpacing.xxxl + AppSpacing.lg,
          y: AppSpacing.xl,
          alpha: alphaShadow,
        ),
      ),
      child: child,
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.enabled});

  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final a = AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md);

    return Container(
      height: AppSizes.iconButtonBox,
      width: AppSizes.iconButtonBox,
      decoration: BoxDecoration(
        color: AppColors.overlay(
          context,
          enabled ? a : (AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.md)),
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.overlay(
            context,
            AppSpacing.xs / AppSpacing.xxxl,
          ),
        ),
      ),
      child: Icon(
        icon,
        color: enabled
            ? AppColors.textPrimary(context)
            : AppColors.textMuted(context).withValues(alpha: 0.65),
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.alphaSurface,
    required this.alphaBorder,
    required this.alphaShadow,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  final double alphaSurface;
  final double alphaBorder;
  final double alphaShadow;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface(context).withValues(alpha: alphaSurface);
    final border = AppColors.overlay(context, alphaBorder);

    final fg = enabled
        ? AppColors.textPrimary(context)
        : AppColors.textMuted(context).withValues(alpha: 0.55);

    return Material(
      color: enabled ? bg : AppColors.overlay(context, AppSpacing.xs / AppSpacing.xxxl),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: border),
            boxShadow: enabled
                ? AppShadows.soft(
                    context,
                    blur: AppSpacing.xxxl,
                    y: AppSpacing.s2.toDouble(),
                    alpha: alphaShadow,
                  )
                : null,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
          ),
        ),
      ),
    );
  }
}