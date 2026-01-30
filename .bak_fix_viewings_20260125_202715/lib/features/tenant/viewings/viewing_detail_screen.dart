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
    final canCancel =
        viewing.status == _ViewingStatus.confirmed ||
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
                            child: Icon(
                              Icons.apartment_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          bottom: 14,
                          child: Text(
                            viewing.priceText,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
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
                        const Icon(
                          Icons.event_rounded,
                          color: Color(0xFFB24B4B),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            viewing.whenText
                                .replaceAll('Completed • ', '')
                                .replaceAll('Cancelled • ', ''),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: _text,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _snack(context, 'Add to Calendar (wire later)'),
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
                            Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF2E5E9A),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Location',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          viewing.location,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
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
                                  child: Icon(
                                    Icons.location_pin,
                                    size: 42,
                                    color: Color(0xFF2E5E9A),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _snack(
                                      context,
                                      'Get directions (wire to maps)',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
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
                            Icon(
                              Icons.support_agent_rounded,
                              color: Color(0xFF3C7C5A),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Contact',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.05,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF6F7785),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    viewing.agentName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: _text,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Real Estate Agent',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: _muted,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _snack(context, 'Chat agent (wire later)'),
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Color(0xFF2E5E9A),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _snack(context, 'Call agent (wire later)'),
                              icon: const Icon(
                                Icons.call_rounded,
                                color: Color(0xFF3C7C5A),
                              ),
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
                  child: _Card(child: _Timeline(status: viewing.status)),
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
                            onPressed: () =>
                                _snack(context, 'Reschedule (wire later)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue.withValues(alpha: 0.85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Reschedule  ›',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: canCancel
                                ? () => _snack(
                                    context,
                                    'Cancel viewing (wire later)',
                                  )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _danger.withValues(alpha: 0.85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Cancel viewing',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
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
    final requestedOn =
        status == _ViewingStatus.requested ||
        status == _ViewingStatus.confirmed ||
        status == _ViewingStatus.completed;
    final confirmedOn =
        status == _ViewingStatus.confirmed ||
        status == _ViewingStatus.completed;
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
