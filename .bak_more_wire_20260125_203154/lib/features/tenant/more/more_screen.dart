import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _green = Color(0xFF3C7C5A);
  static const _inactive = Color(0xFF6F7785);

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
        bottom: false, // bottom nav overlays
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopBrandHeader(),
              const SizedBox(height: 14),
              const _ProfileCard(),
              const SizedBox(height: 16),

              // ✅ List like your screenshot
              _MenuTile(
                icon: Icons.account_balance_wallet_rounded,
                iconBg: const Color(0xFFCFDBEA),
                iconFg: const Color(0xFF2E5E9A),
                title: 'Payments',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.construction_rounded,
                iconBg: const Color(0xFFD7E6DD),
                iconFg: _green,
                title: 'Renting Tools',
                subtitle: 'Tenancies • Applications • Viewings',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.description_rounded,
                iconBg: const Color(0xFFCFDBEA),
                iconFg: const Color(0xFF2E5E9A),
                title: 'Documents',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.build_rounded,
                iconBg: const Color(0xFFD7E6DD),
                iconFg: _green,
                title: 'Maintenance',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.help_outline_rounded,
                iconBg: const Color(0xFFE7E3D1),
                iconFg: const Color(0xFF6B6B6B),
                title: 'Support',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.settings_rounded,
                iconBg: const Color(0xFFD9D9D9),
                iconFg: const Color(0xFF6B6B6B),
                title: 'Settings',
                onTap: () {},
              ),
              const SizedBox(height: 14),

              // ✅ two-item group like mock (Invite Friends + Subscription)
              _GroupCard(
                children: [
                  _MenuRow(
                    icon: Icons.card_giftcard_rounded,
                    iconBg: const Color(0xFFD7E6DD),
                    iconFg: _green,
                    title: 'Invite Friends',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _MenuRow(
                    icon: Icons.star_rounded,
                    iconBg: const Color(0xFFE7E3D1),
                    iconFg: const Color(0xFFC79A2A),
                    title: 'Subscription',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ✅ Legal single card
              _MenuTile(
                icon: Icons.article_rounded,
                iconBg: const Color(0xFFCFDBEA),
                iconFg: const Color(0xFF2E5E9A),
                title: 'Legal',
                onTap: () {},
              ),

              const SizedBox(height: 14),

              // ✅ Another Invite Friends + Account group like mock
              _GroupCard(
                children: [
                  _MenuRow(
                    icon: Icons.card_giftcard_rounded,
                    iconBg: const Color(0xFFD7E6DD),
                    iconFg: _green,
                    title: 'Invite Friends',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _MenuRow(
                    icon: Icons.power_settings_new_rounded,
                    iconBg: const Color(0xFFE9D2D2),
                    iconFg: const Color(0xFFB54A4A),
                    title: 'Account',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 26),
              Center(
                child: Text(
                  'HomeStead v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _inactive.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
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

class _TopBrandHeader extends StatelessWidget {
  const _TopBrandHeader();

  static const _green = Color(0xFF3C7C5A);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 8),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: const Icon(Icons.location_on_rounded, color: _green, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'HomeStead',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  static const _inactive = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Michael Johnson',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'michael.j@email.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _inactive.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: _OutlinePillButton(text: 'View Profile  ›', onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String? subtitle;
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
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(
                            0xFF6F7785,
                          ).withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF6F7785).withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            _IconChip(icon: icon, bg: iconBg, fg: iconFg),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2A3A),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF6F7785).withValues(alpha: 0.75),
            ),
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

class _OutlinePillButton extends StatelessWidget {
  const _OutlinePillButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E2A3A),
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
