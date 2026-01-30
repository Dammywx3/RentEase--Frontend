import 'package:flutter/material.dart';

import '../../../core/constants/status_badge_map.dart';
import '../../../shared/widgets/status_badge.dart';
import 'viewing_detail_screen.dart';

enum ViewingState { requested, confirmed, completed, cancelled }

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({super.key});

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

class _ViewingsScreenState extends State<ViewingsScreen> {
  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _blue = Color(0xFF2E5E9A);
  static const _muted = Color(0xFF6F7785);

  int _tab = 0; // 0 upcoming, 1 completed, 2 cancelled

  late final List<_Viewing> _all = [
    _Viewing(
      id: 'v1',
      listingTitle: 'Lekki Phase 1 • Unit 3B',
      location: 'Lekki, Lagos',
      agentName: 'Daniel Okafor',
      dateTime: DateTime.now().add(const Duration(days: 4, hours: 2)),
      status: ViewingState.confirmed,
    ),
    _Viewing(
      id: 'v2',
      listingTitle: 'Ikoyi • Riverside Flat',
      location: 'Ikoyi, Lagos',
      agentName: 'Blessing Ade',
      dateTime: DateTime.now().add(const Duration(days: 9, hours: 1)),
      status: ViewingState.requested,
    ),
    _Viewing(
      id: 'v3',
      listingTitle: 'Ajah • Family Duplex',
      location: 'Ajah, Lagos',
      agentName: 'Tobi Musa',
      dateTime: DateTime.now().subtract(const Duration(days: 8)),
      status: ViewingState.completed,
    ),
    _Viewing(
      id: 'v4',
      listingTitle: 'Yaba • Studio',
      location: 'Yaba, Lagos',
      agentName: 'Aisha Bello',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      status: ViewingState.cancelled,
    ),
  ];

  List<_Viewing> get _filtered {
    if (_tab == 0) {
      return _all
          .where(
            (v) =>
                v.status == ViewingState.requested ||
                v.status == ViewingState.confirmed,
          )
          .toList();
    }
    if (_tab == 1) {
      return _all.where((v) => v.status == ViewingState.completed).toList();
    }
    return _all.where((v) => v.status == ViewingState.cancelled).toList();
  }

  String _statusRaw(ViewingState s) {
    switch (s) {
      case ViewingState.requested:
        return 'pending';
      case ViewingState.confirmed:
        return 'approved';
      case ViewingState.completed:
        return 'completed';
      case ViewingState.cancelled:
        return 'cancelled';
    }
  }

  String _fmtDate(DateTime dt) {
    final w = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][dt.weekday % 7];
    final m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][dt.month - 1];
    final day = dt.day;
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$w, $m $day • $hour12:$min $ampm';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
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
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'My Viewings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E2A3A),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toast('Calendar (wire later)'),
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                    IconButton(
                      onPressed: () => _toast('Filter (wire later)'),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
              ),

              // Segmented control
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: _Segmented(
                  index: _tab,
                  labels: const ['Upcoming', 'Completed', 'Cancelled'],
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),

              // List (✅ Expanded prevents overflow)
              Expanded(
                child: items.isEmpty
                    ? _EmptyState(onBrowse: () => _toast('Browse listings'))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final v = items[i];
                          return _ViewingTicketCard(
                            viewing: v,
                            dateText: _fmtDate(v.dateTime),
                            statusRaw: _statusRaw(v.status),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ViewingDetailScreen(viewing: v),
                                ),
                              );
                            },
                            onDirections: () =>
                                _toast('Directions (wire later)'),
                            onReschedule: () =>
                                _toast('Reschedule (wire later)'),
                            onCancel: () => _toast('Cancel (wire later)'),
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

class _Viewing {
  const _Viewing({
    required this.id,
    required this.listingTitle,
    required this.location,
    required this.agentName,
    required this.dateTime,
    required this.status,
  });

  final String id;
  final String listingTitle;
  final String location;
  final String agentName;
  final DateTime dateTime;
  final ViewingState status;
}

class _ViewingTicketCard extends StatelessWidget {
  const _ViewingTicketCard({
    required this.viewing,
    required this.dateText,
    required this.statusRaw,
    required this.onTap,
    required this.onDirections,
    required this.onReschedule,
    required this.onCancel,
  });

  final _Viewing viewing;
  final String dateText;
  final String statusRaw;

  final VoidCallback onTap;
  final VoidCallback onDirections;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  static const _muted = Color(0xFF6F7785);
  static const _blue = Color(0xFF2E5E9A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 66,
                          width: 66,
                          color: const Color(0xFFCFDBEA).withValues(alpha: 0.8),
                          child: const Icon(
                            Icons.home_rounded,
                            color: Color(0xFF2E5E9A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // middle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewing.listingTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1E2A3A),
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1E2A3A),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              viewing.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _muted.withValues(alpha: 0.85),
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              viewing.agentName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _muted.withValues(alpha: 0.85),
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge(
                            domain: StatusDomain.viewing,
                            status: statusRaw,
                            compact: false,
                          ),
                          const SizedBox(height: 10),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: _muted.withValues(alpha: 0.75),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // quick actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniAction(
                          icon: Icons.directions_rounded,
                          label: 'Directions',
                          onTap: onDirections,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniAction(
                          icon: Icons.schedule_rounded,
                          label: 'Reschedule',
                          onTap: onReschedule,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniAction(
                          icon: Icons.close_rounded,
                          label: 'Cancel',
                          onTap: onCancel,
                          danger: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? const Color(0xFFB54A4A) : const Color(0xFF2E5E9A);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.60),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.index,
    required this.labels,
    required this.onChanged,
  });

  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.95)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                            color: Colors.black.withValues(alpha: 0.08),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E2A3A),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 66,
              color: const Color(0xFF2E5E9A).withValues(alpha: 0.65),
            ),
            const SizedBox(height: 12),
            Text(
              'No viewings yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse listings and book a viewing in seconds.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6F7785),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onBrowse,
              child: const Text('Browse listings'),
            ),
          ],
        ),
      ),
    );
  }
}
