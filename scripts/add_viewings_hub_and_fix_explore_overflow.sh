#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_viewings_hub_$TS"
mkdir -p "$BACKUP_DIR"

backup() {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

# ---------------- backups ----------------
backup "lib/features/tenant/viewings/viewings_screen.dart"
backup "lib/features/tenant/viewings/viewing_detail_screen.dart"
backup "lib/features/tenant/explore/explore_screen.dart"

# ---------------- write My Viewings hub ----------------
mkdir -p "lib/features/tenant/viewings"

cat > lib/features/tenant/viewings/viewings_screen.dart <<'DART'
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ViewingDetailScreen(viewing: v)),
    );
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      child: const Icon(Icons.apartment_rounded, color: Colors.white),
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2A3A),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          viewing.whenText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2A3A),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          viewing.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Agent: ${viewing.agentName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF6F7785)),
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
            child: const Icon(Icons.event_busy_rounded, size: 46, color: Color(0xFF6F7785)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
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
DART

# ---------------- write Viewing details screen ----------------
cat > lib/features/tenant/viewings/viewing_detail_screen.dart <<'DART'
import 'package:flutter/material.dart';
import 'viewings_screen.dart';

class ViewingDetailScreen extends StatelessWidget {
  const ViewingDetailScreen({super.key, required this.viewing});

  final _Viewing viewing;

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _text = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);

  static const _green = Color(0xFF3C7C5A);
  static const _blue = Color(0xFF2E5E9A);
  static const _danger = Color(0xFFC75A5A);

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCancel = viewing.status == _ViewingStatus.confirmed ||
        viewing.status == _ViewingStatus.requested;

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
              // hero
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _snack(context, 'Share (optional)'),
                        icon: const Icon(Icons.ios_share_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        Container(
                          height: 210,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFC8D3E6), Color(0xFF93A8C6)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.apartment_rounded, size: 60, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          bottom: 14,
                          child: Text(
                            viewing.priceText,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                      color: Colors.black.withValues(alpha: 0.35),
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Text(
                    viewing.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: _text,
                        ),
                  ),
                ),
              ),

              // date/time card + add calendar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: _Card(
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded, color: Color(0xFFB24B4B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            viewing.whenText.replaceAll('Completed • ', '').replaceAll('Cancelled • ', ''),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: _text,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _snack(context, 'Add to Calendar (wire later)'),
                          child: const Text('+ Add to Calendar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // location + mini map
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on_rounded, color: Color(0xFF2E5E9A)),
                            SizedBox(width: 8),
                            Text('Location', style: TextStyle(fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          viewing.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: _text,
                              ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            color: Colors.black.withValues(alpha: 0.04),
                            child: Stack(
                              children: [
                                // simple “map” placeholder
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: CustomPaint(
                                      painter: _MapGridPainter(),
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: Icon(Icons.location_pin, size: 42, color: Color(0xFF2E5E9A)),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _snack(context, 'Get directions (wire to maps)'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                                      foregroundColor: _text,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.directions_rounded),
                                    label: const Text('Get directions'),
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
              ),

              // contact
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.support_agent_rounded, color: Color(0xFF3C7C5A)),
                            SizedBox(width: 8),
                            Text('Contact', style: TextStyle(fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.black.withValues(alpha: 0.05),
                              child: const Icon(Icons.person_rounded, color: Color(0xFF6F7785)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    viewing.agentName,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: _text,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Real Estate Agent',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: _muted,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _snack(context, 'Chat agent (wire later)'),
                              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2E5E9A)),
                            ),
                            IconButton(
                              onPressed: () => _snack(context, 'Call agent (wire later)'),
                              icon: const Icon(Icons.call_rounded, color: Color(0xFF3C7C5A)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // timeline
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: _Card(
                    child: _Timeline(status: viewing.status),
                  ),
                ),
              ),

              // buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 140),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _snack(context, 'Reschedule (wire later)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue.withValues(alpha: 0.85),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Reschedule  ›', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: canCancel ? () => _snack(context, 'Cancel viewing (wire later)') : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _danger.withValues(alpha: 0.85),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Cancel viewing', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
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
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: child,
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final _ViewingStatus status;

  @override
  Widget build(BuildContext context) {
    final requestedOn = status == _ViewingStatus.requested ||
        status == _ViewingStatus.confirmed ||
        status == _ViewingStatus.completed;
    final confirmedOn = status == _ViewingStatus.confirmed || status == _ViewingStatus.completed;
    final completedOn = status == _ViewingStatus.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E2A3A),
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Step(label: 'Requested', on: requestedOn),
            _Line(on: confirmedOn),
            _Step(label: 'Confirmed', on: confirmedOn),
            _Line(on: completedOn),
            _Step(label: 'Completed', on: completedOn),
          ],
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.on});
  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? const Color(0xFF3C7C5A) : const Color(0xFFB8C0CF),
          ),
          child: on
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: on ? const Color(0xFF1E2A3A) : const Color(0xFF6F7785),
              ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: on ? const Color(0xFF3C7C5A) : const Color(0xFFB8C0CF),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

// mini “map” painter (placeholder)
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E5E9A).withValues(alpha: 0.10)
      ..strokeWidth = 1.0;

    const step = 18.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
DART

# ---------------- patch explore: Viewings click navigates + overflow safety ----------------
python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/features/tenant/explore/explore_screen.dart")
s = p.read_text(encoding="utf-8")

# Ensure viewings import exists
if "viewings_screen.dart" not in s:
    # Add after existing tenant imports (near listing_detail import)
    # Safe: insert after first line containing listing_detail import OR after first package import block
    if "listing_detail_screen.dart" in s:
        s = s.replace(
            "import '../listing_detail/listing_detail_screen.dart';",
            "import '../listing_detail/listing_detail_screen.dart';\nimport '../viewings/viewings_screen.dart';"
        )
    else:
        # fallback: insert after first import line
        s = re.sub(r'^(import .+;\s*)\n', r'\1\nimport \'../viewings/viewings_screen.dart\';\n', s, count=1, flags=re.M)

# Replace the Viewings small pill onTap from toast to navigation
# We target the specific block: text: 'Viewings'
pattern = r"(_SmallPill\(\s*[\s\S]*?text:\s*'Viewings',\s*[\s\S]*?onTap:\s*\(\)\s*=>\s*_toast\([^\)]*\),\s*[\s\S]*?\)\s*,)"
def repl(m):
    block = m.group(1)
    block = re.sub(
        r"onTap:\s*\(\)\s*=>\s*_toast\([^\)]*\),",
        "onTap: () => Navigator.of(context).push(\n"
        "      MaterialPageRoute(builder: (_) => const ViewingsScreen()),\n"
        "    ),",
        block
    )
    return block

s2, n = re.subn(pattern, repl, s, flags=re.M)

# Overflow safety: ensure _SmallPill text never overflows
# Replace the Text widget inside _SmallPill builder to use Flexible + FittedBox if present.
# We do a safe small replacement: find "Text(" inside _SmallPill and wrap with Flexible->FittedBox.
s2 = re.sub(
    r"(class _SmallPill[\s\S]*?child:\s*Row\([\s\S]*?children:\s*\[\s*Icon\([^\)]*\),\s*const SizedBox\(width:\s*8\),\s*)Text\(",
    r"\1Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(",
    s2,
    count=1,
    flags=re.M
)
s2 = re.sub(
    r"(Flexible\(child:\s*FittedBox\([\s\S]*?child:\s*Text\([\s\S]*?\)\s*,\s*)\)\s*,\s*(\]\s*\)\s*,\s*\)\s*;)",
    r"\1)),\n            \2",
    s2,
    count=1,
    flags=re.M
)

p.write_text(s2, encoding="utf-8")
print(f"✅ Explore patched: Viewings now opens ViewingsScreen. Changes applied: {n}")
PY

echo "🎨 dart format..."
dart format lib >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backup saved in: $BACKUP_DIR"
