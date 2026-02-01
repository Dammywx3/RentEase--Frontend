// lib/features/tenant/applications/my_applications_screen.dart
import "package:flutter/material.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_sizes.dart";
import "../../../core/theme/app_spacing.dart";

import "application_detail_screen.dart";

enum ApplicationStatus { submitted, inReview, approved, rejected }

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.propertyTitle,
    required this.location,
    required this.rentText,
    required this.submittedAt,
    required this.status,
    required this.agentName,
    this.thumbnailAssetPath,
  });

  final String id;
  final String propertyTitle;
  final String location;
  final String rentText;
  final DateTime submittedAt;
  final ApplicationStatus status;
  final String agentName;
  final String? thumbnailAssetPath;
}

enum ApplicationsTab { all, pending, approved, rejected }

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({
    super.key,
    this.applications = const [],
    this.initialTab = ApplicationsTab.all,
    this.useDemoWhenEmpty = true,
    this.enableSearch = true,
    this.enableFilter = true,
  });

  /// Pass real backend items here.
  final List<ApplicationModel> applications;

  /// ✅ After submitting, open pending by default from caller:
  /// MyApplicationsScreen(initialTab: ApplicationsTab.pending)
  final ApplicationsTab initialTab;

  /// UI dev friendly.
  final bool useDemoWhenEmpty;

  /// Optional icons in top bar.
  final bool enableSearch;
  final bool enableFilter;

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late ApplicationsTab _tab = widget.initialTab;

  List<ApplicationModel> _demo() {
    final now = DateTime.now();
    return [
      ApplicationModel(
        id: "APP-1001",
        propertyTitle: "Modern 2-Bed Apartment",
        location: "Lekki, Lagos",
        rentText: "₦450,000/mo",
        submittedAt: now.subtract(const Duration(days: 3)),
        status: ApplicationStatus.inReview,
        agentName: "Chinedu Okafor",
        thumbnailAssetPath: "assets/images/listing_011.png",
      ),
      ApplicationModel(
        id: "APP-1002",
        propertyTitle: "Cozy Studio Apartment",
        location: "Magodo, Lagos",
        rentText: "₦230,000/mo",
        submittedAt: now.subtract(const Duration(days: 5)),
        status: ApplicationStatus.submitted,
        agentName: "Aisha Bello",
        thumbnailAssetPath: "assets/images/listing_011.png",
      ),
      ApplicationModel(
        id: "APP-0999",
        propertyTitle: "3-Bed Terrace House",
        location: "Ikoyi, Lagos",
        rentText: "₦800,000/mo",
        submittedAt: now.subtract(const Duration(days: 9)),
        status: ApplicationStatus.rejected,
        agentName: "Emeka Nwosu",
        thumbnailAssetPath: "assets/images/listing_011.png",
      ),
      ApplicationModel(
        id: "APP-0988",
        propertyTitle: "1-Bed Serviced Flat",
        location: "VI, Lagos",
        rentText: "₦520,000/mo",
        submittedAt: now.subtract(const Duration(days: 12)),
        status: ApplicationStatus.approved,
        agentName: "Kemi Adeyemi",
        thumbnailAssetPath: "assets/images/listing_011.png",
      ),
    ];
  }

  List<ApplicationModel> get _source {
    if (widget.applications.isNotEmpty) return widget.applications;
    if (widget.useDemoWhenEmpty) return _demo();
    return const [];
  }

  bool _isPending(ApplicationStatus s) =>
      s == ApplicationStatus.submitted || s == ApplicationStatus.inReview;

  List<ApplicationModel> get _filtered {
    final all = _source;

    switch (_tab) {
      case ApplicationsTab.all:
        return [...all]..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

      case ApplicationsTab.pending:
        return all.where((a) => _isPending(a.status)).toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

      case ApplicationsTab.approved:
        return all.where((a) => a.status == ApplicationStatus.approved).toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

      case ApplicationsTab.rejected:
        return all.where((a) => a.status == ApplicationStatus.rejected).toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    }
  }

  int get _pendingCount => _source.where((a) => _isPending(a.status)).length;

  String _submittedLabel(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return "Submitted: ${loc.formatShortMonthDay(dt)}";
  }

  void _openDetails(ApplicationModel a) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ApplicationDetailScreen(application: a),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Stack(
      children: [
        // ✅ Option A: gradient BEHIND the entire page (top bar + safe-area included)
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
            title: "My Applications",
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
            actions: [
              if (widget.enableSearch)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s10),
                  child: _TopIcon(
                    icon: Icons.search_rounded,
                    onTap: () {
                      // wire later
                    },
                  ),
                ),
              if (widget.enableFilter)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.screenH),
                  child: _TopIcon(
                    icon: Icons.tune_rounded,
                    onTap: () {
                      // wire later
                    },
                  ),
                ),
            ],
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
              _Tabs(
                value: _tab,
                pendingCount: _pendingCount,
                onChanged: (t) => setState(() => _tab = t),
              ),
              const SizedBox(height: AppSpacing.md),

              if (_tab == ApplicationsTab.pending)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    "${items.length} Pending",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ),

              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxl),
                  child: Center(
                    child: Text(
                      "No applications yet",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ),
                )
              else
                ...items.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ApplicationCard(
                      application: a,
                      submittedLabel: _submittedLabel(context, a.submittedAt),
                      onTap: () => _openDetails(a),
                      onViewDetails: () => _openDetails(a),
                      onMessageAgent: () {
                        // wire later
                      },
                      onWithdraw: () {
                        // wire later (confirm dialog)
                      },
                      onPayNow: () {
                        // wire later
                      },
                      onViewTenancyTerms: () {
                        // wire later
                      },
                      onViewReason: () {
                        _openDetails(a);
                      },
                      onBrowseSimilar: () {
                        // wire later
                      },
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

/* -------------------------- Top widgets -------------------------- */

class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      onTap: onTap,
      child: Container(
        height: AppSizes.iconButtonBox,
        width: AppSizes.iconButtonBox,
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.overlay(context, 0.06)),
          boxShadow: AppShadows.soft(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: Icon(icon, color: AppColors.textMuted(context), size: 20),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.value,
    required this.pendingCount,
    required this.onChanged,
  });

  final ApplicationsTab value;
  final int pendingCount;
  final ValueChanged<ApplicationsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(ApplicationsTab t, String label) {
      final selected = value == t;
      final bg = selected
          ? AppColors.brandBlueSoft.withValues(alpha: 0.22)
          : AppColors.surface(context).withValues(alpha: 0.55);

      return Expanded(
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: InkWell(
            onTap: () => onChanged(t),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // keep label text-only (avoid hardcoding counts into UI unless you want it later)
    final pendingLabel = "Pending";

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.surface(context).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          tab(ApplicationsTab.all, "All"),
          const SizedBox(width: AppSpacing.sm),
          tab(ApplicationsTab.pending, pendingLabel),
          const SizedBox(width: AppSpacing.sm),
          tab(ApplicationsTab.approved, "Approved"),
          const SizedBox(width: AppSpacing.sm),
          tab(ApplicationsTab.rejected, "Rejected"),
        ],
      ),
    );
  }
}

/* -------------------------- Card -------------------------- */

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.submittedLabel,
    required this.onTap,
    required this.onViewDetails,
    required this.onMessageAgent,
    required this.onWithdraw,
    required this.onPayNow,
    required this.onViewTenancyTerms,
    required this.onViewReason,
    required this.onBrowseSimilar,
  });

  final ApplicationModel application;
  final String submittedLabel;

  final VoidCallback onTap;

  // Actions
  final VoidCallback onViewDetails;
  final VoidCallback onMessageAgent;
  final VoidCallback onWithdraw;

  final VoidCallback onPayNow;
  final VoidCallback onViewTenancyTerms;

  final VoidCallback onViewReason;
  final VoidCallback onBrowseSimilar;

  int _stageFor(ApplicationStatus s) {
    // Submitted -> Review -> Decision
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

  @override
  Widget build(BuildContext context) {
    final badge = _StatusBadge.from(context, application.status);
    final stage = _stageFor(application.status);

    final isPending =
        application.status == ApplicationStatus.submitted ||
        application.status == ApplicationStatus.inReview;

    return _FrostCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: Container(
                      height: AppSizes.listThumbSize,
                      width: AppSizes.listThumbSize + AppSpacing.sm,
                      color: AppColors.tenantPanel.withValues(alpha: 0.85),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.home_rounded,
                        color: AppColors.brandBlueSoft,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.propertyTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          application.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted(context),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.s6),
                        Text(
                          application.rentText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy.withValues(alpha: 0.90),
                              ),
                        ),
                      ],
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

              const SizedBox(height: AppSpacing.md),

              // Mini timeline (Submitted → Review → Decision)
              _MiniProgress(stage: stage),

              const SizedBox(height: AppSpacing.s10),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      submittedLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted(
                          context,
                        ).withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                  if (isPending)
                    InkWell(
                      onTap: onWithdraw,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.s6,
                        ),
                        child: Text(
                          "Withdraw",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMuted(context),
                              ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Status-specific actions
              if (isPending) ...[
                Row(
                  children: [
                    Expanded(
                      child: _CardButton(
                        text: "View details",
                        filled: true,
                        color: AppColors.brandBlueSoft,
                        onTap: onViewDetails,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: _CardButton(
                        text: "Message agent",
                        filled: false,
                        color: AppColors.brandBlueSoft,
                        onTap: onMessageAgent,
                        icon: Icons.chat_bubble_rounded,
                      ),
                    ),
                  ],
                ),
              ] else if (application.status == ApplicationStatus.approved) ...[
                Row(
                  children: [
                    Expanded(
                      child: _CardButton(
                        text: "Pay now",
                        filled: true,
                        color: AppColors.brandGreenDeep,
                        onTap: onPayNow,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: _CardButton(
                        text: "Tenancy terms",
                        filled: false,
                        color: AppColors.brandGreenDeep,
                        onTap: onViewTenancyTerms,
                        icon: Icons.description_rounded,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _CardButton(
                        text: "View reason",
                        filled: true,
                        color: AppColors.tenantDangerSoft,
                        onTap: onViewReason,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: _CardButton(
                        text: "Browse similar",
                        filled: false,
                        color: AppColors.brandBlueSoft,
                        onTap: onBrowseSimilar,
                        icon: Icons.search_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.stage});
  final int stage;

  Color _activeDot(BuildContext context, int idx) {
    if (idx < stage) return AppColors.brandBlueSoft;
    if (idx == stage && stage == 2) return AppColors.brandGreenDeep;
    if (idx == stage) return AppColors.brandBlueSoft;
    return AppColors.textMutedLight.withValues(alpha: 0.35);
  }

  @override
  Widget build(BuildContext context) {
    Widget dot(int i) {
      final c = _activeDot(context, i);
      return Container(
        height: AppSpacing.md,
        width: AppSpacing.md,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: c.withValues(alpha: 0.70), width: 2),
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

/* -------------------------- Small UI -------------------------- */

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.text,
    required this.filled,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String text;
  final bool filled;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: filled ? AppColors.white : AppColors.navy,
              ),
              const SizedBox(width: AppSpacing.s6),
            ],
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: filled ? AppColors.white : AppColors.navy,
              ),
            ),
          ],
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
      color: AppColors.surface(context).withValues(alpha: 0.70),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: AppColors.surface(context).withValues(alpha: 0.55),
          ),
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
        // ✅ Don’t hardcode a new color token; fall back to an existing theme color.
        // If you DO have AppColors.brandOrange, it will use it. If not, use brandBlueSoft.
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
