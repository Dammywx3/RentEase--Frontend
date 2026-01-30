import "package:flutter/material.dart";

import '../../../core/ui/scaffold/app_top_bar.dart';
import "../../../shared/models/viewing_model.dart";
import "viewing_detail_screen.dart";
import '../../../core/ui/scaffold/app_scaffold.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({super.key});

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

enum _Tab { upcoming, completed }

class _ViewingsScreenState extends State<ViewingsScreen> {
  static const _bgTop = AppColors.lightBg;
  static const _bgBottom = AppColors.mist;
  static const _text = AppColors.navy;
  static const _muted = AppColors.textMutedLight;
  static const _blue = AppColors.brandBlueSoft;
  static const _green = AppColors.brandGreenDeep;
  static const _red = Color(0xFFB54A4A);

  _Tab _tab = _Tab.upcoming;

  final List<ViewingModel> _all = [
    ViewingModel(
      id: "v1",
      listingTitle: "Lekki Phase 1 • Unit 3B",
      location: "Lekki, Lagos",
      agentName: "Adekunle A.",
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
      status: ViewingStatus.confirmed,
      priceText: "₦50,000 / month",
    ),
    ViewingModel(
      id: "v2",
      listingTitle: "Victoria Island Condo",
      location: "Victoria Island, Lagos",
      agentName: "Blessing O.",
      dateTime: DateTime.now().add(const Duration(days: 5, hours: 1)),
      status: ViewingStatus.confirmed,
      priceText: "₦120,000 / month",
    ),
    ViewingModel(
      id: "v3",
      listingTitle: "Ikoyi Villa • Room 5C",
      location: "Ikoyi, Lagos",
      agentName: "Tunde K.",
      dateTime: DateTime.now().add(const Duration(days: 10, hours: 1)),
      status: ViewingStatus.confirmed,
      priceText: "₦80,000 / month",
    ),
    ViewingModel(
      id: "v4",
      listingTitle: "Yaba • Studio Apartment",
      location: "Yaba, Lagos",
      agentName: "Chioma I.",
      dateTime: DateTime.now().subtract(const Duration(days: 12)),
      status: ViewingStatus.completed,
      priceText: "₦35,000 / month",
    ),
  ];

  List<ViewingModel> get _filtered {
    switch (_tab) {
      case _Tab.upcoming:
        final list =
            _all
                .where(
                  (v) =>
                      v.status == ViewingStatus.requested ||
                      v.status == ViewingStatus.confirmed,
                )
                .toList()
              ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return list;
      case _Tab.completed:
        final list =
            _all.where((v) => v.status == ViewingStatus.completed).toList()
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
        return list;
    }
  }

  String _fmtDateTime(DateTime dt) {
    const wds = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const mos = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final wd = wds[dt.weekday - 1];
    final mo = mos[dt.month - 1];
    final hour12 = (dt.hour % 12 == 0) ? 12 : (dt.hour % 12);
    final ampm = dt.hour >= 12 ? "PM" : "AM";
    final mm = dt.minute.toString().padLeft(2, "0");
    return "$wd, $mo ${dt.day} • $hour12:$mm $ampm";
  }

  String _dateOnly(DateTime dt) {
    const mos = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final mo = mos[dt.month - 1];
    return "$mo ${dt.day}";
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      topBar: const AppTopBar(title: 'Viewings'),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    Expanded(
                      child: Text(
                        "My Viewings",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: _text,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ],
                ),
              ),

              // tabs (Upcoming / Completed like the screenshot)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: _muted,
                              ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final v = items[i];
                          final statusChip = v.status == ViewingStatus.confirmed
                              ? "Confirmed"
                              : (v.status == ViewingStatus.requested
                                    ? "Requested"
                                    : "Completed");

                          final statusColor =
                              v.status == ViewingStatus.confirmed
                              ? _green
                              : (v.status == ViewingStatus.requested
                                    ? _blue
                                    : _muted);

                          return _ViewingCard(
                            title: v.listingTitle,
                            line1: _fmtDateTime(v.dateTime),
                            line2: _dateOnly(v.dateTime),
                            location: v.location,
                            statusText: statusChip,
                            statusColor: statusColor,
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
                            cancelColor: _red,
                          );
                        },
                      ),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    Widget tab(_Tab t, String label) {
      final selected = value == t;
      return Expanded(
        child: Material(
          color: selected
              ? AppColors.brandBlueSoft.withValues(alpha: 0.24)
              : AppColors.surface(context).withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => onChanged(t),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
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
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.surface(context).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          tab(_Tab.upcoming, "Upcoming"),
          const SizedBox(width: 8),
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
    required this.line2,
    required this.location,
    required this.statusText,
    required this.statusColor,
    required this.onTap,
    required this.onDirections,
    required this.onReschedule,
    required this.onCancel,
    required this.cancelColor,
  });

  final String title;
  final String line1;
  final String line2;
  final String location;

  final String statusText;
  final Color statusColor;

  final VoidCallback onTap;
  final VoidCallback onDirections;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  final Color cancelColor;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  // thumbnail like screenshot
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 64,
                      width: 72,
                      color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.home_rounded,
                        color: AppColors.brandBlueSoft,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(
                              Icons.event_rounded,
                              size: 16,
                              color: Color(0xFFB24A5A),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                line1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textMutedLight,
                                    ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 6),
                        Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.brandBlueSoft,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // action row like screenshot (NO overflow)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MiniAction(
                    icon: Icons.directions_rounded,
                    text: "Directions",
                    onTap: onDirections,
                  ),
                  _MiniAction(
                    icon: Icons.schedule_rounded,
                    text: "Reschedule",
                    onTap: onReschedule,
                  ),
                  _MiniAction(
                    icon: Icons.close_rounded,
                    text: "Cancel",
                    onTap: onCancel,
                    textColor: cancelColor,
                    iconColor: cancelColor,
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
    final ic = iconColor ?? AppColors.textMutedLight;

    return Material(
      color: AppColors.overlay(context, 0.04),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: ic),
              const SizedBox(width: 8),
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
