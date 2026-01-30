// ignore_for_file: unnecessary_underscores

import "package:flutter/material.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";

import "../../../shared/models/viewing_model.dart";
import "viewing_detail_screen.dart";

// ✅ IMPORTANT: path to your apply flow file
import "../applications/apply_flow_screens.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_sizes.dart";

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({
    super.key,
    this.viewings = const [],
    this.title,
    this.useDemoWhenEmpty = true, // ✅ NEW: so it never looks empty while wiring backend
  });

  /// Data-driven: pass real backend viewings here.
  final List<ViewingModel> viewings;

  /// Optional override (still a screen name)
  final String? title;

  /// If true and [viewings] is empty, we show demo items (good for UI dev).
  final bool useDemoWhenEmpty;

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

enum _Tab { upcoming, completed }

class _ViewingsScreenState extends State<ViewingsScreen> {
  _Tab _tab = _Tab.upcoming;

  int _parseMonthlyRent(String? priceText) {
    if (priceText == null) return 0;
    final raw = priceText.replaceAll(RegExp(r"[^0-9]"), "");
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  List<ViewingModel> _demoViewings() {
    final now = DateTime.now();

    return [
      ViewingModel(
        id: "VIS-1001",
        listingTitle: "2 Bedroom Apartment",
        location: "Lekki Phase 1, Lagos",
        agentName: "Chinedu Okafor",
        dateTime: now.add(const Duration(days: 1, hours: 3)),
        status: ViewingStatus.confirmed,
        priceText: "₦850,000 / year",
      ),
      ViewingModel(
        id: "VIS-1002",
        listingTitle: "Mini Flat",
        location: "Yaba, Lagos",
        agentName: "Aisha Bello",
        dateTime: now.add(const Duration(days: 4, hours: 2)),
        status: ViewingStatus.requested,
        priceText: "₦500,000 / year",
      ),
      ViewingModel(
        id: "VIS-0999",
        listingTitle: "Studio Apartment",
        location: "Gwarinpa, Abuja",
        agentName: "Emeka Nwosu",
        dateTime: now.subtract(const Duration(days: 5)),
        status: ViewingStatus.completed,
        priceText: "₦300,000 / year",
      ),
    ];
  }

  List<ViewingModel> get _source {
    if (widget.viewings.isNotEmpty) return widget.viewings;
    if (widget.useDemoWhenEmpty) return _demoViewings();
    return const [];
  }

  List<ViewingModel> get _filtered {
    final all = _source;

    switch (_tab) {
      case _Tab.upcoming:
        final list = all
            .where(
              (v) =>
                  v.status == ViewingStatus.requested ||
                  v.status == ViewingStatus.confirmed,
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return list;

      case _Tab.completed:
        final list = all
            .where(
              (v) =>
                  v.status == ViewingStatus.completed ||
                  v.status == ViewingStatus.cancelled,
            )
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
        return list;
    }
  }

  String _fmtLine1(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    final time = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: false,
    );
    return "${loc.formatFullDate(dt)} • $time";
  }

  String _fmtLine2(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatShortDate(dt);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Stack(
      children: [
        // ✅ Option A: Gradient BEHIND the entire screen (including top bar / safe-area)
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
          // ✅ Use your AppTopBar (only screen name in the middle + back arrow)
          topBar: AppTopBar(
            title: widget.title ?? "Viewings",
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
            actions: const [],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenV,
                  AppSpacing.sm,
                  AppSpacing.screenV,
                  AppSpacing.md,
                ),
                child: _Tabs(
                  value: _tab,
                  onChanged: (t) => setState(() => _tab = t),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          "No viewings yet",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textMuted(context),
                                  ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenV,
                          AppSpacing.sm,
                          AppSpacing.screenV,
                          AppSizes.screenBottomPad,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, i) {
                          final v = items[i];
                          final badge = _ViewingBadge.from(context, v.status);

                          final showApplyNow =
                              v.status == ViewingStatus.completed;

                          return _ViewingCard(
                            title: v.listingTitle,
                            line1: _fmtLine1(context, v.dateTime),
                            line2: _fmtLine2(context, v.dateTime),
                            location: v.location,
                            badge: badge,
                            status: v.status,
                            showApplyNow: showApplyNow,
                            onApplyNow: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ApplyPreCheckScreen(
                                    listing: ApplyListingVM(
                                      id: v.id,
                                      title: v.listingTitle,
                                      location: v.location,
                                      rentPerMonthNgn:
                                          _parseMonthlyRent(v.priceText),
                                      priceText: v.priceText ?? "",
                                      photoAssetPath:
                                          "assets/images/listing_011.png",
                                    ),
                                    guarantorRequiredThresholdNgn: 500000,
                                  ),
                                ),
                              );
                            },
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ViewingDetailScreen(viewing: v),
                                ),
                              );
                            },
                            onDirections: () {},
                            onReschedule: () {},
                            onCancel: () {},
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});
  final _Tab value;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(_Tab t, String label) {
      final selected = value == t;

      final bg = selected
          ? AppColors.brandBlueSoft.withValues(alpha: 0.24)
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
          tab(_Tab.upcoming, "Upcoming"),
          const SizedBox(width: AppSpacing.sm),
          tab(_Tab.completed, "Completed"),
        ],
      ),
    );
  }
}

// --- card code ---

class _ViewingCard extends StatelessWidget {
  const _ViewingCard({
    required this.title,
    required this.line1,
    required this.line2,
    required this.location,
    required this.badge,
    required this.status,
    required this.showApplyNow,
    required this.onApplyNow,
    required this.onTap,
    required this.onDirections,
    required this.onReschedule,
    required this.onCancel,
  });

  final String title;
  final String line1;
  final String line2;
  final String location;

  final _ViewingBadge badge;
  final ViewingStatus status;

  final bool showApplyNow;
  final VoidCallback onApplyNow;

  final VoidCallback onTap;
  final VoidCallback onDirections;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == ViewingStatus.completed;

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
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.s6),
                        Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              size: AppSizes.minTap / 3,
                              color: AppColors.tenantDangerDeep,
                            ),
                            const SizedBox(width: AppSpacing.s6),
                            Expanded(
                              child: Text(
                                line1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textMuted(context),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s6),
                        Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brandBlueSoft,
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

              // ✅ RULE:
              // - If Completed => hide Reschedule and show Apply Now
              // - If NOT Completed => show Reschedule and hide Apply Now
              Wrap(
                spacing: AppSpacing.s10,
                runSpacing: AppSpacing.s10,
                children: [
                  _MiniAction(
                    icon: Icons.directions_rounded,
                    text: "Directions",
                    onTap: onDirections,
                  ),
                  if (!isCompleted)
                    _MiniAction(
                      icon: Icons.schedule_rounded,
                      text: "Reschedule",
                      onTap: onReschedule,
                    ),
                  _MiniAction(
                    icon: Icons.close_rounded,
                    text: "Cancel",
                    onTap: onCancel,
                    textColor: AppColors.tenantDangerSoft,
                    iconColor: AppColors.tenantDangerSoft,
                  ),
                  if (isCompleted && showApplyNow)
                    _MiniAction(
                      icon: Icons.assignment_rounded,
                      text: "Apply Now",
                      onTap: onApplyNow,
                      textColor: AppColors.brandGreenDeep,
                      iconColor: AppColors.brandGreenDeep,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final tc = textColor ?? AppColors.navy;
    final ic = iconColor ?? AppColors.textMuted(context);

    return Material(
      color: AppColors.overlay(context, 0.04),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.s10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: ic),
              const SizedBox(width: AppSpacing.sm),
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: tc,
                    ),
              ),
            ],
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
      color: AppColors.surface(context).withValues(alpha: 0.70),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: AppColors.surface(context).withValues(alpha: 0.55),
          ),
          boxShadow: AppShadows.lift(
            context,
            blur: 18,
            y: 10,
            alpha: 0.08,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _ViewingBadge {
  const _ViewingBadge({required this.label, required this.color});

  final String label;
  final Color color;

  static _ViewingBadge from(BuildContext context, ViewingStatus status) {
    switch (status) {
      case ViewingStatus.requested:
        return const _ViewingBadge(
          label: "Requested",
          color: AppColors.brandBlueSoft,
        );
      case ViewingStatus.confirmed:
        return const _ViewingBadge(
          label: "Confirmed",
          color: AppColors.brandGreenDeep,
        );
      case ViewingStatus.completed:
        return const _ViewingBadge(
          label: "Completed",
          color: AppColors.brandGreenDeep,
        );
      case ViewingStatus.cancelled:
        return const _ViewingBadge(
          label: "Cancelled",
          color: AppColors.textMutedLight,
        );
    }
  }
}