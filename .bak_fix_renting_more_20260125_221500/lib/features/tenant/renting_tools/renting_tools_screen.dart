import 'package:flutter/material.dart';

import '../tenancies/tenancies_screen.dart';
import '../viewings/viewings_screen.dart';

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
      title: 'Lekki Phase 1 • Unit 3B',
      dueText: 'Due May 1',
      amount: 50000,
    ),
    _TenancyCardData(
      title: 'Marina Garden • Unit A9',
      dueText: 'Due May 3',
      amount: 120000,
    ),
    _TenancyCardData(
      title: 'Ikoyi Villa • Room 5C',
      dueText: 'Due May 10',
      amount: 220000,
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
          children: [
            _TopBar(
              title: 'Renting Tools',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 10),

            Text(
              'Active Tenancies ($activeCount)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E2A3A),
                  ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 190,
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
                                    .withValues(alpha: 0.8),
                                child: const Icon(Icons.home_rounded,
                                    size: 34, color: Color(0xFF2E5E9A)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
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
                                      const Icon(Icons.event_rounded,
                                          size: 16,
                                          color: Color(0xFFB24A5A)),
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
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _PillButton(
                                          text: 'View  ›',
                                          color: _blue,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    TenanciesScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _PillButton(
                                          text: 'Pay ${_fmtNaira(t.amount)}',
                                          color: _green,
                                          onTap: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Pay flow will be wired from Tenancies screen'),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${_idx + 1}/${_tenancies.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: _muted.withValues(alpha: 0.8),
                                          ),
                                    ),
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

            const SizedBox(height: 16),

            _ToolTile(
              icon: Icons.home_work_rounded,
              title: 'My Tenancies',
              subtitle:
                  'Lease status, rent due date, landlord/agent contact',
              badge: '$activeCount Active',
              badgeColor: _green,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TenanciesScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _ToolTile(
              icon: Icons.assignment_rounded,
              title: 'My Applications',
              subtitle: 'Submitted, In Review, Approved, Rejected',
              badge: '2 Pending',
              badgeColor: const Color(0xFFC79A2A),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Applications (wire later)')),
                );
              },
            ),
            const SizedBox(height: 10),
            _ToolTile(
              icon: Icons.remove_red_eye_rounded,
              title: 'My Viewings',
              subtitle: 'Upcoming, Completed',
              badge: '2 Upcoming',
              badgeColor: _blue,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ViewingsScreen()),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Shortcuts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E2A3A),
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SmallTile(
                    icon: Icons.saved_search_rounded,
                    title: 'Saved Searches',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'Proof of Payment',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SmallTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Contact Landlord / Agent',
              onTap: () {},
              fullWidth: true,
            ),

            const SizedBox(height: 18),

            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E2A3A),
                  ),
            ),
            const SizedBox(height: 10),
            _ActivityRow(
              icon: Icons.event_available_rounded,
              title: 'Viewing confirmed for Sat 2pm',
              time: '2 days ago',
              dotColor: _green,
            ),
            _ActivityRow(
              icon: Icons.check_circle_rounded,
              title: 'Application approved',
              time: '3 days ago',
              dotColor: const Color(0xFFC79A2A),
            ),
            _ActivityRow(
              icon: Icons.payments_rounded,
              title: 'Rent reminder: due in 5 days',
              time: '5 days ago',
              dotColor: _blue,
            ),
          ],
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E2A3A),
                    ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;

  static const _muted = Color(0xFF6F7785);

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
              Container(
                height: 40,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Icon(icon, color: badgeColor, size: 22),
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _muted.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2A3A),
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

class _SmallTile extends StatelessWidget {
  const _SmallTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.fullWidth = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = _FrostCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2E5E9A)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E2A3A),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.time,
    required this.dotColor,
  });

  final IconData icon;
  final String title;
  final String time;
  final Color dotColor;

  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Icon(icon, color: dotColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E2A3A),
                  ),
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _muted.withValues(alpha: 0.85),
                ),
          ),
        ],
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
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