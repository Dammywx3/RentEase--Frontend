// lib/features/tenant/viewings/viewing_detail_screen.dart
import "package:flutter/material.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";
import "../../../shared/models/viewing_model.dart";

import "../applications/apply_flow_screens.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_sizes.dart";

import "data/viewings_api.dart";

class ViewingDetailScreen extends StatefulWidget {
  const ViewingDetailScreen({super.key, required this.viewing});

  final ViewingModel viewing;

  @override
  State<ViewingDetailScreen> createState() => _ViewingDetailScreenState();
}

class _ViewingDetailScreenState extends State<ViewingDetailScreen> {
  bool _busy = false;

  String _dateOnly(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatShortDate(dt);
  }

  String _fullDateTime(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    final time = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: false,
    );
    return "${loc.formatFullDate(dt)} • $time";
  }

  int _stageFor(ViewingStatus s) {
    switch (s) {
      case ViewingStatus.requested:
        return 0;
      case ViewingStatus.confirmed:
        return 1;
      case ViewingStatus.completed:
        return 2;
      case ViewingStatus.rejected:
        return 0;
      case ViewingStatus.cancelled:
        return 0;
    }
  }

  static int _parseMonthlyRent(String? priceText) {
    if (priceText == null) return 0;
    final raw = priceText.replaceAll(RegExp(r"[^0-9]"), "");
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  Future<void> _cancelVisit() async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      final api = ViewingsApi();
      await api.cancel(widget.viewing.id);

      if (!mounted) return;

      // tell previous screen to refresh
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn’t cancel. ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewing = widget.viewing;

    final price = (viewing.priceText ?? "₦—").trim();
    final dateText = _dateOnly(context, viewing.dateTime);
    final fullDateTime = _fullDateTime(context, viewing.dateTime);

    final isCompleted = viewing.status == ViewingStatus.completed;

    final canCancel =
        viewing.status == ViewingStatus.requested ||
        viewing.status == ViewingStatus.confirmed;

    final stage = _stageFor(viewing.status);
    final badge = _ViewingBadge.from(context, viewing.status);

    return Stack(
      children: [
        // ✅ Gradient behind entire screen
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
            title: "Viewing",
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
            actions: const [],
          ),

          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenV,
              AppSpacing.sm,
              AppSpacing.screenV,
              AppSizes.screenBottomPad,
            ),
            children: [
              // Hero image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1 / AppSizes.featuredCardAspect,
                      child: Container(
                        width: double.infinity,
                        color: AppColors.tenantPanel.withValues(alpha: 0.85),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.home_rounded,
                          size: AppSpacing.xxxl + AppSpacing.xxxl,
                          color: AppColors.brandBlueSoft,
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.screenV,
                      bottom: AppSpacing.screenV,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.overlay(context, 0.35),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Text(
                          price,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.screenV),

              // Title + status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      viewing.listingTitle,
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
              const SizedBox(height: AppSpacing.s10),

              // Date
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenV),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: AppSizes.minTap / 2.4,
                        color: AppColors.tenantDangerDeep,
                      ),
                      const SizedBox(width: AppSpacing.s10),
                      Expanded(
                        child: Text(
                          dateText,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("+ Add to Calendar"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Location
              Text(
                "Location",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenV),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.place_rounded,
                            color: AppColors.brandBlueSoft,
                            size: AppSizes.minTap / 2.6,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              "${viewing.listingTitle}\n${viewing.location}",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: Container(
                          width: double.infinity,
                          height: AppSizes.listThumbSize * 2,
                          decoration: BoxDecoration(
                            color: AppColors.overlay(context, 0.05),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.20,
                                  child: CustomPaint(painter: _GridPainter()),
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.s10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface(context).withValues(alpha: 0.80),
                                    borderRadius: BorderRadius.circular(AppRadii.pill),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.brandBlueSoft,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: AppSpacing.md,
                                bottom: AppSpacing.s10,
                                child: _PillOutlineButton(
                                  text: "Get directions",
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.screenV),

              // Contact
              Text(
                "Contact",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenV),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: AppSizes.minTap / 2.2,
                        backgroundColor: AppColors.tenantPanel.withValues(alpha: 0.85),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.brandBlueSoft,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewing.agentName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              "Real Estate Agent",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted(context).withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _IconBubble(icon: Icons.call_rounded, onTap: () {}),
                      const SizedBox(width: AppSpacing.s10),
                      _IconBubble(icon: Icons.chat_rounded, onTap: () {}),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.screenV),

              // Timeline
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenV,
                    AppSpacing.md,
                    AppSpacing.screenV,
                    AppSpacing.screenV,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Timeline(stage: stage),
                      const SizedBox(height: AppSpacing.s10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TimelineLabel(text: "Requested", active: stage >= 0),
                          _TimelineLabel(text: "Confirmed", active: stage >= 1),
                          _TimelineLabel(text: "Completed", active: stage >= 2),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        fullDateTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted(context).withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.screenV),

              // Bottom actions
              if (isCompleted) ...[
                _PillButton(
                  text: "Apply Now  ›",
                  color: AppColors.brandGreenDeep,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ApplyPreCheckScreen(
                          listing: ApplyListingVM(
                            id: viewing.id,
                            title: viewing.listingTitle,
                            location: viewing.location,
                            rentPerMonthNgn: _parseMonthlyRent(viewing.priceText),
                            priceText: viewing.priceText ?? "₦450,000/mo",
                            photoAssetPath: "assets/images/listing_011.png",
                          ),
                          guarantorRequiredThresholdNgn: 500000,
                        ),
                      ),
                    );
                  },
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _PillButton(
                        text: "Reschedule  ›",
                        color: AppColors.brandBlueSoft,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _PillButton(
                        text: _busy ? "Cancelling…" : "Cancel visit",
                        color: AppColors.tenantDangerSoft,
                        onTap: (canCancel && !_busy) ? _cancelVisit : null,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Busy overlay
        if (_busy)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: AppColors.overlay(context, 0.12),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: SizedBox(
          height: AppSizes.iconButtonBox,
          width: AppSizes.iconButtonBox,
          child: Icon(icon, color: AppColors.brandBlueSoft, size: 18),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  final String text;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Material(
      color: disabled
          ? AppColors.tenantBorderMuted.withValues(alpha: 0.28)
          : color.withValues(alpha: 0.80),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          height: AppSizes.pillButtonHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
            child: Center(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: disabled ? AppColors.mutedMid : AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillOutlineButton extends StatelessWidget {
  const _PillOutlineButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineLabel extends StatelessWidget {
  const _TimelineLabel({required this.text, required this.active});
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: active
            ? AppColors.navy
            : AppColors.textMuted(context).withValues(alpha: 0.75),
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
    final dotSize = AppSpacing.md;
    final innerDot = AppSpacing.s6;
    final lineH = AppSpacing.s2;

    Widget dot(int i) {
      final c = _dotColor(i);
      return SizedBox(
        height: dotSize,
        width: dotSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: c.withValues(alpha: 0.75), width: 2),
          ),
          child: Center(
            child: Container(
              height: innerDot,
              width: innerDot,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
        ),
      );
    }

    Widget line(bool active) {
      return Expanded(
        child: Container(
          height: lineH,
          color: (active
              ? AppColors.brandBlueSoft
              : AppColors.textMutedLight.withValues(alpha: 0.25)),
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
        child: child,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.navy.withValues(alpha: 0.20)
      ..strokeWidth = 1;

    final step = AppSpacing.lg;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      case ViewingStatus.rejected:
        return const _ViewingBadge(
          label: "Rejected",
          color: AppColors.tenantDangerDeep,
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