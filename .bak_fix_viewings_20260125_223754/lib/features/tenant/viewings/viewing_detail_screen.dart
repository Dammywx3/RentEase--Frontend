import 'package:flutter/material.dart';

import '../../../core/constants/status_badge_map.dart';
import '../../../shared/widgets/status_badge.dart';
import 'viewings_screen.dart';

class ViewingDetailScreen extends StatelessWidget {
  const ViewingDetailScreen({super.key, required this.viewing});
  final _Viewing viewing;

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _blue = Color(0xFF2E5E9A);
  static const _muted = Color(0xFF6F7785);

  String get _statusRaw {
    switch (viewing.status) {
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

  @override
  Widget build(BuildContext context) {
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
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 120),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Viewing Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2A3A),
                      ),
                    ),
                  ),
                ],
              ),

              // 1) Hero image + price (placeholder)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Container(
                      height: 210,
                      width: double.infinity,
                      color: const Color(0xFFCFDBEA).withValues(alpha: 0.8),
                      child: const Icon(
                        Icons.home_rounded,
                        size: 56,
                        color: Color(0xFF2E5E9A),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '₦50,000 / month',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                viewing.listingTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2A3A),
                ),
              ),
              const SizedBox(height: 10),

              // 2) Date/Time card + add to calendar
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        size: 20,
                        color: Color(0xFFB24A5A),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _fmtDate(viewing.dateTime),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E2A3A),
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('+ Add to Calendar'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3) Location card with mini map
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.place_rounded,
                            color: Color(0xFF2E5E9A),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Location',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1E2A3A),
                                ),
                          ),
                          const Spacer(),
                          StatusBadge(
                            domain: StatusDomain.viewing,
                            status: _statusRaw,
                            compact: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        viewing.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E2A3A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 150,
                          color: const Color(0xFFE1E6F0),
                          alignment: Alignment.center,
                          child: Text(
                            'Mini map (wire later)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _PillButton(
                          text: 'Get directions',
                          onTap: () {},
                          color: _blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 4) Contact
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(
                          0xFFCFDBEA,
                        ).withValues(alpha: 0.8),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF2E5E9A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewing.agentName,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1E2A3A),
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Real Estate Agent',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _muted.withValues(alpha: 0.85),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _IconBubble(icon: Icons.call_rounded, onTap: () {}),
                      const SizedBox(width: 10),
                      _IconBubble(icon: Icons.chat_rounded, onTap: () {}),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      text: 'Reschedule  ›',
                      onTap: () {},
                      color: _blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillButton(
                      text: 'Cancel viewing',
                      onTap: () {},
                      color: const Color(0xFFB54A4A),
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

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.text,
    required this.onTap,
    required this.color,
  });

  final String text;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Icon(icon, color: const Color(0xFF2E5E9A), size: 18),
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
