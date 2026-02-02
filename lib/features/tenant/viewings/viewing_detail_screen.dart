// lib/features/tenant/viewings/viewing_detail_screen.dart
// ignore_for_file: unnecessary_underscores

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";
import "../../../shared/models/viewing_model.dart";

// ✅ Import ONLY the screen we need to avoid ApplyListingVM conflicts
import "../applications/apply_flow_screens.dart" show ApplyPreCheckScreen;

import "../../../core/network/api_client.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_sizes.dart";

import "../../../shared/models/application_form_models.dart" show ApplyListingVM;

class ViewingDetailScreen extends StatefulWidget {
  const ViewingDetailScreen({super.key, required this.viewing});

  final ViewingModel viewing;

  @override
  State<ViewingDetailScreen> createState() => _ViewingDetailScreenState();
}

class _ViewingDetailScreenState extends State<ViewingDetailScreen> {
  bool _busy = false;
  late ViewingModel _viewing;

  final ApiClient _client = ApiClient();

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaSurface => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorderSoft => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;
  double get _alphaOverlaySoft => AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);

  @override
  void initState() {
    super.initState();
    _viewing = widget.viewing;
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

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _canCancel(ViewingModel v) {
    return v.status == ViewingStatus.requested || v.status == ViewingStatus.confirmed;
  }

  bool _canReschedule(ViewingModel v) {
    return v.status == ViewingStatus.requested || v.status == ViewingStatus.confirmed;
  }

  Future<bool> _confirmDialog({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return res == true;
  }

  // ---------------- Backend fallbacks ----------------

  Future<void> _cancelOnBackend(String viewingId) async {
    try {
      await _client.patch("/v1/viewings/$viewingId/cancel", data: {});
      return;
    } catch (_) {}

    try {
      await _client.post("/v1/viewings/$viewingId/cancel", data: {});
      return;
    } catch (_) {}

    try {
      await _client.patch("/v1/viewings/$viewingId", data: {"status": "cancelled"});
      return;
    } catch (_) {}

    await _client.post("/v1/viewings/$viewingId", data: {"status": "cancelled"});
  }

  Future<void> _rescheduleOnBackend(String viewingId, String scheduledAtIsoUtc) async {
    try {
      await _client.post(
        "/v1/viewings/$viewingId/reschedule",
        data: {"scheduledAt": scheduledAtIsoUtc},
      );
      return;
    } catch (_) {}

    try {
      await _client.patch(
        "/v1/viewings/$viewingId/reschedule",
        data: {"scheduledAt": scheduledAtIsoUtc},
      );
      return;
    } catch (_) {}

    try {
      await _client.patch(
        "/v1/viewings/$viewingId",
        data: {"scheduledAt": scheduledAtIsoUtc},
      );
      return;
    } catch (_) {}

    await _client.post(
      "/v1/viewings/$viewingId",
      data: {"scheduledAt": scheduledAtIsoUtc},
    );
  }

  // ---------------- Actions ----------------

  Future<void> _addToCalendar() async {
    final v = _viewing;
    final when = _fullDateTime(context, v.dateTime);

    final details = [
      "RentEase Viewing",
      v.listingTitle,
      v.location,
      "When: $when",
      if ((v.priceText ?? "").trim().isNotEmpty) "Amount: ${v.priceText!.trim()}",
      "Agent: ${v.agentName}",
      if ((v.landlordName ?? "").trim().isNotEmpty) "Landlord: ${v.landlordName!.trim()}",
      "",
      "Viewing ID: ${v.id}",
      if ((v.listingId ?? "").trim().isNotEmpty) "Listing ID: ${v.listingId}",
      if ((v.propertyId ?? "").trim().isNotEmpty) "Property ID: ${v.propertyId}",
    ].join("\n");

    await Clipboard.setData(ClipboardData(text: details));
    _toast("Viewing details copied. Paste into your calendar event.");
  }

  Future<void> _cancelVisit() async {
    final v = _viewing;
    if (_busy) return;
    if (!_canCancel(v)) return;

    final ok = await _confirmDialog(
      title: "Cancel visit?",
      message: "Are you sure you want to cancel this visit request?",
      confirmText: "Cancel visit",
    );
    if (!ok) return;

    setState(() => _busy = true);
    try {
      await _cancelOnBackend(v.id);
      if (!mounted) return;

      setState(() {
        _viewing = _viewing.copyWith(status: ViewingStatus.cancelled);
      });

      _toast("Visit cancelled");
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _toast("Couldn’t cancel. Please try again.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rescheduleVisit() async {
    final v = _viewing;
    if (_busy) return;
    if (!_canReschedule(v)) return;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: v.dateTime.isAfter(start) ? v.dateTime : start,
      firstDate: start,
      lastDate: start.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(v.dateTime),
    );
    if (pickedTime == null) return;

    final newLocal = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final ok = await _confirmDialog(
      title: "Reschedule visit?",
      message: "Move this visit to:\n\n${_fullDateTime(context, newLocal)}",
      confirmText: "Reschedule",
    );
    if (!ok) return;

    setState(() => _busy = true);
    try {
      final scheduledAtIsoUtc = newLocal.toUtc().toIso8601String();
      await _rescheduleOnBackend(v.id, scheduledAtIsoUtc);

      if (!mounted) return;

      setState(() {
        _viewing = _viewing.copyWith(dateTime: newLocal);
      });

      _toast("Visit rescheduled");
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _toast("Couldn’t reschedule. Please try again.");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openApply(ViewingModel v) {
    // ✅ ApplyListingVM now requires listingId + propertyId + title/location/rent/priceText
    final listingId = (v.listingId ?? "").trim().isNotEmpty ? v.listingId!.trim() : v.id;
    final propertyId = (v.propertyId ?? "").trim().isNotEmpty ? v.propertyId!.trim() : listingId;

    final priceText = (v.priceText ?? "").trim();
    final rentNgn = _parseMonthlyRent(priceText);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ApplyPreCheckScreen(
          listing: ApplyListingVM(
            listingId: listingId,
            propertyId: propertyId,
            title: v.listingTitle.trim(),
            location: v.location.trim(),
            rentPerMonthNgn: rentNgn,
            priceText: priceText.isEmpty ? "₦0" : priceText,
            // You only have thumbnailUrl (network). ApplyListingVM expects asset path.
            photoAssetPath: null,
          ),
          guarantorRequiredThresholdNgn: 500000,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = _viewing;

    final price = (v.priceText ?? "₦—").trim();
    final fullDateTime = _fullDateTime(context, v.dateTime);

    final isCompleted = v.status == ViewingStatus.completed;
    final canCancel = _canCancel(v);
    final canReschedule = _canReschedule(v);

    final stage = _stageFor(v.status);
    final badge = _ViewingBadge.from(context, v.status);

    final titleColor = AppColors.textPrimary(context);
    final subColor = AppColors.textSecondary(context);
    final muted = AppColors.textMuted(context);

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
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(context).withValues(alpha: _alphaSurfaceStrong),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: AppColors.overlay(context, _alphaBorderSoft)),
                    boxShadow: AppShadows.lift(
                      context,
                      blur: AppSpacing.xxxl + AppSpacing.lg,
                      y: AppSpacing.xl,
                      alpha: _alphaShadowSoft,
                    ),
                  ),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1 / AppSizes.featuredCardAspect,
                        child: Container(
                          width: double.infinity,
                          color: AppColors.overlay(context, _alphaOverlaySoft),
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
                            color: AppColors.overlay(context, AppSpacing.sm / AppSpacing.xxxl),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            border: Border.all(
                              color: AppColors.overlay(context, AppSpacing.xs / AppSpacing.xxxl),
                            ),
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
              ),
              const SizedBox(height: AppSpacing.screenV),

              // Title + badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      v.listingTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: titleColor,
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
                      color: badge.color.withValues(
                        alpha: AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md),
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: badge.color.withValues(
                          alpha: AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs),
                        ),
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

              // Date card + add to calendar
              _ExploreSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenV),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: AppSizes.minTap / 2.4,
                        color: AppColors.brandBlueSoft,
                      ),
                      const SizedBox(width: AppSpacing.s10),
                      Expanded(
                        child: Text(
                          fullDateTime,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: titleColor,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: _busy ? null : _addToCalendar,
                        child: const Text("Add to calendar"),
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
                      color: titleColor,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),

              _ExploreSurfaceCard(
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
                              v.location,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: titleColor,
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
                            color: AppColors.overlay(
                              context,
                              AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs),
                            ),
                            border: Border.all(color: AppColors.overlay(context, _alphaBorderSoft)),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Opacity(
                                  opacity: AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm),
                                  child: CustomPaint(painter: _GridPainter()),
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.s10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface(context)
                                        .withValues(alpha: _alphaSurfaceStrong),
                                    borderRadius: BorderRadius.circular(AppRadii.pill),
                                    border: Border.all(
                                      color: AppColors.overlay(context, _alphaBorderSoft),
                                    ),
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
                                child: _PillOutlineButton(text: "Get directions", onTap: () {}),
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

              // Contact (agent + landlord)
              Text(
                "Contact",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),

              _ExploreSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenV),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: AppSizes.minTap / 2.2,
                        backgroundColor: AppColors.brandBlueSoft.withValues(
                          alpha: AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md),
                        ),
                        child: Icon(Icons.person_rounded, color: titleColor),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.agentName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: titleColor,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              (v.landlordName ?? "").trim().isNotEmpty
                                  ? "Agent • Landlord: ${v.landlordName!.trim()}"
                                  : "Agent",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: muted.withValues(
                                      alpha: AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm),
                                    ),
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
              _ExploreSurfaceCard(
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
                              color: subColor,
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
                  onTap: _busy ? null : () => _openApply(v),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _PillButton(
                        text: _busy ? "Rescheduling…" : "Reschedule  ›",
                        color: AppColors.brandBlueSoft,
                        onTap: (!_busy && canReschedule) ? _rescheduleVisit : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _PillButton(
                        text: _busy ? "Cancelling…" : "Cancel visit",
                        color: AppColors.tenantDangerSoft,
                        onTap: (!_busy && canCancel) ? _cancelVisit : null,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        if (_busy)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: AppColors.overlay(
                  context,
                  AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs),
                ),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

// =====================
// Explore primitives
// =====================

class _ExploreSurfaceCard extends StatelessWidget {
  const _ExploreSurfaceCard({required this.child});
  final Widget child;

  double get _alphaSurface => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorder => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaShadow => AppSpacing.xs / AppSpacing.xxxl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: _alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, _alphaBorder)),
        boxShadow: AppShadows.soft(
          context,
          blur: AppSpacing.xxxl,
          y: AppSpacing.xl,
          alpha: _alphaShadow,
        ),
      ),
      child: child,
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  double get _alphaSurface => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorder => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: _alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          height: AppSizes.iconButtonBox,
          width: AppSizes.iconButtonBox,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: AppColors.overlay(context, _alphaBorder)),
          ),
          child: Icon(icon, color: AppColors.textPrimary(context), size: 18),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.text, required this.color, required this.onTap});

  final String text;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    // ✅ Avoid tokens that may not exist (like mutedMid / tenantBorderMuted)
    final alphaBg = AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaFill = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

    return Material(
      color: disabled ? AppColors.overlay(context, alphaBg) : color.withValues(alpha: alphaFill),
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
                      color: disabled ? AppColors.textMuted(context) : AppColors.white,
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

  double get _alphaSurface => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorder => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: _alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.overlay(context, _alphaBorder)),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
      ),
    );
  }
}

// Timeline
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
            color: active ? AppColors.textPrimary(context) : AppColors.textMuted(context),
          ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.stage});
  final int stage;

  Color _dotColor(BuildContext context, int idx) {
    if (idx < stage) return AppColors.brandBlueSoft;
    if (idx == stage && stage == 2) return AppColors.brandGreenDeep;
    if (idx == stage) return AppColors.brandBlueSoft;
    return AppColors.textMuted(context).withValues(
      alpha: AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = AppSpacing.md;
    final innerDot = AppSpacing.s6;
    final lineH = AppSpacing.s2;

    Widget dot(int i) {
      final c = _dotColor(context, i);
      return SizedBox(
        height: dotSize,
        width: dotSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.withValues(alpha: AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md)),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: c.withValues(alpha: AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs)),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              height: innerDot,
              width: innerDot,
              decoration: BoxDecoration(
                color: c.withValues(alpha: AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs)),
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
          color: active
              ? AppColors.brandBlueSoft
              : AppColors.textMuted(context).withValues(
                  alpha: AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm),
                ),
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

// Map grid painter
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.white.withValues(alpha: AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm))
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

// Badge
class _ViewingBadge {
  const _ViewingBadge({required this.label, required this.color});

  final String label;
  final Color color;

  static _ViewingBadge from(BuildContext context, ViewingStatus status) {
    switch (status) {
      case ViewingStatus.requested:
        return const _ViewingBadge(label: "Requested", color: AppColors.brandBlueSoft);
      case ViewingStatus.confirmed:
        return const _ViewingBadge(label: "Confirmed", color: AppColors.brandGreenDeep);
      case ViewingStatus.rejected:
        return const _ViewingBadge(label: "Rejected", color: AppColors.tenantDangerDeep);
      case ViewingStatus.completed:
        return const _ViewingBadge(label: "Completed", color: AppColors.brandGreenDeep);
      case ViewingStatus.cancelled:
        return _ViewingBadge(label: "Cancelled", color: AppColors.textMuted(context));
    }
  }
}