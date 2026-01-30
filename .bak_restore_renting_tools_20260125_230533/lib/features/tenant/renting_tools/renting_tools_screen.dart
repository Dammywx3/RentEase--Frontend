import package:flutter/material.dart;

import ../tenancies/tenancies_screen.dart;
import ../viewings/viewings_screen.dart;

class RentingToolsScreen extends StatefulWidget {
  const RentingToolsScreen({super.key});

  @override
  State<RentingToolsScreen> createState() => _RentingToolsScreenState();
}

class _RentingToolsScreenState extends State<RentingToolsScreen> {
  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);
  static const _muted = Color(0xFF6F7785);
  static const _blue = Color(0xFF2E5E9A);
  static const _green = Color(0xFF3C7C5A);

  final PageController _pc = PageController(viewportFraction: 0.92);
  int _idx = 0;

  final _tenancies = const [
    _TenancyCardData(
      title: "Lekki Phase 1 • Unit 3B",
      dueText: "Due May 1",
      amount: 50000,
    ),
    _TenancyCardData(
      title: "Marina Garden • Unit A9",
      dueText: "Due May 3",
      amount: 120000,
    ),
    _TenancyCardData(
      title: "Ikoyi Villa • Room 5C",
      dueText: "Due May 10",
      amount: 220000,
    ),
  ];

  String _fmtNaira(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(",");
    }
    return "₦$buf";
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _tenancies.length;

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
          backgroundColor: Colors.transparent, // keep your gradient visible
          body: ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
            children: [
              _TopBar(
                title: "Renting Tools",
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 10),

              Text(
                "Active Tenancies ($activeCount)",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E2A3A),
                    ),
              ),
              const SizedBox(height: 10),

              // ✅ FIX: give cards enough height and remove Spacer overflow inside card
              SizedBox(
                height: 210,
                child: PageView.builder(
                  controller: _pc,
                  onPageChanged: (i) => setState(() => _idx = i),
                  itemCount: _tenancies.length,
                  itemBuilder: (_, i) {
                    final t = _tenancies[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _FrostCard(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 110,
                                  height: double.infinity,
                                  color: const Color(0xFFCFDBEA)
                                      .withValues(alpha: 0.80),
                                  child: const Icon(
                                    Icons.home_rounded,
                                    size: 34,
                                    color: Color(0xFF2E5E9A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // ✅ FIX: Column must use spaceBetween instead of Spacer()
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: const Color(0xFF1E2A3A),
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.event_rounded,
                                              size: 16,
                                              color: Color(0xFFB24A5A),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                t.dueText,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                      color: const Color(0xFF1E2A3A),
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _PillButton(
                                                text: "View  ›",
                                                color: _blue,
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => TenanciesScreen(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _PillButton(
                                                text: "Pay ${_fmtNaira(t.amount)}",
                                                color: _green,
                                                onTap: () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Pay flow will be wired from Tenancies screen",
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "${_idx + 1}/${_tenancies.length}",
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: _muted.withValues(alpha: 0.80),
                                                ),
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
                  },
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "Quick Actions",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E2A3A),
                    ),
              ),
              const SizedBox(height: 10),

              _FrostCard(
                child: Column(
                  children: [
                    _TileRow(
                      icon: Icons.event_available_rounded,
                      title: "My Viewings",
                      subtitle: "Appointments and visits",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ViewingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _TileRow(
                      icon: Icons.home_work_rounded,
                      title: "My Tenancies",
                      subtitle: "Active & past tenancies",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TenanciesScreen()),
                        );
                      },
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2A3A),
                ),
          ),
        ),
      ],
    );
  }
}

class _TileRow extends StatelessWidget {
  const _TileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF2E5E9A)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E2A3A),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6F7785),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
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
    return Material(
      color: color.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Center(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
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
      color: Colors.white.withValues(alpha: 0.68),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: child,
        ),
      ),
    );
  }
}

class _TenancyCardData {
  const _TenancyCardData({
    required this.title,
    required this.dueText,
    required this.amount,
  });

  final String title;
  final String dueText;
  final int amount;
}
