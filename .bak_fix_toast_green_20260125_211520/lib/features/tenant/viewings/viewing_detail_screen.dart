import 'package:flutter/material.dart';
import '../../../shared/models/viewing_model.dart';

class ViewingDetailScreen extends StatelessWidget {
  const ViewingDetailScreen({super.key, required this.viewing});

  final ViewingModel viewing;

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);
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
                            backgroundColor: const Color(
                              0xFF2E5E9A,
                            ).withValues(alpha: 0.16),
                            foregroundColor: const Color(0xFF2E5E9A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Reschedule  ›'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: viewing.status.isUpcoming ? () {} : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFB54A4A,
                            ).withValues(alpha: 0.16),
                            foregroundColor: const Color(0xFFB54A4A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
                      child: Icon(
                        Icons.apartment_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
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
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.trailing,
  });
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
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E2A3A),
                  ),
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
                child: Icon(
                  Icons.map_rounded,
                  size: 38,
                  color: Color(0xFF6F7785),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onDirections,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E5E9A),
                  side: BorderSide(
                    color: const Color(0xFF2E5E9A).withValues(alpha: 0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF2E5E9A),
              ),
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
  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    final reachedRequested = true;
    final reachedConfirmed =
        status == ViewingStatus.confirmed || status == ViewingStatus.completed;
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
          color: on
              ? onColor.withValues(alpha: 0.6)
              : _muted.withValues(alpha: 0.18),
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
                Text(
                  'Requested',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _muted,
                  ),
                ),
                Text(
                  'Confirmed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _muted,
                  ),
                ),
                Text(
                  'Completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _muted,
                  ),
                ),
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
