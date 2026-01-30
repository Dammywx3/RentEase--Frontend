#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_home_mock_v2_$TS"
mkdir -p "$BACKUP_DIR"

backup_file () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "📍 Repo: $ROOT_DIR"
echo "🗂️ Backup: $BACKUP_DIR"

NAV_FILE="lib/core/ui/nav/tenant_bottom_nav.dart"
EXPLORE_FILE="lib/features/tenant/explore/explore_screen.dart"
SEARCH_FILE="lib/features/tenant/search/search_screen.dart"
ALERTS_FILE="lib/features/tenant/alerts/alerts_screen.dart"

mkdir -p "$(dirname "$NAV_FILE")"
mkdir -p "$(dirname "$EXPLORE_FILE")"
mkdir -p "$(dirname "$SEARCH_FILE")"
mkdir -p "$(dirname "$ALERTS_FILE")"

backup_file "$NAV_FILE"
backup_file "$EXPLORE_FILE"
backup_file "$SEARCH_FILE"
backup_file "$ALERTS_FILE"

echo "🛠️ Writing: $NAV_FILE"
cat > "$NAV_FILE" <<'DART'
import 'dart:ui';
import 'package:flutter/material.dart';

class TenantBottomNav extends StatelessWidget {
  const TenantBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    this.savedBadgeCount = 3,
  });

  final int index;
  final ValueChanged<int> onChanged;

  /// Set to 0 if you want no badge on Saved.
  final int savedBadgeCount;

  static const _active = Color(0xFF3C7C5A); // green like mock
  static const _inactive = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 6),
      child: Padding(
        // ✅ IMPORTANT: small bottom padding only (no extra “floating” gap)
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withValues(alpha: 0.10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _Item(
                        label: 'Explore',
                        active: index == 0,
                        activeColor: _active,
                        inactiveColor: _inactive,
                        icon: Icons.eco_outlined,
                        iconActive: Icons.eco_rounded,
                        onTap: () => onChanged(0),
                      ),
                    ),
                    Expanded(
                      child: _Item(
                        label: 'Search',
                        active: index == 1,
                        activeColor: _active,
                        inactiveColor: _inactive,
                        icon: Icons.search_rounded,
                        iconActive: Icons.search_rounded,
                        onTap: () => onChanged(1),
                      ),
                    ),
                    Expanded(
                      child: _Item(
                        label: 'Saved',
                        active: index == 2,
                        activeColor: _active,
                        inactiveColor: _inactive,
                        icon: Icons.favorite_border_rounded,
                        iconActive: Icons.favorite_rounded,
                        badgeCount: savedBadgeCount,
                        onTap: () => onChanged(2),
                      ),
                    ),
                    Expanded(
                      child: _Item(
                        label: 'Messages',
                        active: index == 3,
                        activeColor: _active,
                        inactiveColor: _inactive,
                        icon: Icons.chat_bubble_outline_rounded,
                        iconActive: Icons.chat_bubble_rounded,
                        onTap: () => onChanged(3),
                      ),
                    ),
                    Expanded(
                      child: _Item(
                        label: 'More',
                        active: index == 4,
                        activeColor: _active,
                        inactiveColor: _inactive,
                        icon: Icons.more_horiz_rounded,
                        iconActive: Icons.more_horiz_rounded,
                        onTap: () => onChanged(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.icon,
    required this.iconActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final IconData icon;
  final IconData iconActive;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final c = active ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 28,
              width: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (active)
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activeColor.withValues(alpha: 0.55),
                          width: 1.6,
                        ),
                      ),
                    ),
                  Icon(active ? iconActive : icon, color: c, size: 22),
                  if (badgeCount > 0)
                    Positioned(
                      top: 0,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD07A53), // orange badge like mock
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c,
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
DART

echo "🛠️ Writing: $ALERTS_FILE"
cat > "$ALERTS_FILE" <<'DART'
import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Alerts'),
        foregroundColor: cs.onSurface,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        itemBuilder: (context, i) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_rounded, color: Color(0xFF3C7C5A)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  i == 0
                      ? 'New listing alert: 3-bedroom in Lekki'
                      : 'Price drop alert: ₦95,000,000 in Ikeja',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: 6,
      ),
    );
  }
}
DART

echo "🛠️ Writing: $SEARCH_FILE (filter screen like your mock)"
cat > "$SEARCH_FILE" <<'DART'
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  RangeValues _price = const RangeValues(20_000_000, 500_000_000);
  int _propertyTab = 0; // 0 residential, 1 commercial, 2 land
  bool _buy = true;

  String _fmtNaira(num v) {
    final s = v.toInt().toString();
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
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF1F3F8), Color(0xFFE9ECF4)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopHeader(
                onProfile: () {},
              ),
              const SizedBox(height: 12),
              _SearchBar(
                onTap: () {},
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      icon: Icons.filter_alt_rounded,
                      text: 'Advanced Filters',
                      onTap: () {},
                      filled: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _price = const RangeValues(20_000_000, 500_000_000);
                        _propertyTab = 0;
                        _buy = true;
                      });
                    },
                    child: const Text('Reset All  ›'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                '${_fmtNaira(_price.start)}                                ${_fmtNaira(_price.end)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E2A3A),
                    ),
              ),
              const SizedBox(height: 6),
              RangeSlider(
                values: _price,
                min: 20_000_000,
                max: 1_000_000_000,
                divisions: 40,
                onChanged: (v) => setState(() => _price = v),
              ),
              Text(
                '${_fmtNaira(20_000_000)}  -  ${_fmtNaira(1_000_000_000)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w700,
                    ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _Segment(
                      label: 'Residential',
                      active: _propertyTab == 0,
                      onTap: () => setState(() => _propertyTab = 0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Segment(
                      label: 'Commercial',
                      active: _propertyTab == 1,
                      onTap: () => setState(() => _propertyTab = 1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Segment(
                      label: 'Land',
                      active: _propertyTab == 2,
                      onTap: () => setState(() => _propertyTab = 2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    'Buy',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF3C7C5A),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Rent',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF3C7C5A),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _BuyRentToggle(
                buy: _buy,
                onChanged: (v) => setState(() => _buy = v),
              ),

              const SizedBox(height: 12),

              Row(
                children: const [
                  Expanded(child: _MiniDrop(text: 'Min Beds  ›')),
                  SizedBox(width: 10),
                  Expanded(child: _MiniDrop(text: 'Min Baths')),
                ],
              ),
              const SizedBox(height: 10),
              const _MiniDrop(text: 'Min Plot Size (sqft)'),

              const SizedBox(height: 16),

              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFD0DA).withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Center(
                      child: Text(
                        'Map Preview (demo)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface.withValues(alpha: 0.60),
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _PillButton(
                      icon: Icons.map_rounded,
                      text: 'Map',
                      onTap: () {},
                      filled: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Center(
                child: SizedBox(
                  width: 280,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C7C5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black.withValues(alpha: 0.20),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
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

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.onProfile});
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // logo circle
        Container(
          height: 42,
          width: 42,
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
          child: const Icon(Icons.eco_rounded, color: Color(0xFF3C7C5A)),
        ),
        const SizedBox(width: 10),
        Text(
          'HomeStead',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
        ),
        const Spacer(),
        InkWell(
          onTap: onProfile,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: const Icon(Icons.person_rounded, color: Color(0xFF5C6677)),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF4E5A6D)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search location, price, or city...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4E5A6D),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF3C7C5A)),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: filled
              ? const Color(0xFF3C7C5A).withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: filled ? Colors.white : const Color(0xFF3C7C5A)),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: filled ? Colors.white : const Color(0xFF1E2A3A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
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
          color: active
              ? const Color(0xFF2D5E9C).withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF1E2A3A),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _BuyRentToggle extends StatelessWidget {
  const _BuyRentToggle({required this.buy, required this.onChanged});

  final bool buy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onChanged(true),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: buy ? const Color(0xFF3C7C5A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Buy',
                  style: TextStyle(
                    color: buy ? Colors.white : const Color(0xFF6F7785),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(false),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !buy ? const Color(0xFF3C7C5A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Rent',
                  style: TextStyle(
                    color: !buy ? Colors.white : const Color(0xFF6F7785),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniDrop extends StatelessWidget {
  const _MiniDrop({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4E5A6D),
                  ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF4E5A6D)),
        ],
      ),
    );
  }
}
DART

echo "🛠️ Writing: $EXPLORE_FILE (naira + nigeria + quick nav buttons)"
cat > "$EXPLORE_FILE" <<'DART'
import 'package:flutter/material.dart';

import '../search/search_screen.dart';
import '../saved/saved_screen.dart';
import '../viewings/viewings_screen.dart';
import '../alerts/alerts_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  String _fmtNaira(num v) {
    final s = v.toInt().toString();
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _TopHeader()),
            SliverToBoxAdapter(
              child: _SearchBar(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            const SliverToBoxAdapter(
              child: _SectionTitle(title: 'Featured Listings'),
            ),
            SliverToBoxAdapter(child: _FeaturedCard(price: _fmtNaira(1150000000))),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _QuickButtons(
                onSaved: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SavedScreen()),
                ),
                onViewings: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ViewingsScreen()),
                ),
                onAlerts: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            const SliverToBoxAdapter(child: _SectionTitle(title: 'Latest Listings')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 140),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final demo = _latest[i % _latest.length];
                    return _ListingGridCard(
                      price: _fmtNaira(demo.price),
                      meta: demo.meta,
                      location: demo.location,
                    );
                  },
                  childCount: 6,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.86,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      // ✅ better spacing so it aligns like mock
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
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
            child: const Icon(Icons.eco_rounded, color: Color(0xFF3C7C5A)),
          ),
          const SizedBox(width: 10),
          Text(
            'HomeStead',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
          ),
          const Spacer(),
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: const Icon(Icons.person_rounded, color: Color(0xFF5C6677)),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFF4E5A6D)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search location, price, or city...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4E5A6D),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF3C7C5A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E2A3A),
            ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.price});
  final String price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 12),
              color: Colors.black.withValues(alpha: 0.10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
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
                        child: Icon(Icons.villa_rounded, size: 54, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white.withValues(alpha: 0.95),
                        size: 26,
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 42,
                      child: Text(
                        'Premium Villa',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  blurRadius: 18,
                                  color: Colors.black.withValues(alpha: 0.35),
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3C7C5A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Verified Deal',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lekki, Lagos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4E5A6D),
                            fontWeight: FontWeight.w700,
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
  }
}

class _QuickButtons extends StatelessWidget {
  const _QuickButtons({
    required this.onSaved,
    required this.onViewings,
    required this.onAlerts,
  });

  final VoidCallback onSaved;
  final VoidCallback onViewings;
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Row(
        children: [
          Expanded(
            child: _QuickPill(
              icon: Icons.favorite_rounded,
              label: 'Saved',
              onTap: onSaved,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickPill(
              icon: Icons.calendar_month_rounded,
              label: 'Viewings',
              onTap: onViewings,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickPill(
              icon: Icons.notifications_rounded,
              label: 'Alerts',
              onTap: onAlerts,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPill extends StatelessWidget {
  const _QuickPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 8),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF3C7C5A)),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _ListingGridCard extends StatelessWidget {
  const _ListingGridCard({
    required this.price,
    required this.meta,
    required this.location,
  });

  final String price;
  final String meta;
  final String location;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFD4DDEB), Color(0xFFB2C0D6)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.home_work_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.favorite_border_rounded, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w700,
                        ),
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

class _LatestDemo {
  const _LatestDemo(this.price, this.meta, this.location);
  final int price;
  final String meta;
  final String location;
}

const _latest = <_LatestDemo>[
  _LatestDemo(95000000, '4 beds | 3 bath | 2,676 sqft', 'Ikoyi, Lagos'),
  _LatestDemo(129000000, '3 beds | 2 bath | 1,900 sqft', 'Ikeja, Lagos'),
  _LatestDemo(65000000, '2 beds | 2 bath | 1,200 sqft', 'Ajah, Lagos'),
  _LatestDemo(185000000, '5 beds | 4 bath | 3,100 sqft', 'Maitama, Abuja'),
];
DART

echo "🎨 dart format..."
dart format lib >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze

echo
echo "✅ Done."
echo "🗂️ Backup saved in: $BACKUP_DIR"
echo
echo "▶️ Run:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run"
