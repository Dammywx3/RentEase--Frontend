import "package:flutter/material.dart";

import "viewing_models.dart";

class ViewingDetailScreen extends StatelessWidget {
  const ViewingDetailScreen({super.key, required this.viewing});

  final ViewingModel viewing;

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _text = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);
  static const _blue = Color(0xFF2E5E9A);
  static const _red = Color(0xFFB54A4A);

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
    final dateText = _fmtDateTime(viewing.dateTime);

    final canCancel =
        viewing.status == ViewingStatus.requested ||
        viewing.status == ViewingStatus.confirmed;

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
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    Expanded(
                      child: Text(
                        "Viewing Details",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: _text,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Container(
                            height: 210,
                            width: double.infinity,
                            color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
                            alignment: Alignment.center,
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
                    const SizedBox(height: 12),
                    Text(
                      viewing.listingTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: _text,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      viewing.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _muted.withValues(alpha: 0.9),
                          ),
                    ),
                    const SizedBox(height: 12),

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
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
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

                    _FrostCard(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
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
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: _text,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Agent",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
