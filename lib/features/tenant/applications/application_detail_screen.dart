// lib/features/tenant/applications/application_detail_screen.dart
import "package:flutter/material.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_sizes.dart";
import "../../../core/theme/app_spacing.dart";

import "../../../shared/models/application_model.dart";

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({
    super.key,
    required this.application,
    this.onWithdraw,
  });

  final ApplicationModel application;
  final VoidCallback? onWithdraw;

  _Badge _badge(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.pending:
        return const _Badge(label: "Pending", color: AppColors.brandBlueSoft);
      case ApplicationStatus.approved:
        return const _Badge(label: "Approved", color: AppColors.brandGreenDeep);
      case ApplicationStatus.rejected:
        return const _Badge(label: "Rejected", color: AppColors.tenantDangerSoft);
      case ApplicationStatus.withdrawn:
        return const _Badge(label: "Withdrawn", color: AppColors.textMutedLight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badge(application.status);

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
            title: "Application",
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenV,
              AppSpacing.sm,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Application Details",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s10,
                              vertical: AppSpacing.s7,
                            ),
                            decoration: BoxDecoration(
                              color: badge.color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                              border: Border.all(color: badge.color.withValues(alpha: 0.22)),
                            ),
                            child: Text(
                              badge.label,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: badge.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _kv(context, "ID", application.id),
                      _kv(context, "Listing ID", application.listingId),
                      _kv(context, "Property ID", application.propertyId),
                      _kv(context, "Applicant ID", application.applicantId),
                      _kv(context, "Status", application.status.label),
                      _kv(context, "Move-in date", application.moveInDate ?? "—"),
                      _kv(context, "Monthly income", application.monthlyIncome?.toString() ?? "—"),
                      _kv(context, "Message", (application.message?.trim().isNotEmpty ?? false) ? application.message!.trim() : "—"),
                      _kv(context, "Created", application.createdAt?.toIso8601String() ?? "—"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (onWithdraw != null)
                _PillButton(
                  text: "Withdraw",
                  filled: false,
                  color: AppColors.tenantDangerSoft,
                  onTap: onWithdraw!,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              k,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted(context),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.text,
    required this.filled,
    required this.color,
    required this.onTap,
  });

  final String text;
  final bool filled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: AppSizes.minTap,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.80) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: filled ? AppColors.white : AppColors.navy,
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
      color: AppColors.surface(context).withValues(alpha: 0.68),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, 0.05)),
          boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: child,
      ),
    );
  }
}