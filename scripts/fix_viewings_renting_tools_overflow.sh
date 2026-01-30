#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
BACKUP_DIR=".bak_viewings_renting_tools_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📍 Repo: $ROOT"
echo "🗂️ Backup -> $BACKUP_DIR"

backup_file () {
  local f="$1"
  if [[ -f "$f" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

# Backups
backup_file "lib/features/tenant/viewings/viewings_screen.dart"
backup_file "lib/features/tenant/viewings/viewing_detail_screen.dart"
backup_file "lib/features/tenant/more/more_screen.dart"
backup_file "lib/shared/models/viewing_model.dart"
backup_file "lib/features/tenant/renting_tools/renting_tools_screen.dart"
backup_file "lib/features/tenant/alerts/alerts_screen.dart"

mkdir -p lib/shared/models
mkdir -p lib/features/tenant/viewings
mkdir -p lib/features/tenant/renting_tools
mkdir -p lib/features/tenant/more

echo "🧱 Write: lib/shared/models/viewing_model.dart"
cat > lib/shared/models/viewing_model.dart <<'DART'
class ViewingModel {
  const ViewingModel({
    required this.id,
    required this.listingTitle,
    required this.location,
    required this.agentName,
    required this.priceNgnPerMonth,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    this.imageUrl,
  });

  final String id;
  final String listingTitle;
  final String location;
  final String agentName;
  final int priceNgnPerMonth;
  final String dateLabel; // e.g. "Sat, May 4"
  final String timeLabel; // e.g. "2:00 PM"
  final ViewingStatus status;
  final String? imageUrl;
}

enum ViewingStatus { requested, confirmed, completed, cancelled }

extension ViewingStatusX on ViewingStatus {
  String get label {
    switch (this) {
      case ViewingStatus.requested:
        return 'Requested';
      case ViewingStatus.confirmed:
        return 'Confirmed';
      case ViewingStatus.completed:
        return 'Completed';
      case ViewingStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isUpcoming => this == ViewingStatus.requested || this == ViewingStatus.confirmed;
}
DART

echo "🧱 Write: lib/features/tenant/viewings/viewings_screen.dart (premium hub + no overflow)"
cat > lib/features/tenant/viewings/viewings_screen.dart <<'DART'
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
          IconButton(
            onPressed: onFilter,
            icon: const Icon(Icons.tune_rounded),
          ),
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
                  color: active ? _active.withValues(alpha: 0.20) : Colors.transparent,
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
                        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                      ),
                      child: const Icon(Icons.apartment_rounded, color: Colors.white),
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2A3A),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF6F7785)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${viewing.dateLabel} • ${viewing.timeLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF6F7785)),
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
              child: const Icon(Icons.event_available_rounded, size: 56, color: Color(0xFF3C7C5A)),
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
DART

echo "🧱 Write: lib/features/tenant/viewings/viewing_detail_screen.dart (premium detail)"
cat > lib/features/tenant/viewings/viewing_detail_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../../../shared/models/viewing_model.dart';

class ViewingDetailScreen extends StatelessWidget {
  const ViewingDetailScreen({super.key, required this.viewing});

  final ViewingModel viewing;

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);
  static const _green = Color(0xFF3C7C5A);

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

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.chevron_left_rounded, size: 30),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: _HeroCard(
                    title: viewing.listingTitle,
                    price: '${_fmtNaira(viewing.priceNgnPerMonth)}/month',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: _InfoCard(
                    icon: Icons.calendar_month_rounded,
                    title: '${viewing.dateLabel} • ${viewing.timeLabel}',
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('+ Add to Calendar'),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: _LocationCard(
                    location: viewing.location,
                    onDirections: () {},
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: _ContactCard(agentName: viewing.agentName),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: _Timeline(status: viewing.status),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 120),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E5E9A).withValues(alpha: 0.16),
                            foregroundColor: const Color(0xFF2E5E9A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Reschedule  ›'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: viewing.status.isUpcoming ? () {} : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB54A4A).withValues(alpha: 0.16),
                            foregroundColor: const Color(0xFFB54A4A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel viewing'),
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.price});
  final String title;
  final String price;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFB9C7DD), Color(0xFF879BB8)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.apartment_rounded, size: 60, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Text(
                      price,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                blurRadius: 16,
                                color: Colors.black.withValues(alpha: 0.35),
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2A3A),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.trailing});
  final IconData icon;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB54A4A)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E2A3A),
                    ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location, required this.onDirections});
  final String location;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.location_on_rounded, color: Color(0xFF2E5E9A)),
                SizedBox(width: 8),
                Text(
                  'Location',
                  style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E2A3A)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              location,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2A3A),
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: const Center(
                child: Icon(Icons.map_rounded, size: 38, color: Color(0xFF6F7785)),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onDirections,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E5E9A),
                  side: BorderSide(color: const Color(0xFF2E5E9A).withValues(alpha: 0.35)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Get directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.agentName});
  final String agentName;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black.withValues(alpha: 0.06),
              child: const Icon(Icons.person_rounded, color: Color(0xFF6F7785)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agentName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E2A3A),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Real Estate Agent',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6F7785),
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2E5E9A)),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call_rounded, color: Color(0xFF3C7C5A)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final ViewingStatus status;

  static const _green = Color(0xFF3C7C5A);
  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    final reachedRequested = true;
    final reachedConfirmed = status == ViewingStatus.confirmed || status == ViewingStatus.completed;
    final reachedCompleted = status == ViewingStatus.completed;

    Widget dot(bool on, Color onColor) {
      return Container(
        height: 10,
        width: 10,
        decoration: BoxDecoration(
          color: on ? onColor : _muted.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
    }

    Widget line(bool on, Color onColor) {
      return Expanded(
        child: Container(
          height: 2,
          color: on ? onColor.withValues(alpha: 0.6) : _muted.withValues(alpha: 0.18),
        ),
      );
    }

    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
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
                dot(reachedRequested, const Color(0xFF2E5E9A)),
                line(reachedConfirmed, const Color(0xFF2E5E9A)),
                dot(reachedConfirmed, _green),
                line(reachedCompleted, _green),
                dot(reachedCompleted, _green),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Requested', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: _muted)),
                Text('Confirmed', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: _muted)),
                Text('Completed', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: _muted)),
              ],
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
DART

echo "🧱 Write: lib/features/tenant/renting_tools/renting_tools_screen.dart (premium)"
cat > lib/features/tenant/renting_tools/renting_tools_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../viewings/viewings_screen.dart';

class RentingToolsScreen extends StatefulWidget {
  const RentingToolsScreen({super.key});

  @override
  State<RentingToolsScreen> createState() => _RentingToolsScreenState();
}

class _RentingToolsScreenState extends State<RentingToolsScreen> {
  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);
  static const _green = Color(0xFF3C7C5A);

  final PageController _pc = PageController(viewportFraction: 0.92);
  int _page = 0;

  final List<_Tenancy> _tenancies = const [
    _Tenancy(title: 'Lekki Phase 1 • Unit 3B', dueLabel: 'Due May 1', amountNgn: 50000),
    _Tenancy(title: 'Victoria Island • Apt 12', dueLabel: 'Due May 7', amountNgn: 120000),
    _Tenancy(title: 'Ikoyi • Room 5C', dueLabel: 'Due May 12', amountNgn: 180000),
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

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.chevron_left_rounded, size: 30),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Renting Tools',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1E2A3A),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Text(
                    'Active Tenancies (${_tenancies.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E2A3A),
                        ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 150,
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: _tenancies.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      final t = _tenancies[i];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(i == 0 ? 14 : 8, 0, i == _tenancies.length - 1 ? 14 : 8, 0),
                        child: _TenancyCarouselCard(
                          title: t.title,
                          dueLabel: t.dueLabel,
                          amount: _fmtNaira(t.amountNgn),
                          onView: () {},
                          onPay: () {},
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_tenancies.length, (i) {
                      final active = i == _page;
                      return Container(
                        height: 8,
                        width: active ? 18 : 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: active ? _green : const Color(0xFF6F7785).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: _ToolTile(
                    icon: Icons.home_work_rounded,
                    iconBg: const Color(0xFFD7E6DD),
                    iconFg: _green,
                    title: 'My Tenancies',
                    subtitle: 'Lease status, rent due date, landlord/agent contact',
                    badge: '${_tenancies.length} Active',
                    onTap: () {},
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: _ToolTile(
                    icon: Icons.badge_rounded,
                    iconBg: const Color(0xFFE7E3D1),
                    iconFg: const Color(0xFFC79A2A),
                    title: 'My Applications',
                    subtitle: 'Submitted, In Review, Approved, Rejected',
                    badge: '2 Pending',
                    onTap: () {},
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  child: _ToolTile(
                    icon: Icons.remove_red_eye_rounded,
                    iconBg: const Color(0xFFCFDBEA),
                    iconFg: const Color(0xFF2E5E9A),
                    title: 'My Viewings',
                    subtitle: 'Upcoming, Completed',
                    badge: '2 Upcoming',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ViewingsScreen()));
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Text(
                    'Shortcuts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E2A3A),
                        ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.saved_search_rounded,
                          text: 'Saved Searches',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.receipt_long_rounded,
                          text: 'Proof of Payment',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  child: _Shortcut(
                    icon: Icons.chat_bubble_outline_rounded,
                    text: 'Contact Landlord / Agent',
                    onTap: () {},
                    full: true,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E2A3A),
                        ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 120),
                  child: _ActivityList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tenancy {
  const _Tenancy({required this.title, required this.dueLabel, required this.amountNgn});
  final String title;
  final String dueLabel;
  final int amountNgn;
}

class _TenancyCarouselCard extends StatelessWidget {
  const _TenancyCarouselCard({
    required this.title,
    required this.dueLabel,
    required this.amount,
    required this.onView,
    required this.onPay,
  });

  final String title;
  final String dueLabel;
  final String amount;
  final VoidCallback onView;
  final VoidCallback onPay;

  static const _green = Color(0xFF3C7C5A);

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 92,
                width: 98,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB9C7DD), Color(0xFF879BB8)],
                  ),
                ),
                child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E2A3A),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFFB54A4A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dueLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2A3A),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onView,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E5E9A).withValues(alpha: 0.16),
                            foregroundColor: const Color(0xFF2E5E9A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('View  ›'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onPay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green.withValues(alpha: 0.22),
                            foregroundColor: _green,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Pay $amount'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              _IconChip(icon: icon, bg: iconBg, fg: iconFg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E2A3A),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6F7785),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2A3A),
                      ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF6F7785)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.text, required this.onTap, this.full = false});

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool full;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: full ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF6F7785)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _ActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String text, String when, Color dot) {
      return Row(
        children: [
          Container(height: 10, width: 10, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Icon(icon, size: 18, color: const Color(0xFF6F7785)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2A3A),
                  ),
            ),
          ),
          Text(
            when,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6F7785),
                ),
          ),
        ],
      );
    }

    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          children: [
            row(Icons.calendar_month_rounded, 'Viewing confirmed for Sat 2pm', '2 days ago', const Color(0xFF3C7C5A)),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
            const SizedBox(height: 12),
            row(Icons.check_circle_rounded, 'Application approved', '3 days ago', const Color(0xFFC79A2A)),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
            const SizedBox(height: 12),
            row(Icons.alarm_rounded, 'Rent reminder: due in 5 days', '5 days ago', const Color(0xFF2E5E9A)),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.bg, required this.fg});
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Icon(icon, color: fg, size: 20),
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
DART

echo "🧩 Patch: lib/features/tenant/more/more_screen.dart -> open RentingToolsScreen"
# Insert import + onTap wire
python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/features/tenant/more/more_screen.dart")
s = p.read_text(encoding="utf-8")

if "renting_tools_screen.dart" not in s:
    s = s.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport '../renting_tools/renting_tools_screen.dart';"
    )

# Replace the Renting Tools tile onTap: () {} with Navigator push
s = re.sub(
    r"(title:\s*'Renting Tools',\s*subtitle:\s*'Tenancies\s*•\s*Applications\s*•\s*Viewings',\s*)onTap:\s*\(\)\s*\{\s*\},",
    r"\1onTap: () {\n                  Navigator.of(context).push(\n                    MaterialPageRoute(builder: (_) => const RentingToolsScreen()),\n                  );\n                },",
    s
)

p.write_text(s, encoding="utf-8")
print("✅ MoreScreen wired to RentingToolsScreen.")
PY

echo "🧹 Fix lint: unnecessary_underscores in alerts_screen.dart (if present)"
python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/features/tenant/alerts/alerts_screen.dart")
if p.exists():
    s = p.read_text(encoding="utf-8")
    # Convert common patterns like (_, __) => to (context, error, stackTrace) =>
    s2 = s
    s2 = re.sub(r"\(\s*_\s*,\s*__\s*\)", "(context, error, stackTrace)", s2)
    s2 = re.sub(r"\(\s*_\s*,\s*__\s*,\s*___\s*\)", "(context, error, stackTrace)", s2)
    if s2 != s:
        p.write_text(s2, encoding="utf-8")
        print("✅ alerts_screen.dart underscores lint fixed.")
    else:
        print("ℹ️ alerts_screen.dart unchanged.")
else:
    print("ℹ️ alerts_screen.dart not found; skipping.")
PY

echo "🎨 dart format..."
dart format lib >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backup saved in: $BACKUP_DIR"
