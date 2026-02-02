// lib/features/tenant/listing_detail/schedule_visit_screen.dart
// ignore_for_file: prefer_final_fields, use_build_context_synchronously, unnecessary_underscores

import 'dart:math' as math;
import 'package:flutter/material.dart';

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_sizes.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";

import "../../../core/network/api_client.dart";
import "../../../shared/models/viewing_model.dart";
import "../viewings/viewings_screen.dart";

enum VisitType { rent, buy, land, commercial }
enum VisitMode { inPerson, virtual }

/// ✅ Fix: Flutter MaterialLocalizations has no shortWeekday().
/// We provide our own short weekday labels.
String _shortWeekday(DateTime d) {
  const names = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final idx = (d.weekday - 1).clamp(0, 6);
  return names[idx];
}

/// ✅ Simple in-memory store (optional).
/// If your real My Viewings screen fetches from backend, you can remove this later.
class ViewingStore {
  ViewingStore._();
  static final List<ViewingModel> items = <ViewingModel>[];

  static void add(ViewingModel v) {
    items.removeWhere((x) => x.id == v.id);
    items.insert(0, v);
  }
}

/// ✅ Backend-ready API contract
abstract class VisitRequestApi {
  Future<RequestResultVM> send(
    VisitRequestDraft draft, {
    required bool instantBooking,
  });
}

/// ✅ Real backend implementation
///
/// IMPORTANT:
/// Backend now derives property_id from listing_id.
/// So we MUST NOT send propertyId from Flutter.
class BackendVisitRequestApi implements VisitRequestApi {
  BackendVisitRequestApi(this._client);

  final ApiClient _client;

  @override
  Future<RequestResultVM> send(
    VisitRequestDraft draft, {
    required bool instantBooking,
  }) async {
    final listingId = draft.listing.listingId.trim();

    if (listingId.isEmpty) {
      throw Exception("LISTING_ID_MISSING");
    }

    final dtLocal = DateTime(
      draft.selectedDate.year,
      draft.selectedDate.month,
      draft.selectedDate.day,
      draft.selectedTime.hour,
      draft.selectedTime.minute,
    );

    // Backend expects ISO datetime string (UTC)
    final scheduledAtIso = dtLocal.toUtc().toIso8601String();

    final viewMode = draft.mode == VisitMode.virtual ? "virtual" : "in_person";

    final notesCombined = <String>[
      draft.notes.trim(),
      if (draft.extraFieldValue.trim().isNotEmpty)
        "Extra: ${draft.extraFieldValue.trim()}",
    ].where((s) => s.isNotEmpty).join("\n");

    // ✅ Matches backend createViewingBodySchema:
    // { listingId, scheduledAt, viewMode?, notes? }
    final json = await _client.post(
      "/v1/viewings",
      data: {
        "listingId": listingId,
        "scheduledAt": scheduledAtIso,
        "viewMode": viewMode,
        if (notesCombined.isNotEmpty) "notes": notesCombined,
      },
    );

    final Map<String, dynamic> item = _extractViewingMap(json);

    final id = (item["id"] ?? "").toString().trim();
    final status = (item["status"] ?? "pending").toString().trim();

    final scheduledAtRaw = (item["scheduled_at"] ??
            item["scheduledAt"] ??
            item["scheduled_at_iso"] ??
            scheduledAtIso)
        .toString();

    DateTime parsed;
    try {
      parsed = DateTime.parse(scheduledAtRaw).toLocal();
    } catch (_) {
      parsed = dtLocal;
    }

    final agentName =
        (item["agentName"] ?? item["agent_name"] ?? "Agent").toString();

    final agentSubtitle =
        status.toLowerCase() == "approved" ? "Confirmed" : "Pending";

    return RequestResultVM(
      referenceId: id.isEmpty ? _fallbackRef() : id,
      agentName: agentName,
      agentSubtitle: agentSubtitle,
      dateTime: parsed,
      backendStatus: status,
      listingTitle: draft.listing.title,
      location: draft.listing.location,
      priceText: draft.listing.priceLine,
    );
  }

  static Map<String, dynamic> _extractViewingMap(dynamic json) {
    if (json is Map<String, dynamic>) {
      final dynamic pick = json["viewing"] ?? json["item"] ?? json["data"];
      if (pick is Map) return Map<String, dynamic>.from(pick as Map);

      if (json.containsKey("id") || json.containsKey("status")) {
        return json;
      }
    }
    return <String, dynamic>{};
  }

  static String _fallbackRef() {
    final n = 20000 + math.Random().nextInt(79999);
    return "HS-VIS-$n";
  }
}

class VisitListingCardVM {
  const VisitListingCardVM({
    required this.title,
    required this.location,
    required this.priceLine,
    this.photoAssetPath,
    this.photoUrl,
    required this.locationTitle,
    required this.addressLine,

    /// ✅ REQUIRED FOR BACKEND CREATE
    required this.listingId,

    /// Optional now (backend derives propertyId)
    this.propertyId = "",
  });

  final String title;
  final String location;
  final String priceLine;

  final String? photoAssetPath;
  final String? photoUrl;

  final String locationTitle;
  final String addressLine;

  /// ✅ Must be the property_listings.id
  final String listingId;

  /// Optional (not used in request anymore)
  final String propertyId;
}

class VisitRequestDraft {
  const VisitRequestDraft({
    required this.visitType,
    required this.listing,
    required this.selectedDate,
    required this.selectedTime,
    required this.mode,
    required this.notes,
    required this.extraFieldValue,
  });

  final VisitType visitType;
  final VisitListingCardVM listing;

  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  final VisitMode mode;
  final String notes;
  final String extraFieldValue;
}

class RequestResultVM {
  const RequestResultVM({
    required this.referenceId,
    required this.agentName,
    required this.agentSubtitle,
    required this.dateTime,
    required this.backendStatus,
    required this.listingTitle,
    required this.location,
    required this.priceText,
  });

  final String referenceId;
  final String agentName;
  final String agentSubtitle;
  final DateTime dateTime;

  /// ✅ backend: pending/approved/rejected/completed/cancelled
  final String backendStatus;

  final String listingTitle;
  final String location;
  final String? priceText;
}

class ScheduleVisitScreen extends StatefulWidget {
  const ScheduleVisitScreen({
    super.key,
    required this.visitType,
    required this.listing,
    this.instantBooking = false,

    /// ✅ inject real API later; defaults to backend
    this.api,
  });

  final VisitType visitType;
  final VisitListingCardVM listing;
  final bool instantBooking;
  final VisitRequestApi? api;

  @override
  State<ScheduleVisitScreen> createState() => _ScheduleVisitScreenState();
}

class _ScheduleVisitScreenState extends State<ScheduleVisitScreen> {
  late List<DateTime> _dates;
  late DateTime _selectedDate;

  TimeOfDay? _selectedTime;

  VisitMode _mode = VisitMode.inPerson;
  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _extraCtrl = TextEditingController();

  VisitRequestApi get _api => widget.api ?? BackendVisitRequestApi(ApiClient());

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    _dates = List.generate(7, (i) => start.add(Duration(days: i)));
    _selectedDate = _dates.first;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _extraCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAnyDate() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: start,
      lastDate: start.add(const Duration(days: 365)),
    );

    if (picked == null) return;

    final d = DateTime(picked.year, picked.month, picked.day);

    setState(() {
      _selectedDate = d;

      final exists = _dates.any(
        (x) => x.year == d.year && x.month == d.month && x.day == d.day,
      );

      if (!exists) _dates.insert(0, d);
    });
  }

  Future<void> _pickAnyTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
    );

    if (picked == null) return;
    setState(() => _selectedTime = picked);
  }

  String get _title {
    switch (widget.visitType) {
      case VisitType.rent:
        return "Schedule Viewing";
      case VisitType.buy:
        return "Request Inspection";
      case VisitType.land:
        return "Request Inspection";
      case VisitType.commercial:
        return "Schedule Tour";
    }
  }

  String get _primaryCta {
    switch (widget.visitType) {
      case VisitType.rent:
        return "Request Viewing";
      case VisitType.buy:
        return "Request Inspection";
      case VisitType.land:
        return "Request Site Inspection";
      case VisitType.commercial:
        return "Request Tour";
    }
  }

  String get _confirmTitle {
    switch (widget.visitType) {
      case VisitType.rent:
        return "Confirm Viewing";
      case VisitType.buy:
        return "Confirm Inspection";
      case VisitType.land:
        return "Confirm Inspection";
      case VisitType.commercial:
        return "Confirm Tour";
    }
  }

  String? get _extraLabel {
    switch (widget.visitType) {
      case VisitType.rent:
        return null;
      case VisitType.buy:
        return "Purpose (optional)";
      case VisitType.land:
        return "Bring surveyor? (optional)";
      case VisitType.commercial:
        return "Intended use (optional)";
    }
  }

  String _fmtDateChip(BuildContext context, DateTime d) {
    final loc = MaterialLocalizations.of(context);
    final weekday = _shortWeekday(d);
    final monthShort = loc.formatMonthYear(d).split(" ").first;
    return "$weekday, $monthShort ${d.day}";
  }

  String _fmtTime(BuildContext context, TimeOfDay t) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatTimeOfDay(t, alwaysUse24HourFormat: false);
  }

  List<_TimeSlot> _buildTimeSlots() {
    // Demo availability (later fetch availability)
    final base = <TimeOfDay>[
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 13, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
    ];

    final hash =
        _selectedDate.day + _selectedDate.month * 31 + _selectedDate.year;

    bool isUnavailable(TimeOfDay t) {
      final v = (hash + t.hour * 7 + t.minute) % 9;
      return v == 0;
    }

    return base
        .map((t) => _TimeSlot(time: t, available: !isUnavailable(t)))
        .toList();
  }

  bool get _canProceed => _selectedTime != null;

  Future<void> _goConfirm() async {
    if (!_canProceed) return;

    final draft = VisitRequestDraft(
      visitType: widget.visitType,
      listing: widget.listing,
      selectedDate: _selectedDate,
      selectedTime: _selectedTime!,
      mode: _mode,
      notes: _notesCtrl.text.trim(),
      extraFieldValue: _extraCtrl.text.trim(),
    );

    final res = await Navigator.of(context).push<RequestResultVM?>(
      MaterialPageRoute(
        builder: (_) => ConfirmVisitRequestScreen(
          title: _confirmTitle,
          primaryLabel: "Send Request",
          draft: draft,
          instantBooking: widget.instantBooking,
          api: _api,
        ),
      ),
    );

    if (res != null) {
      setState(() {
        _selectedTime = null;
        _notesCtrl.clear();
        _extraCtrl.clear();
        _mode = VisitMode.inPerson;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Guard: make sure listingId exists, so backend call won't fail silently.
    final listingIdOk = widget.listing.listingId.trim().isNotEmpty;

    final slots = _buildTimeSlots();

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
          topBar: AppTopBar(title: _title),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenV,
              AppSpacing.sm,
              AppSpacing.screenV,
              AppSizes.screenBottomPad,
            ),
            children: [
              _ListingMiniCard(listing: widget.listing),
              if (!listingIdOk) ...[
                const SizedBox(height: AppSpacing.md),
                _FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.tenantDangerDeep,
                          size: AppSizes.minTap / 3,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            "Listing ID is missing. Pass property_listings.id into ScheduleVisitScreen.",
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary(context),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                title: "Select date",
                trailing: _LinkText(text: "Pick any date", onTap: _pickAnyDate),
              ),
              const SizedBox(height: AppSpacing.sm),
              _DateChipsRow(
                dates: _dates,
                selected: _selectedDate,
                labelFor: (d) => _fmtDateChip(context, d),
                onSelected: (d) => setState(() => _selectedDate = d),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                title: "Select time",
                trailing: _LinkText(text: "Pick any time", onTap: _pickAnyTime),
              ),
              const SizedBox(height: AppSpacing.sm),
              _TimeGrid(
                slots: slots,
                selected: _selectedTime,
                labelFor: (t) => _fmtTime(context, t),
                onTap: (slot) {
                  if (!slot.available) return;
                  setState(() => _selectedTime = slot.time);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Unavailable",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color:
                          AppColors.textMuted(context).withValues(alpha: 0.85),
                    ),
              ),
              if (widget.visitType == VisitType.rent) ...[
                const SizedBox(height: AppSpacing.lg),
                const _SectionHeader(title: "Viewing type"),
                const SizedBox(height: AppSpacing.sm),
                _ModeRow(
                  value: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
              ],
              if (_extraLabel != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader(title: _extraLabel!),
                const SizedBox(height: AppSpacing.sm),
                _InputField(
                  controller: _extraCtrl,
                  hint: _extraHint(widget.visitType),
                  maxLines: 1,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                title: "Meeting location",
                trailing: _LinkText(text: "Open in Maps", onTap: () {}),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MeetingLocationCard(listing: widget.listing),
              const SizedBox(height: AppSpacing.lg),
              const _SectionHeader(title: "Notes"),
              const SizedBox(height: AppSpacing.sm),
              _InputField(
                controller: _notesCtrl,
                hint: "Any instructions for the agent?",
                maxLines: 1,
              ),
              const SizedBox(height: AppSpacing.lg),
              _PrimaryPillButton(
                text: _primaryCta,
                enabled: _canProceed && listingIdOk,
                onTap: (_canProceed && listingIdOk) ? _goConfirm : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _extraHint(VisitType t) {
    switch (t) {
      case VisitType.buy:
        return "Inspection / negotiation (optional)";
      case VisitType.land:
        return "Yes / No (optional)";
      case VisitType.commercial:
        return "Office / retail / warehouse (optional)";
      case VisitType.rent:
        return "";
    }
  }
}

class ConfirmVisitRequestScreen extends StatefulWidget {
  const ConfirmVisitRequestScreen({
    super.key,
    required this.title,
    required this.primaryLabel,
    required this.draft,
    required this.instantBooking,
    required this.api,
  });

  final String title;
  final String primaryLabel;
  final VisitRequestDraft draft;
  final bool instantBooking;
  final VisitRequestApi api;

  @override
  State<ConfirmVisitRequestScreen> createState() =>
      _ConfirmVisitRequestScreenState();
}

class _ConfirmVisitRequestScreenState extends State<ConfirmVisitRequestScreen> {
  bool _sending = false;

  String _fmtDateTime(BuildContext context, DateTime d, TimeOfDay t) {
    final loc = MaterialLocalizations.of(context);
    final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    final time = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: false,
    );

    return "${_shortWeekday(dt)}, ${loc.formatShortMonthDay(dt)} • $time";
  }

  String _modeText(VisitMode m) =>
      m == VisitMode.virtual ? "Virtual" : "In-person";

  Future<void> _sendRequest() async {
    if (_sending) return;
    setState(() => _sending = true);

    try {
      final result = await widget.api.send(
        widget.draft,
        instantBooking: widget.instantBooking,
      );

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RequestSentScreen(result: result)),
      );

      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;

      String msg = "Please check your connection and try again.";
      final raw = e.toString();

      if (raw.contains("LISTING_ID_MISSING")) {
        msg =
            "Listing ID is missing. Make sure you pass property_listings.id into ScheduleVisitScreen.";
      }

      final retry = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => RequestFailedScreen(message: msg)),
      );

      if (retry == true) {
        if (mounted) setState(() => _sending = false);
        _sendRequest();
        return;
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryDT = _fmtDateTime(
      context,
      widget.draft.selectedDate,
      widget.draft.selectedTime,
    );

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
          topBar: AppTopBar(title: widget.title),
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
                  padding: const EdgeInsets.all(AppSpacing.screenV),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ListingMiniCard(
                        listing: widget.draft.listing,
                        compact: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SummaryRow(icon: Icons.event_rounded, title: summaryDT),
                      if (widget.draft.visitType == VisitType.rent) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _SummaryRow(
                          icon: Icons.people_alt_rounded,
                          title: _modeText(widget.draft.mode),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        "Meeting point",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _MeetingLocationCard(
                        listing: widget.draft.listing,
                        compact: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        "Notes",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _SurfaceLine(
                        text: widget.draft.notes.isEmpty
                            ? "—"
                            : widget.draft.notes,
                      ),
                      if (widget.draft.extraFieldValue.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          "Extra",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary(context),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _SurfaceLine(text: widget.draft.extraFieldValue),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _PrimaryPillButton(
                text: _sending ? "Sending…" : widget.primaryLabel,
                enabled: !_sending,
                onTap: _sending ? null : _sendRequest,
              ),
              const SizedBox(height: AppSpacing.sm),
              _SecondaryPillButton(
                text: "Edit details",
                onTap: _sending ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RequestSentScreen extends StatelessWidget {
  const RequestSentScreen({super.key, required this.result});

  final RequestResultVM result;

  String _fmtDateTime(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    final time = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: false,
    );

    return "${_shortWeekday(dt)}, ${loc.formatShortMonthDay(dt)} • $time";
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _statusText(result.backendStatus);
    final statusColor = _statusColor(result.backendStatus);

    // Optional: add to local list UI
    try {
      final viewing = ViewingModel(
        id: result.referenceId,
        listingTitle: result.listingTitle,
        location: result.location,
        agentName: result.agentName,
        dateTime: result.dateTime,
        status: ViewingStatus.requested,
        priceText: result.priceText,
      );
      ViewingStore.add(viewing);
    } catch (_) {}

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
            title: "Request Sent",
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenV,
                AppSpacing.lg,
                AppSpacing.screenV,
                AppSizes.screenBottomPad,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SuccessIcon(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Request Sent",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Your request has been saved. You’ll get an update when it’s approved.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted(context)
                                .withValues(alpha: 0.92),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _FrostCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenV),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.55),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                                border: Border.all(
                                  color: AppColors.overlay(context, 0.06),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  statusText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary(context),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _SummaryRow(
                              icon: Icons.event_rounded,
                              title: _fmtDateTime(context, result.dateTime),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _AgentMiniCard(
                              name: result.agentName,
                              subtitle: result.agentSubtitle,
                              referenceId: result.referenceId,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _PrimaryPillButton(
                      text: "View in My Visits",
                      enabled: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ViewingsScreen(
                              title: "My Visits",
                              viewings: ViewingStore.items,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SecondaryPillButton(
                      text: "Back",
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _statusText(String backendStatus) {
    switch (backendStatus.toLowerCase()) {
      case "approved":
        return "Approved";
      case "rejected":
        return "Rejected";
      case "completed":
        return "Completed";
      case "cancelled":
        return "Cancelled";
      case "pending":
      default:
        return "Pending confirmation";
    }
  }

  Color _statusColor(String backendStatus) {
    switch (backendStatus.toLowerCase()) {
      case "approved":
        return AppColors.brandGreenDeep;
      case "rejected":
        return AppColors.tenantDangerDeep;
      case "completed":
        return AppColors.brandBlueSoft;
      case "cancelled":
        return AppColors.tenantBorderMuted;
      case "pending":
      default:
        return AppColors.tenantIconBgSand;
    }
  }
}

class RequestFailedScreen extends StatelessWidget {
  const RequestFailedScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
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
            title: "Couldn’t send request",
            leadingIcon: Icons.close_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenV,
                AppSpacing.lg,
                AppSpacing.screenV,
                AppSizes.screenBottomPad,
              ),
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
                          "Couldn’t send request",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary(context),
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          message ??
                              "Please check your connection and try again.",
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted(context)
                                        .withValues(alpha: 0.92),
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _PrimaryPillButton(
                          text: "Try Again",
                          enabled: true,
                          onTap: () => Navigator.of(context).pop(true),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _SecondaryPillButton(
                          text: "Close",
                          onTap: () => Navigator.of(context).pop(false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------- small UI pieces ----------
class _ListingMiniCard extends StatelessWidget {
  const _ListingMiniCard({required this.listing, this.compact = false});

  final VisitListingCardVM listing;
  final bool compact;

  bool _isUrl(String s) => s.startsWith("http://") || s.startsWith("https://");

  @override
  Widget build(BuildContext context) {
    final imgH = compact
        ? (AppSizes.listThumbSize * 2.2)
        : (AppSizes.listThumbSize * 2.7);

    final asset = (listing.photoAssetPath ?? "").trim();
    final url = (listing.photoUrl ?? "").trim();

    Widget image;
    if (asset.isNotEmpty && asset.startsWith("assets/")) {
      image = Image.asset(asset, fit: BoxFit.cover);
    } else if (url.isNotEmpty && _isUrl(url)) {
      image = Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: Icon(
              Icons.home_rounded,
              size: AppSpacing.xxxl + AppSpacing.lg,
              color: AppColors.brandBlueSoft,
            ),
          );
        },
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.home_rounded,
            size: AppSpacing.xxxl + AppSpacing.lg,
            color: AppColors.brandBlueSoft,
          ),
        ),
      );
    } else {
      image = Center(
        child: Icon(
          Icons.home_rounded,
          size: AppSpacing.xxxl + AppSpacing.lg,
          color: AppColors.brandBlueSoft,
        ),
      );
    }

    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: SizedBox(
                height: imgH,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: AppColors.overlay(context, 0.06),
                        child: image,
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      bottom: AppSpacing.md,
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
                          listing.priceLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            const SizedBox(height: AppSpacing.md),
            Text(
              listing.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              listing.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted(context).withValues(alpha: 0.92),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _DateChipsRow extends StatelessWidget {
  const _DateChipsRow({
    required this.dates,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
  });

  final List<DateTime> dates;
  final DateTime selected;
  final String Function(DateTime) labelFor;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.pillButtonHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final d = dates[i];
          final isSel = d.year == selected.year &&
              d.month == selected.month &&
              d.day == selected.day;
          return _ChipButton(
            text: labelFor(d),
            selected: isSel,
            onTap: () => onSelected(d),
          );
        },
      ),
    );
  }
}

class _TimeSlot {
  const _TimeSlot({required this.time, required this.available});
  final TimeOfDay time;
  final bool available;
}

class _TimeGrid extends StatelessWidget {
  const _TimeGrid({
    required this.slots,
    required this.selected,
    required this.labelFor,
    required this.onTap,
  });

  final List<_TimeSlot> slots;
  final TimeOfDay? selected;
  final String Function(TimeOfDay) labelFor;
  final ValueChanged<_TimeSlot> onTap;

  @override
  Widget build(BuildContext context) {
    final cross = 3;
    final gap = AppSpacing.sm;

    return LayoutBuilder(
      builder: (context, c) {
        final tileW = (c.maxWidth - (gap * (cross - 1))) / cross;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: slots.map((s) {
            final isSel = selected != null &&
                selected!.hour == s.time.hour &&
                selected!.minute == s.time.minute;
            return SizedBox(
              width: tileW,
              child: _ChipButton(
                text: labelFor(s.time),
                selected: isSel,
                disabled: !s.available,
                trailing: isSel ? Icons.check_rounded : null,
                onTap: () => onTap(s),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({required this.value, required this.onChanged});

  final VisitMode value;
  final ValueChanged<VisitMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ChipButton(
            text: "In-person",
            selected: value == VisitMode.inPerson,
            onTap: () => onChanged(VisitMode.inPerson),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ChipButton(
            text: "Virtual",
            selected: value == VisitMode.virtual,
            onTap: () => onChanged(VisitMode.virtual),
          ),
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.text,
    required this.selected,
    required this.onTap,
    this.disabled = false,
    this.trailing,
  });

  final String text;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.brandBlueSoft.withValues(alpha: 0.22)
        : AppColors.surface(context).withValues(alpha: 0.55);

    final border = selected
        ? AppColors.brandBlueSoft.withValues(alpha: 0.22)
        : AppColors.overlay(context, 0.06);

    final fg = disabled
        ? AppColors.textMuted(context).withValues(alpha: 0.45)
        : AppColors.textPrimary(context);

    return Material(
      color: disabled ? AppColors.overlay(context, 0.02) : bg,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          height: AppSizes.pillButtonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: fg,
                      ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(trailing, size: 18, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MeetingLocationCard extends StatelessWidget {
  const _MeetingLocationCard({required this.listing, this.compact = false});

  final VisitListingCardVM listing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mapH = compact
        ? (AppSizes.listThumbSize * 1.45)
        : (AppSizes.listThumbSize * 1.70);

    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Container(
                height: mapH,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.overlay(context, 0.06),
                ),
                child: Center(
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
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              listing.locationTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              listing.addressLine,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted(context).withValues(alpha: 0.92),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenV,
          vertical: AppSpacing.s10,
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
          ).copyWith(hintText: hint),
        ),
      ),
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({
    required this.text,
    required this.enabled,
    required this.onTap,
  });

  final String text;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || onTap == null;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color:
                                disabled ? AppColors.mutedMid : AppColors.white,
                          ),
                    ),
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

class _SecondaryPillButton extends StatelessWidget {
  const _SecondaryPillButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          height: AppSizes.pillButtonHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
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

class _LinkText extends StatelessWidget {
  const _LinkText({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.brandBlueSoft,
              ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.minTap / 3,
          color: AppColors.textMuted(context),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _SurfaceLine extends StatelessWidget {
  const _SurfaceLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.03),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _AgentMiniCard extends StatelessWidget {
  const _AgentMiniCard({
    required this.name,
    required this.subtitle,
    required this.referenceId,
  });

  final String name;
  final String subtitle;
  final String referenceId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSizes.minTap / 2.6,
            backgroundColor: AppColors.brandBlueSoft.withValues(alpha: 0.22),
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
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Reference ID: $referenceId",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.xxxl + AppSpacing.lg,
      width: AppSpacing.xxxl + AppSpacing.lg,
      decoration: BoxDecoration(
        color: AppColors.brandGreenDeep.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.overlay(context, 0.06)),
        boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
      ),
      child: const Icon(
        Icons.check_rounded,
        color: AppColors.brandGreenDeep,
        size: 44,
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