// lib/features/tenant/viewings/viewings_screen.dart
// ignore_for_file: unnecessary_underscores

import "package:flutter/material.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";

import "../../../shared/models/viewing_model.dart";
import "viewing_detail_screen.dart";

// ✅ Import ONLY the screen we need (avoids ApplyListingVM name clashes)
import "../applications/apply_flow_screens.dart" show ApplyPreCheckScreen;

import "data/viewings_api.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_sizes.dart";

import "../../../shared/models/application_form_models.dart" show ApplyListingVM;

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({
    super.key,
    this.viewings = const [],
    this.title,
    this.fetchWhenEmpty = true, // ✅ fetch from backend by default
  });

  /// If you pass real viewings, the screen uses them.
  final List<ViewingModel> viewings;

  /// Optional screen title
  final String? title;

  /// If true and [viewings] is empty, the screen will fetch from backend
  final bool fetchWhenEmpty;

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

enum _Tab { upcoming, completed }

class _ViewingsScreenState extends State<ViewingsScreen> {
  _Tab _tab = _Tab.upcoming;

  final ViewingsApi _api = ViewingsApi();

  bool _loading = false;
  String? _error;
  List<ViewingModel> _fetched = const [];

  /// Local overrides after actions (cancel/reschedule) so UI always reflects
  /// latest state even if parent passed a const list.
  final Map<String, ViewingModel> _overrides = <String, ViewingModel>{};

  /// Track per-item action loading
  final Set<String> _busyIds = <String>{};

  int _parseMonthlyRent(String? priceText) {
    if (priceText == null) return 0;
    final raw = priceText.replaceAll(RegExp(r"[^0-9]"), "");
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _maybeFetch();
  }

  Future<void> _maybeFetch() async {
    if (!widget.fetchWhenEmpty) return;
    if (widget.viewings.isNotEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await _api.listMy(limit: 50, offset: 0);
      if (!mounted) return;

      setState(() {
        _fetched = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshFromBackendIfUsingFetched() async {
    if (widget.viewings.isNotEmpty) return; // parent controls data
    await _maybeFetch();
  }

  List<ViewingModel> get _source {
    final base = widget.viewings.isNotEmpty ? widget.viewings : _fetched;
    if (_overrides.isEmpty) return base;
    return base.map((v) => _overrides[v.id] ?? v).toList();
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
                  v.status == ViewingStatus.cancelled ||
                  v.status == ViewingStatus.rejected,
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

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _canReschedule(ViewingModel v) {
    return v.status == ViewingStatus.requested ||
        v.status == ViewingStatus.confirmed;
  }

  bool _canCancel(ViewingModel v) {
    return v.status == ViewingStatus.requested ||
        v.status == ViewingStatus.confirmed;
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

  Future<void> _handleCancel(ViewingModel v) async {
    if (!_canCancel(v)) return;

    final ok = await _confirmDialog(
      title: "Cancel visit?",
      message: "Are you sure you want to cancel this visit request?",
      confirmText: "Cancel visit",
    );
    if (!ok) return;

    if (_busyIds.contains(v.id)) return;
    setState(() => _busyIds.add(v.id));

    try {
      final updatedFromApi = await _api.cancel(v.id);

      setState(() => _overrides[v.id] = updatedFromApi);

      await _refreshFromBackendIfUsingFetched();
      _toast("Visit cancelled");
    } catch (e) {
      _toast("Couldn’t cancel. Please try again.");
    } finally {
      if (mounted) setState(() => _busyIds.remove(v.id));
    }
  }

  Future<void> _handleReschedule(ViewingModel v) async {
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
      message: "Move this visit to:\n\n${_fmtLine1(context, newLocal)}",
      confirmText: "Reschedule",
    );
    if (!ok) return;

    if (_busyIds.contains(v.id)) return;
    setState(() => _busyIds.add(v.id));

    try {
      final updatedFromApi = await _api.reschedule(
        viewingId: v.id,
        scheduledAtLocal: newLocal,
      );

      // Ensure date updates instantly even if API doesn’t echo local date
      final merged = updatedFromApi.copyWith(dateTime: newLocal);
      setState(() => _overrides[v.id] = merged);

      await _refreshFromBackendIfUsingFetched();
      _toast("Visit rescheduled");
    } catch (e) {
      _toast("Couldn’t reschedule. Please try again.");
    } finally {
      if (mounted) setState(() => _busyIds.remove(v.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

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
            title: widget.title ?? "My Visits",
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
            actions: [
              IconButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() {
                          _error = null;
                          _loading = true;
                        });
                        try {
                          final list = await _api.listMy(limit: 50, offset: 0);
                          if (!mounted) return;
                          setState(() {
                            _fetched = list;
                            _loading = false;
                          });
                        } catch (e) {
                          if (!mounted) return;
                          setState(() {
                            _error = e.toString();
                            _loading = false;
                          });
                        }
                      },
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
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
                child: _loading
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: AppColors.brandGreenDeep,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                "Loading visits…",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textMuted(context),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _error != null
                        ? _ErrorState(message: _error!, onRetry: _maybeFetch)
                        : items.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Text(
                                    "No visits yet",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textMuted(context),
                                        ),
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
                                  final badge =
                                      _ViewingBadge.from(context, v.status);

                                  final busy = _busyIds.contains(v.id);
                                  final showApplyNow =
                                      v.status == ViewingStatus.completed;

                                  final canReschedule =
                                      _canReschedule(v) && !busy;
                                  final canCancel = _canCancel(v) && !busy;

                                  final who = (v.landlordName == null ||
                                          v.landlordName!.trim().isEmpty)
                                      ? v.agentName
                                      : "${v.agentName} • ${v.landlordName!.trim()}";

                                  return _ViewingCard(
                                    title: v.listingTitle,
                                    line1: _fmtLine1(context, v.dateTime),
                                    location: v.location,
                                    subtitle: who,
                                    amountText: v.priceText,
                                    badge: badge,
                                    status: v.status,
                                    thumbnailUrl: v.thumbnailUrl,
                                    busy: busy,
                                    showApplyNow: showApplyNow,
                                    onApplyNow: () {
  final listingId = (v.listingId ?? "").trim();

  if (listingId.isEmpty) {
    _toast("Missing listingId. Refresh and try again.");
    return;
  }

  final propertyId = (v.propertyId ?? "").trim();

  // ✅ STOP if missing (do not navigate)
  if (propertyId.isEmpty) {
    _toast("This viewing is missing propertyId. Refresh and try again.");
    return;
  }

  final priceText = (v.priceText ?? "").trim();
  final rentNgn = _parseMonthlyRent(priceText);

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ApplyPreCheckScreen(
        listing: ApplyListingVM(
          listingId: listingId,
          propertyId: propertyId, // ✅ always real UUID now
          title: v.listingTitle.trim(),
          location: v.location.trim(),
          rentPerMonthNgn: rentNgn,
          priceText: priceText.isEmpty ? "₦0" : priceText,
          photoAssetPath: null,
        ),
        guarantorRequiredThresholdNgn: 500000,
      ),
    ),
  );
},
                                    onTap: () async {
                                      final changed =
                                          await Navigator.of(context).push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ViewingDetailScreen(viewing: v),
                                        ),
                                      );

                                      if (changed == true) {
                                        await _refreshFromBackendIfUsingFetched();
                                      }
                                    },
                                    onDirections: () {},
                                    onReschedule: canReschedule
                                        ? () => _handleReschedule(v)
                                        : null,
                                    onCancel: canCancel
                                        ? () => _handleCancel(v)
                                        : null,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenV),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _FrostCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: AppSpacing.xxxl + AppSpacing.lg,
                    color: AppColors.tenantDangerDeep,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    "Couldn’t load visits",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted(context)
                              .withValues(alpha: 0.92),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PillButton(
                    text: "Retry",
                    color: AppColors.brandBlueSoft,
                    onTap: onRetry,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});
  final _Tab value;
  final ValueChanged<_Tab> onChanged;

  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    Widget tab(_Tab t, String label) {
      final selected = value == t;

      final bg = selected
          ? AppColors.brandBlueSoft.withValues(
              alpha: AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm),
            )
          : AppColors.surface(context).withValues(alpha: _alphaSurfaceSoft);

      final border = selected
          ? AppColors.brandBlueSoft.withValues(
              alpha: AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs),
            )
          : AppColors.overlay(context, _alphaBorderSoft);

      final fg = AppColors.textPrimary(context);

      return Expanded(
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: InkWell(
            onTap: () => onChanged(t),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              height: AppSizes.pillButtonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: border),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: fg,
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
        color: AppColors.surface(context).withValues(alpha: _alphaSurfaceStrong),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, _alphaBorderSoft)),
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

class _ViewingCard extends StatelessWidget {
  const _ViewingCard({
    required this.title,
    required this.line1,
    required this.location,
    required this.subtitle,
    required this.amountText,
    required this.badge,
    required this.status,
    required this.thumbnailUrl,
    required this.busy,
    required this.showApplyNow,
    required this.onApplyNow,
    required this.onTap,
    required this.onDirections,
    required this.onReschedule,
    required this.onCancel,
  });

  final String title;
  final String line1;
  final String location;

  final String subtitle; // agent / landlord line
  final String? amountText;

  final _ViewingBadge badge;
  final ViewingStatus status;

  final String? thumbnailUrl;

  final bool busy;

  final bool showApplyNow;
  final VoidCallback onApplyNow;

  final VoidCallback onTap;
  final VoidCallback onDirections;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;

  bool _isUrl(String s) => s.startsWith("http://") || s.startsWith("https://");

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == ViewingStatus.completed;

    Widget thumb;
    final url = (thumbnailUrl ?? "").trim();
    if (url.isNotEmpty && _isUrl(url)) {
      thumb = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.home_rounded,
          color: AppColors.brandBlueSoft,
        ),
      );
    } else {
      thumb = const Icon(Icons.home_rounded, color: AppColors.brandBlueSoft);
    }

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
                      color: AppColors.overlay(
                        context,
                        AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm),
                      ),
                      alignment: Alignment.center,
                      child: busy
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : thumb,
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary(context),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.s6),
                        Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              size: AppSizes.minTap / 3,
                              color: AppColors.textMuted(context),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary(context),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.s6),
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: AppSizes.minTap / 3,
                              color: AppColors.textMuted(context),
                            ),
                            const SizedBox(width: AppSpacing.s6),
                            Expanded(
                              child: Text(
                                subtitle,
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
                        if ((amountText ?? "").trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s6),
                          Text(
                            amountText!.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandGreenDeep,
                                ),
                          ),
                        ],
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
                      color: badge.color.withValues(
                        alpha: AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.s10,
                runSpacing: AppSpacing.s10,
                children: [
                  _MiniAction(
                    icon: Icons.directions_rounded,
                    text: "Directions",
                    onTap: busy ? null : onDirections,
                  ),
                  if (!isCompleted)
                    _MiniAction(
                      icon: Icons.schedule_rounded,
                      text: "Reschedule",
                      onTap: onReschedule,
                      disabled: busy || onReschedule == null,
                    ),
                  _MiniAction(
                    icon: Icons.close_rounded,
                    text: "Cancel",
                    onTap: onCancel,
                    disabled: busy || onCancel == null,
                    textColor: AppColors.tenantDangerSoft,
                    iconColor: AppColors.tenantDangerSoft,
                  ),
                  if (isCompleted && showApplyNow)
                    _MiniAction(
                      icon: Icons.assignment_rounded,
                      text: "Apply Now",
                      onTap: busy ? null : onApplyNow,
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
    this.disabled = false,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool disabled;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final tc = textColor ?? AppColors.textPrimary(context);
    final ic = iconColor ?? AppColors.textMuted(context);

    final alphaBg = AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    final effectiveTextColor =
        disabled ? AppColors.textMuted(context).withValues(alpha: 0.55) : tc;
    final effectiveIconColor =
        disabled ? AppColors.textMuted(context).withValues(alpha: 0.55) : ic;

    return Material(
      color: AppColors.overlay(context, alphaBg),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.overlay(context, alphaBorder)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.s10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: effectiveIconColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: effectiveTextColor,
                    ),
              ),
            ],
          ),
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

    final alphaBg = AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaStrong = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

    return Material(
      color: disabled
          ? AppColors.overlay(context, alphaBg)
          : color.withValues(alpha: alphaStrong),
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

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return Material(
      color: AppColors.surface(context).withValues(alpha: alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: AppSpacing.xs / AppSpacing.xxxl,
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
      case ViewingStatus.rejected:
        return const _ViewingBadge(
          label: "Rejected",
          color: AppColors.tenantDangerDeep,
        );
      case ViewingStatus.cancelled:
        return _ViewingBadge(
          label: "Cancelled",
          color: AppColors.textMuted(context),
        );
    }
  }
}