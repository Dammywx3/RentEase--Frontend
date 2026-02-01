// lib/features/tenant/applications/application_detail_screen.dart
import "package:flutter/material.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_sizes.dart";
import "../../../core/theme/app_spacing.dart";

import "my_applications_screen.dart";

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key, required this.application});

  final ApplicationModel application;

  int _stageFor(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.submitted:
        return 0;
      case ApplicationStatus.inReview:
        return 1;
      case ApplicationStatus.approved:
      case ApplicationStatus.rejected:
        return 2;
    }
  }

  String _fullDate(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatFullDate(dt);
  }

  bool get _isApproved => application.status == ApplicationStatus.approved;
  bool get _isRejected => application.status == ApplicationStatus.rejected;
  bool get _isPending =>
      application.status == ApplicationStatus.submitted ||
      application.status == ApplicationStatus.inReview;

  @override
  Widget build(BuildContext context) {
    final stage = _stageFor(application.status);
    final badge = _StatusBadge.from(context, application.status);

    return Stack(
      children: [
        // ✅ Option A: gradient behind the entire page (including top safe-area + top bar)
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
            actions: const [],
          ),

          // ✅ No inner DecoratedBox needed; prevents black top-area on non-shell routes
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenV,
              AppSpacing.sm,
              AppSpacing.screenV,
              AppSizes.screenBottomPad,
            ),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: AspectRatio(
                  aspectRatio: 1 / AppSizes.featuredCardAspect,
                  child: Container(
                    color: AppColors.tenantPanel.withValues(alpha: 0.85),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.home_rounded,
                      size: 64,
                      color: AppColors.brandBlueSoft,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.screenV),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      application.propertyTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s10,
                      vertical: AppSpacing.s7,
                    ),
                    decoration: BoxDecoration(
                      color: badge.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: badge.color.withValues(alpha: 0.22),
                      ),
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
              const SizedBox(height: AppSpacing.s6),
              Text(
                "${application.location} • ${application.rentText}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted(context),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Timeline(stage: stage),
                      const SizedBox(height: AppSpacing.s10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _TL(text: "Submitted"),
                          _TL(text: "Review"),
                          _TL(text: "Decision"),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Text(
                        "Submitted on ${_fullDate(context, application.submittedAt)}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.screenV),

              _Section(
                title: "Applicant & Guarantor",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _KV(label: "Applicant", value: "—"),
                    const _KV(label: "Guarantor", value: "—"),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Wire this from your application flow (personal + guarantor step).",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              _Section(
                title: "Uploaded Documents",
                child: Column(
                  children: const [
                    _DocRow(title: "ID document", status: "Uploaded"),
                    SizedBox(height: AppSpacing.s10),
                    _DocRow(title: "Proof of income", status: "Uploaded"),
                    SizedBox(height: AppSpacing.s10),
                    _DocRow(title: "Utility bill", status: "Pending"),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              _Section(
                title: "Messages",
                child: Text(
                  "Thread with agent: ${application.agentName} (wire later).",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.screenV),

              if (_isApproved)
                _PillButton(
                  text: "Pay now  ›",
                  filled: true,
                  color: AppColors.brandGreenDeep,
                  onTap: () {
                    // wire later
                  },
                )
              else if (_isRejected)
                Row(
                  children: [
                    Expanded(
                      child: _PillButton(
                        text: "View reason",
                        filled: true,
                        color: AppColors.tenantDangerSoft,
                        onTap: () {
                          // wire later
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _PillButton(
                        text: "Browse similar",
                        filled: false,
                        color: AppColors.brandBlueSoft,
                        onTap: () {
                          // wire later
                        },
                      ),
                    ),
                  ],
                )
              else if (_isPending)
                Row(
                  children: [
                    Expanded(
                      child: _PillButton(
                        text: "Message agent",
                        filled: true,
                        color: AppColors.brandBlueSoft,
                        onTap: () {
                          // wire later
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _PillButton(
                        text: "Withdraw",
                        filled: false,
                        color: AppColors.tenantDangerSoft,
                        onTap: () {
                          // wire later
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/* -------------------------- UI bits -------------------------- */

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted(context),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({required this.title, required this.status});
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    final ok = status.toLowerCase().contains("upload");

    // ✅ No hardcoding: if you have brandOrange use it; otherwise fallback to brandBlueSoft.
    final Color pendingColor = ok
        ? AppColors.brandGreenDeep
        : AppColors.brandBlueSoft;

    final c = pendingColor;

    return Row(
      children: [
        Icon(Icons.description_rounded, color: c, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.s6,
          ),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: c.withValues(alpha: 0.22)),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: c,
            ),
          ),
        ),
      ],
    );
  }
}

class _TL extends StatelessWidget {
  const _TL({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.navy,
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.stage});
  final int stage;

  Color _dotColor(int idx) {
    if (idx < stage) return AppColors.brandBlueSoft;
    if (idx == stage && stage == 2) return AppColors.brandGreenDeep;
    if (idx == stage) return AppColors.brandBlueSoft;
    return AppColors.textMutedLight.withValues(alpha: 0.35);
  }

  @override
  Widget build(BuildContext context) {
    Widget dot(int i) {
      final c = _dotColor(i);
      return Container(
        height: AppSpacing.md,
        width: AppSpacing.md,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: c.withValues(alpha: 0.75), width: 2),
        ),
      );
    }

    Widget line(bool active) {
      return Expanded(
        child: Container(
          height: AppSpacing.s2,
          color: active
              ? AppColors.brandBlueSoft
              : AppColors.textMutedLight.withValues(alpha: 0.25),
        ),
      );
    }

    return Row(
      children: [
        dot(0),
        const SizedBox(width: AppSpacing.sm),
        line(stage >= 1),
        const SizedBox(width: AppSpacing.sm),
        dot(1),
        const SizedBox(width: AppSpacing.sm),
        line(stage >= 2),
        const SizedBox(width: AppSpacing.sm),
        dot(2),
      ],
    );
  }
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

class _StatusBadge {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  static _StatusBadge from(BuildContext context, ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.submitted:
        return const _StatusBadge(
          label: "Submitted",
          color: AppColors.brandBlueSoft,
        );
      case ApplicationStatus.inReview:
        // ✅ Avoid dependency on a token that might not exist in your theme.
        // If you want a review color later, add a token in AppColors and switch back.
        return const _StatusBadge(
          label: "In Review",
          color: AppColors.brandBlueSoft,
        );
      case ApplicationStatus.approved:
        return const _StatusBadge(
          label: "Approved",
          color: AppColors.brandGreenDeep,
        );
      case ApplicationStatus.rejected:
        return const _StatusBadge(
          label: "Rejected",
          color: AppColors.tenantDangerSoft,
        );
    }
  }
}
