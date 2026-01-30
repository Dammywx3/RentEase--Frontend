import "package:flutter/material.dart";

import "../../../shared/models/viewing_model.dart";

class ViewingDetailScreen extends StatelessWidget {
  const ViewingDetailScreen({super.key, required this.viewing});

  final ViewingModel viewing;

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _text = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);
  static const _blue = Color(0xFF2E5E9A);
  static const _red = Color(0xFFB54A4A);

  String _fmtDateOnly(DateTime dt) {
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
    final price = viewing.priceText ?? "₦—";
    final dateText = _fmtDateOnly(viewing.dateTime);
    final fullDateTime = _fmtDateTime(viewing.dateTime);

    final canCancel =
        viewing.status == ViewingStatus.requested ||
        viewing.status == ViewingStatus.confirmed;

    // status stage for the timeline
    final int stage = viewing.status == ViewingStatus.requested
        ? 0
        : (viewing.status == ViewingStatus.confirmed ? 1 : 2);

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
              // top bar like screenshot (back + arrows)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
                  children: [
                    // hero image with price overlay
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Container(
                            height: 220,
                            width: double.infinity,
                            color: const Color(
                              0xFFCFDBEA,
                            ).withValues(alpha: 0.85),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.home_rounded,
                              size: 64,
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
                              child: Text(
                                price,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // title
                    Text(
                      viewing.listingTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // date row + add to calendar
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
                                dateText,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: _text,
                                    ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text("+ Add to Calendar"),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // location section (map card + get directions)
                    Text(
                      "Location",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _text.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                                  color: _blue,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${viewing.listingTitle}\n${viewing.location}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: _text,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                height: 130,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.05),
                                ),
                                child: Stack(
                                  children: [
                                    // light "map" grid placeholder
                                    Positioned.fill(
                                      child: Opacity(
                                        opacity: 0.20,
                                        child: CustomPaint(
                                          painter: _GridPainter(),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.75,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.location_on_rounded,
                                          color: _blue,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 12,
                                      bottom: 10,
                                      child: _PillOutlineButton(
                                        text: "Get directions",
                                        onTap: () {},
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

                    const SizedBox(height: 14),

                    // contact section
                    Text(
                      "Contact",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _text.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FrostCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(
                                0xFFCFDBEA,
                              ).withValues(alpha: 0.85),
                              child: const Icon(
                                Icons.person_rounded,
                                color: _blue,
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
                                    "Real Estate Agent",
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: _muted.withValues(alpha: 0.9),
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

                    // status timeline like screenshot
                    _FrostCard(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Timeline(stage: stage),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _TimelineLabel(
                                  text: "Requested",
                                  active: stage >= 0,
                                ),
                                _TimelineLabel(
                                  text: "Confirmed",
                                  active: stage >= 1,
                                ),
                                _TimelineLabel(
                                  text: "Completed",
                                  active: stage >= 2,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              fullDateTime,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: _muted.withValues(alpha: 0.9),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // bottom buttons
                    Row(
                      children: [
                        Expanded(
                          child: _PillButton(
                            text: "Reschedule  ›",
                            color: _blue,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PillButton(
                            text: "Cancel viewing",
                            color: _red,
                            onTap: canCancel ? () {} : null,
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
      color: Colors.white.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 38,
          width: 38,
          child: Icon(icon, color: const Color(0xFF2E5E9A), size: 18),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  final String text;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: disabled
          ? const Color(0xFFB9C1CF).withValues(alpha: 0.28)
          : color.withValues(alpha: 0.80),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: disabled ? const Color(0xFF9AA2AF) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _PillOutlineButton extends StatelessWidget {
  const _PillOutlineButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E2A3A),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineLabel extends StatelessWidget {
  const _TimelineLabel({required this.text, required this.active});
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: active
            ? const Color(0xFF1E2A3A)
            : const Color(0xFF6F7785).withValues(alpha: 0.75),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.stage});
  final int stage;

  static const _blue = Color(0xFF2E5E9A);
  static const _muted = Color(0xFF6F7785);

  Color _dotColor(int idx) {
    if (idx < stage) return _blue;
    if (idx == stage && stage == 2) return const Color(0xFF3C7C5A);
    if (idx == stage) return _blue;
    return _muted.withValues(alpha: 0.35);
  }

  @override
  Widget build(BuildContext context) {
    Widget dot(int i) {
      final c = _dotColor(i);
      return Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.withValues(alpha: 0.75), width: 2),
        ),
        child: Center(
          child: Container(
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      );
    }

    Widget line(bool active) {
      return Expanded(
        child: Container(
          height: 2,
          color: (active ? _blue : _muted.withValues(alpha: 0.25)),
        ),
      );
    }

    return Row(
      children: [
        dot(0),
        const SizedBox(width: 8),
        line(stage >= 1),
        const SizedBox(width: 8),
        dot(1),
        const SizedBox(width: 8),
        line(stage >= 2),
        const SizedBox(width: 8),
        dot(2),
      ],
    );
  }
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
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
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1E2A3A).withValues(alpha: 0.20)
      ..strokeWidth = 1;

    const step = 18.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
