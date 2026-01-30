import 'package:flutter/material.dart';
import '../../../shared/models/viewing_model.dart';
import 'viewing_detail_screen.dart';

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({super.key});

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

class _ViewingsScreenState extends State<ViewingsScreen> {
  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  int _tab = 0; // 0 Upcoming, 1 Completed, 2 Cancelled

  final List<ViewingModel> _all = const [
    ViewingModel(
      id: 'v1',
      listingTitle: 'Lekki Phase 1 • Unit 3B',
      location: 'Lekki, Lagos',
      agentName: 'Daniel',
      priceNgnPerMonth: 50000,
      dateLabel: 'Sat, May 4',
      timeLabel: '2:00 PM',
      status: ViewingStatus.confirmed,
    ),
    ViewingModel(
      id: 'v2',
      listingTitle: 'Victoria Island Condo',
      location: 'Victoria Island, Lagos',
      agentName: 'Esther',
      priceNgnPerMonth: 120000,
      dateLabel: 'Sun, May 5',
      timeLabel: '11:00 AM',
      status: ViewingStatus.confirmed,
    ),
    ViewingModel(
      id: 'v3',
      listingTitle: 'Ikoyi Villa • Room 5C',
      location: 'Ikoyi, Lagos',
      agentName: 'Kola',
      priceNgnPerMonth: 180000,
      dateLabel: 'Fri, May 10',
      timeLabel: '1:00 PM',
      status: ViewingStatus.requested,
    ),
    ViewingModel(
      id: 'v4',
      listingTitle: 'Ajah Apartment • Block A',
      location: 'Ajah, Lagos',
      agentName: 'Tomi',
      priceNgnPerMonth: 65000,
      dateLabel: 'Wed, Apr 10',
      timeLabel: '4:00 PM',
      status: ViewingStatus.completed,
    ),
    ViewingModel(
      id: 'v5',
      listingTitle: 'Yaba Studio',
      location: 'Yaba, Lagos',
      agentName: 'Seyi',
      priceNgnPerMonth: 40000,
      dateLabel: 'Mon, Apr 1',
      timeLabel: '10:00 AM',
      status: ViewingStatus.cancelled,
    ),
  ];

  String _fmtNaira(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return '₦$buf';
  }

  List<ViewingModel> get _filtered {
    if (_tab == 0) {
      return _all.where((x) => x.status.isUpcoming).toList();
    }
    if (_tab == 1) {
      return _all.where((x) => x.status == ViewingStatus.completed).toList();
    }
    return _all.where((x) => x.status == ViewingStatus.cancelled).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return DecoratedBox(
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
            _TopBar(
              title: 'My Viewings',
              onBack: () => Navigator.of(context).maybePop(),
              onCalendar: () {},
              onFilter: () {},
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _SegmentedTabs(
                index: _tab,
                labels: const ['Upcoming', 'Completed', 'Cancelled'],
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: items.isEmpty
                  ? _EmptyState(
                      onBrowse: () => Navigator.of(context).maybePop(),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 120),
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final v = items[i];
                        return _ViewingTicketCard(
                          viewing: v,
                          priceText: '${_fmtNaira(v.priceNgnPerMonth)}/month',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ViewingDetailScreen(viewing: v),
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
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onCalendar,
    required this.onFilter,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onCalendar;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left_rounded, size: 30),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2A3A),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onCalendar,
            icon: const Icon(Icons.calendar_month_rounded),
          ),
          IconButton(onPressed: onFilter, icon: const Icon(Icons.tune_rounded)),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.index,
    required this.labels,
    required this.onChanged,
  });

  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  static const _active = Color(0xFF3C7C5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active
                      ? _active.withValues(alpha: 0.20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: active ? _active : const Color(0xFF6F7785),
                    ),
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

class _ViewingTicketCard extends StatelessWidget {
  const _ViewingTicketCard({
    required this.viewing,
    required this.priceText,
    required this.onTap,
    required this.onDirections,
    required this.onReschedule,
    required this.onCancel,
  });

  final ViewingModel viewing;
  final String priceText;
  final VoidCallback onTap;
  final VoidCallback onDirections;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  static const _green = Color(0xFF3C7C5A);

  Color _pillColor(ViewingStatus s) {
    switch (s) {
      case ViewingStatus.confirmed:
        return _green;
      case ViewingStatus.requested:
        return const Color(0xFF2E5E9A);
      case ViewingStatus.completed:
        return const Color(0xFF3C7C5A);
      case ViewingStatus.cancelled:
        return const Color(0xFFB54A4A);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ No overflow: everything is constrained + text maxLines
    return _FrostCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 62,
                      width: 76,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFB9C7DD), Color(0xFF879BB8)],
                        ),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewing.listingTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2A3A),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: Color(0xFF6F7785),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${viewing.dateLabel} • ${viewing.timeLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E2A3A),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${viewing.location} • ${viewing.agentName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6F7785),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusPill(
                        text: viewing.status.label,
                        color: _pillColor(viewing.status),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        priceText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF6F7785),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF6F7785),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniAction(
                      icon: Icons.directions_rounded,
                      text: 'Directions',
                      onTap: onDirections,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniAction(
                      icon: Icons.event_repeat_rounded,
                      text: 'Reschedule',
                      onTap: onReschedule,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniAction(
                      icon: Icons.close_rounded,
                      text: 'Cancel',
                      danger: true,
                      onTap: onCancel,
                    ),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: color,
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
    this.danger = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? const Color(0xFFB54A4A) : const Color(0xFF2E5E9A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 56,
                color: Color(0xFF3C7C5A),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No viewings yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse listings and book your first viewing.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6F7785),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C7C5A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Browse listings'),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: child,
    );
  }
}
