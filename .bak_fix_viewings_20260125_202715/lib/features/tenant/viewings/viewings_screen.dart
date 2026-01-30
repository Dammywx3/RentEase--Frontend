import 'package:flutter/material.dart';
import 'viewing_detail_screen.dart';

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({super.key});

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

class _ViewingsScreenState extends State<ViewingsScreen> {
  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _text = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);
  static const _green = Color(0xFF3C7C5A);
  static const _blue = Color(0xFF2E5E9A);
  static const _danger = Color(0xFFC75A5A);

  int _tab = 0; // 0 upcoming, 1 completed, 2 cancelled

  // Demo data (swap to backend later)
  final List<_Viewing> _upcoming = [
    _Viewing(
      id: 'v1',
      title: 'Lekki Phase 1 • Unit 3B',
      whenText: 'Sat, May 4 • 2:00 PM',
      location: 'Lekki Phase 1, Lagos',
      agentName: 'Daniel',
      status: _ViewingStatus.confirmed,
      priceText: '₦50,000/month',
    ),
    _Viewing(
      id: 'v2',
      title: 'Victoria Island Condo',
      whenText: 'Sun, May 5 • 11:00 AM',
      location: 'Victoria Island, Lagos',
      agentName: 'Sarah',
      status: _ViewingStatus.confirmed,
      priceText: '₦120,000/month',
    ),
    _Viewing(
      id: 'v3',
      title: 'Ikoyi Villa • Room 5C',
      whenText: 'Fri, May 10 • 1:00 PM',
      location: 'Ikoyi, Lagos',
      agentName: 'Michael',
      status: _ViewingStatus.confirmed,
      priceText: '₦250,000/month',
    ),
  ];

  final List<_Viewing> _completed = [
    _Viewing(
      id: 'c1',
      title: 'Ikeja GRA Apartment',
      whenText: 'Completed • Tue, Apr 16 • 4:30 PM',
      location: 'Ikeja GRA, Lagos',
      agentName: 'Daniel',
      status: _ViewingStatus.completed,
      priceText: '₦90,000/month',
    ),
  ];

  final List<_Viewing> _cancelled = [
    _Viewing(
      id: 'x1',
      title: 'Ajah 2BR Apartment',
      whenText: 'Cancelled • Mon, Apr 8 • 9:00 AM',
      location: 'Ajah, Lagos',
      agentName: 'Sarah',
      status: _ViewingStatus.cancelled,
      priceText: '₦75,000/month',
      cancelReason: 'Agent unavailable',
    ),
  ];

  void _openDetail(_Viewing v) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ViewingDetailScreen(viewing: v)));
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0
        ? _upcoming
        : _tab == 1
        ? _completed
        : _cancelled;

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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
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
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: _text,
                              ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () => _snack('Calendar (wire later)'),
                        icon: const Icon(Icons.calendar_month_rounded),
                      ),
                      IconButton(
                        onPressed: () => _snack('Filter (optional)'),
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ],
                  ),
                ),
              ),

              // segmented tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: _SegmentedTabs(
                    index: _tab,
                    labels: const ['Upcoming', 'Completed', 'Cancelled'],
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                ),
              ),

              // content
              if (list.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    onBrowse: () => Navigator.of(context).maybePop(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 140),
                  sliver: SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final v = list[i];
                      return _ViewingTicketCard(
                        viewing: v,
                        onTap: () => _openDetail(v),
                        onDirections: () => _snack('Directions: ${v.location}'),
                        onReschedule: () => _snack('Reschedule: ${v.title}'),
                        onCancel: () => _snack('Cancel: ${v.title}'),
                        muted: _muted,
                        green: _green,
                        blue: _blue,
                        danger: _danger,
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

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
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
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: index == i
                        ? const Color(0xFF2E5E9A).withValues(alpha: 0.20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: index == i
                            ? const Color(0xFF2E5E9A)
                            : const Color(0xFF6F7785),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewingTicketCard extends StatelessWidget {
  const _ViewingTicketCard({
    required this.viewing,
    required this.onTap,
    required this.onDirections,
    required this.onReschedule,
    required this.onCancel,
    required this.muted,
    required this.green,
    required this.blue,
    required this.danger,
  });

  final _Viewing viewing;
  final VoidCallback onTap;
  final VoidCallback onDirections;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  final Color muted;
  final Color green;
  final Color blue;
  final Color danger;

  @override
  Widget build(BuildContext context) {
    final pill = _statusPill(viewing.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 12),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                children: [
                  // thumbnail
                  ClipRRct(
                    radius: 14,
                    child: Container(
                      height: 74,
                      width: 74,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFC8D3E6), Color(0xFF93A8C6)],
                        ),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // middle details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2A3A),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          viewing.whenText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2A3A),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          viewing.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: muted.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Agent: ${viewing.agentName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: muted.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // right side
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      pill,
                      const SizedBox(height: 10),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF6F7785),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // quick actions row
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniAction(
                      icon: Icons.directions_rounded,
                      label: 'Directions',
                      onTap: onDirections,
                      color: blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniAction(
                      icon: Icons.schedule_rounded,
                      label: 'Reschedule',
                      onTap: onReschedule,
                      color: const Color(0xFFD07A53),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniAction(
                      icon: Icons.close_rounded,
                      label: 'Cancel',
                      onTap: onCancel,
                      color: danger,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(_ViewingStatus status) {
    Color bg;
    String text;

    switch (status) {
      case _ViewingStatus.requested:
        bg = const Color(0xFF2E5E9A);
        text = 'Requested';
        break;
      case _ViewingStatus.confirmed:
        bg = const Color(0xFF3C7C5A);
        text = 'Confirmed';
        break;
      case _ViewingStatus.completed:
        bg = const Color(0xFF4E5A6D);
        text = 'Completed';
        break;
      case _ViewingStatus.cancelled:
        bg = const Color(0xFFC75A5A);
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          height: 1.0,
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
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 40, 18, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.60),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 46,
              color: Color(0xFF6F7785),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No viewings yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E2A3A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Browse listings and book your first viewing.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6F7785),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C7C5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Browse listings',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple clip helper (no extra file)
class ClipRRect extends StatelessWidget {
  const ClipRRect({super.key, required this.radius, required this.child});
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}

enum _ViewingStatus { requested, confirmed, completed, cancelled }

class _Viewing {
  const _Viewing({
    required this.id,
    required this.title,
    required this.whenText,
    required this.location,
    required this.agentName,
    required this.status,
    required this.priceText,
    this.cancelReason,
  });

  final String id;
  final String title;
  final String whenText;
  final String location;
  final String agentName;
  final _ViewingStatus status;
  final String priceText;
  final String? cancelReason;
}
