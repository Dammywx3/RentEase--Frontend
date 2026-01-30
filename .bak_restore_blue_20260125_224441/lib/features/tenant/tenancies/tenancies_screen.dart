import 'package:flutter/material.dart';

class TenanciesScreen extends StatefulWidget {
  const TenanciesScreen({super.key});

  @override
  State<TenanciesScreen> createState() => TenanciesScreenState();
}

class TenanciesScreenState extends State<TenanciesScreen> {
  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _green = Color(0xFF3C7C5A);
  static const _muted = Color(0xFF6F7785);

  int _tab = 0; // 0=Active, 1=Past

  // Demo data (wire later)
  final List<_Tenancy> _active = const [
    _Tenancy(
      id: 't1',
      title: 'Lekki Phase 1 • Unit 3B',
      location: 'Lekki, Lagos',
      rent: 50000,
      dueLabel: 'May 1',
      startLabel: 'Jan 2026',
      endLabel: 'Jan 2027',
      statusLabel: 'Active',
    ),
    _Tenancy(
      id: 't2',
      title: 'Marina Garden • Unit A9',
      location: 'Victoria Island, Lagos',
      rent: 75000,
      dueLabel: 'May 6',
      startLabel: 'Feb 2026',
      endLabel: 'Feb 2027',
      statusLabel: 'Active',
    ),
    _Tenancy(
      id: 't3',
      title: 'Ikoyi Villa • Room 5C',
      location: 'Ikoyi, Lagos',
      rent: 120000,
      dueLabel: 'May 12',
      startLabel: 'Mar 2026',
      endLabel: 'Mar 2027',
      statusLabel: 'Active',
    ),
  ];

  final List<_Tenancy> _past = const [
    _Tenancy(
      id: 'p1',
      title: 'Yaba Heights • Flat 2A',
      location: 'Yaba, Lagos',
      rent: 35000,
      dueLabel: '-',
      startLabel: 'Jan 2024',
      endLabel: 'Jan 2025',
      statusLabel: 'Completed',
    ),
    _Tenancy(
      id: 'p2',
      title: 'Ajah Prime • Unit 1C',
      location: 'Ajah, Lagos',
      rent: 42000,
      dueLabel: '-',
      startLabel: 'Feb 2023',
      endLabel: 'Dec 2023',
      statusLabel: 'Terminated',
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

  void _openDetails(_Tenancy t) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TenancyDetailsScreen(tenancy: t)));
  }

  void _openPaySheet(_Tenancy t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PayRentSheet(
        title: t.title,
        amount: t.rent,
        dueLabel: t.dueLabel,
        onContinue: () {
          Navigator.of(context).pop();
          // Wire later: go to payment method screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Continue to payment (wire later)')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _active : _past;
    final activeCount = _active.length;

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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('My Tenancies'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Documents (wire later)')),
                  );
                },
                icon: const Icon(Icons.description_rounded),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
            children: [
              _SegmentTabs(
                left: _tab == 0 ? 'Active ($activeCount)' : 'Active',
                right: 'Past',
                value: _tab,
                onChanged: (v) => setState(() => _tab = v),
              ),
              const SizedBox(height: 12),
              ...list.map((t) {
                final isActive = _tab == 0;
                final pillColor = isActive ? _green : const Color(0xFF6B6B6B);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FrostCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 62,
                                  width: 72,
                                  color: const Color(
                                    0xFFCFDBEA,
                                  ).withValues(alpha: 0.85),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.home_rounded,
                                    color: _blue,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF1E2A3A),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${t.location} • ${t.startLabel} – ${t.endLabel}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: _muted.withValues(
                                              alpha: 0.85,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: pillColor.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: pillColor.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  t.statusLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E2A3A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Key info row
                          Row(
                            children: [
                              _MiniInfo(
                                icon: Icons.payments_rounded,
                                text: '${_fmtNaira(t.rent)} / month',
                              ),
                              const SizedBox(width: 10),
                              _MiniInfo(
                                icon: Icons.event_rounded,
                                text: isActive
                                    ? 'Next due: ${t.dueLabel}'
                                    : '${t.startLabel} – ${t.endLabel}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child: _PillButton(
                                  text: isActive ? 'Pay rent' : 'View details',
                                  filled: true,
                                  color: isActive ? _blue : _green,
                                  onTap: () => isActive
                                      ? _openPaySheet(t)
                                      : _openDetails(t),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _PillButton(
                                  text: 'View details',
                                  filled: false,
                                  color: _blue,
                                  onTap: () => _openDetails(t),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Links row
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _LinkChip(
                                icon: Icons.description_rounded,
                                text: 'Lease documents',
                                onTap: () {},
                              ),
                              _LinkChip(
                                icon: Icons.build_rounded,
                                text: 'Request maintenance',
                                onTap: () {},
                              ),
                              _LinkChip(
                                icon: Icons.chat_rounded,
                                text: 'Contact landlord/agent',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class TenancyDetailsScreen extends StatelessWidget {
  const TenancyDetailsScreen({super.key, required this.tenancy});
  final _Tenancy tenancy;

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _green = Color(0xFF3C7C5A);
  static const _muted = Color(0xFF6F7785);

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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(tenancy.title),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 190,
                  color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
                  alignment: Alignment.center,
                  child: const Icon(Icons.home_rounded, size: 56, color: _blue),
                ),
              ),
              const SizedBox(height: 12),

              _Section(
                title: 'Overview',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenancy.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFCFDBEA),
                          child: Icon(Icons.person_rounded, color: _blue),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Landlord / Agent\nDaniel (wire later)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E2A3A),
                                ),
                          ),
                        ),
                        _IconBubble(icon: Icons.call_rounded, onTap: () {}),
                        const SizedBox(width: 10),
                        _IconBubble(icon: Icons.chat_rounded, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _Section(
                title: 'Rent & Payments',
                child: Column(
                  children: [
                    _KVRow(
                      label: 'Monthly rent',
                      value: '${_fmtNaira(tenancy.rent)} / month',
                    ),
                    _KVRow(
                      label: 'Next due date',
                      value: tenancy.dueLabel == '-' ? '—' : tenancy.dueLabel,
                    ),
                    _KVRow(label: 'Status', value: tenancy.statusLabel),
                    const SizedBox(height: 10),
                    _PillButton(
                      text: 'Pay now',
                      filled: true,
                      color: _green,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => _PayRentSheet(
                            title: tenancy.title,
                            amount: tenancy.rent,
                            dueLabel: tenancy.dueLabel,
                            onContinue: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Continue to payment (wire later)',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Recent transactions (wire later)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _muted.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _Section(
                title: 'Lease',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tenancy.startLabel} – ${tenancy.endLabel}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PillButton(
                      text: 'View lease document',
                      filled: false,
                      color: _blue,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _Section(
                title: 'Maintenance',
                child: Column(
                  children: [
                    const _KVRow(label: 'Open requests', value: '0'),
                    const SizedBox(height: 10),
                    _PillButton(
                      text: 'Request maintenance',
                      filled: true,
                      color: _blue,
                      onTap: () {},
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

/* ---------------------- UI bits ---------------------- */

class _Tenancy {
  const _Tenancy({
    required this.id,
    required this.title,
    required this.location,
    required this.rent,
    required this.dueLabel,
    required this.startLabel,
    required this.endLabel,
    required this.statusLabel,
  });

  final String id;
  final String title;
  final String location;
  final int rent;
  final String dueLabel;
  final String startLabel;
  final String endLabel;
  final String statusLabel;
}

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({
    required this.left,
    required this.right,
    required this.value,
    required this.onChanged,
  });

  final String left;
  final String right;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegBtn(
              text: left,
              active: value == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SegBtn(
              text: right,
              active: value == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  const _SegBtn({
    required this.text,
    required this.active,
    required this.onTap,
  });
  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _blue.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? _blue.withValues(alpha: 0.25) : Colors.transparent,
          ),
        ),
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
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.icon, required this.text});
  final IconData icon;
  final String text;

  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: _muted.withValues(alpha: 0.85)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E2A3A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.icon,
    required this.text,
    required this.onTap,
  });
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _muted.withValues(alpha: 0.85)),
            const SizedBox(width: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E2A3A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
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
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.label, required this.value});
  final String label;
  final String value;

  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: _muted.withValues(alpha: 0.85),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E2A3A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayRentSheet extends StatefulWidget {
  const _PayRentSheet({
    required this.title,
    required this.amount,
    required this.dueLabel,
    required this.onContinue,
  });

  final String title;
  final int amount;
  final String dueLabel;
  final VoidCallback onContinue;

  @override
  State<_PayRentSheet> createState() => _PayRentSheetState();
}

class _PayRentSheetState extends State<_PayRentSheet> {
  static const _muted = Color(0xFF6F7785);

  bool _full = true;
  bool _includeService = false;
  final TextEditingController _partCtrl = TextEditingController();

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
  void dispose() {
    _partCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              blurRadius: 28,
              offset: const Offset(0, -12),
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFDBEA).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pay Rent',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E2A3A),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 58,
                        width: 70,
                        color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
                        alignment: Alignment.center,
                        child: const Icon(Icons.home_rounded, color: _blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1E2A3A),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due ${widget.dueLabel}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _muted.withValues(alpha: 0.85),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _ChoiceTile(
                  active: _full,
                  title: 'Full rent (${_fmtNaira(widget.amount)})',
                  onTap: () => setState(() => _full = true),
                ),
                const SizedBox(height: 10),
                _ChoiceTile(
                  active: !_full,
                  title: 'Part payment',
                  onTap: () => setState(() => _full = false),
                  trailing: !_full
                      ? SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _partCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        )
                      : null,
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Include service charge?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E2A3A),
                        ),
                      ),
                    ),
                    Switch(
                      value: _includeService,
                      onChanged: (v) => setState(() => _includeService = v),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                _PillButton(
                  text: 'Continue',
                  filled: true,
                  color: _blue,
                  onTap: widget.onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.active,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final bool active;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? _blue.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? _blue.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2A3A),
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            const SizedBox(width: 10),
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: active ? _blue : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: active ? _blue : Colors.black.withValues(alpha: 0.2),
                ),
              ),
              child: active
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
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
    return InkWell(
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
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.text,
    required this.onTap,
    required this.filled,
    required this.color,
  });

  final String text;
  final VoidCallback? onTap;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFFB9C1CF).withValues(alpha: 0.35)
              : (filled ? color.withValues(alpha: 0.80) : Colors.transparent),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: disabled
                ? Colors.black.withValues(alpha: 0.06)
                : color.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: disabled
                ? const Color(0xFF9AA2AF)
                : (filled ? Colors.white : const Color(0xFF1E2A3A)),
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
