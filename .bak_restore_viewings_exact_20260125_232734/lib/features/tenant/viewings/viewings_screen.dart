import "package:flutter/material.dart";

import "../../../shared/models/viewing_model.dart";
import "viewing_detail_screen.dart";

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({super.key});

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

enum _Tab { upcoming, completed, cancelled }

class _ViewingsScreenState extends State<ViewingsScreen> {
  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _text = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);

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
      listingTitle: "Ikoyi • Ocean View",
      location: "Ikoyi, Lagos",
      agentName: "Blessing O.",
      dateTime: DateTime.now().add(const Duration(days: 5, hours: 1)),
      status: ViewingStatus.requested,
      priceText: "₦120,000 / month",
    ),
    ViewingModel(
      id: "v3",
      listingTitle: "Yaba • Studio Apartment",
      location: "Yaba, Lagos",
      agentName: "Tunde K.",
      dateTime: DateTime.now().subtract(const Duration(days: 12)),
      status: ViewingStatus.completed,
      priceText: "₦35,000 / month",
    ),
    ViewingModel(
      id: "v4",
      listingTitle: "Ajah • Family Duplex",
      location: "Ajah, Lagos",
      agentName: "Chioma I.",
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
      status: ViewingStatus.cancelled,
      priceText: "₦80,000 / month",
    ),
  ];

  List<ViewingModel> get _filtered {
    switch (_tab) {
      case _Tab.upcoming:
        return _all
            .where(
              (v) =>
                  v.status == ViewingStatus.requested ||
                  v.status == ViewingStatus.confirmed,
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      case _Tab.completed:
        return _all.where((v) => v.status == ViewingStatus.completed).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      case _Tab.cancelled:
        return _all.where((v) => v.status == ViewingStatus.cancelled).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
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

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                child: Row(
                  children: [
                    Text(
                      "My Viewings",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _text,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ],
                ),
              ),
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
                          return _Ticket(
                            title: v.listingTitle,
                            subtitle:
                                "${_fmtDateTime(v.dateTime)} • ${v.location}",
                            status: v.status.label,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ViewingDetailScreen(viewing: v),
                                ),
                              );
                            },
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
              ? Colors.white.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.50),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => onChanged(t),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E2A3A),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          tab(_Tab.upcoming, "Upcoming"),
          const SizedBox(width: 8),
          tab(_Tab.completed, "Completed"),
          const SizedBox(width: 8),
          tab(_Tab.cancelled, "Cancelled"),
        ],
      ),
    );
  }
}

class _Ticket extends StatelessWidget {
  const _Ticket({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.70),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 58,
                  width: 58,
                  color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.home_rounded,
                    color: Color(0xFF2E5E9A),
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6F7785),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E2A3A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
