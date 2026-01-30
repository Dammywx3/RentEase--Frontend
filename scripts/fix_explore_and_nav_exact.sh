#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_explore_nav_exact_fix_$TS"
mkdir -p "$BACKUP_DIR"

backup () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "�� Repo: $ROOT_DIR"
echo "🗂️ Backup..."
backup "lib/core/ui/nav/tenant_bottom_nav.dart"
backup "lib/core/ui/nav/tenant_nav_scope.dart"
backup "lib/features/tenant/shell/tenant_shell.dart"
backup "lib/features/tenant/explore/explore_screen.dart"

mkdir -p lib/core/ui/nav
mkdir -p lib/features/tenant/explore
mkdir -p lib/features/tenant/shell

echo "🛠️ Writing: lib/core/ui/nav/tenant_nav_scope.dart"
cat > lib/core/ui/nav/tenant_nav_scope.dart <<'DART'
import 'package:flutter/widgets.dart';

/// Allows inner screens (Explore etc.) to switch the Tenant bottom-nav tab.
class TenantNavScope extends InheritedWidget {
  const TenantNavScope({
    super.key,
    required this.index,
    required this.setIndex,
    required super.child,
  });

  final int index;
  final ValueChanged<int> setIndex;

  static TenantNavScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TenantNavScope>();
    assert(scope != null, 'TenantNavScope not found above this context.');
    return scope!;
  }

  static TenantNavScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TenantNavScope>();
  }

  @override
  bool updateShouldNotify(TenantNavScope oldWidget) => index != oldWidget.index;
}
DART

echo "🛠️ Writing: lib/core/ui/nav/tenant_bottom_nav.dart (fix bottom spacing + mock-ish style)"
cat > lib/core/ui/nav/tenant_bottom_nav.dart <<'DART'
import 'dart:ui';
import 'package:flutter/material.dart';

class TenantBottomNav extends StatelessWidget {
  const TenantBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    this.messagesBadgeCount = 0,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final int messagesBadgeCount;

  static const _active = Color(0xFF3C7C5A); // green like mock
  static const _inactive = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // ✅ IMPORTANT: keep it sitting at the bottom properly.
    // We use the device safe-area inset + a small visual margin (6).
    final padBottom = bottomInset + 6;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, padBottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.80),
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
                      icon: Icons.explore_outlined,
                      iconActive: Icons.explore_rounded,
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
                      badgeCount: messagesBadgeCount,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD07A53), // orange badge
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

echo "🛠️ Writing: lib/features/tenant/shell/tenant_shell.dart (nav scope + correct overlay)"
cat > lib/features/tenant/shell/tenant_shell.dart <<'DART'
import 'package:flutter/material.dart';

import '../../../core/ui/nav/tenant_bottom_nav.dart';
import '../../../core/ui/nav/tenant_nav_scope.dart';

import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../saved/saved_screen.dart';
import '../messages/messages_screen.dart';
import '../more/more_screen.dart';

class TenantShell extends StatefulWidget {
  const TenantShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<TenantShell> createState() => _TenantShellState();
}

class _TenantShellState extends State<TenantShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _setIndex(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ExploreScreen(),
      const SearchScreen(),
      const SavedScreen(),
      const MessagesScreen(),
      const MoreScreen(),
    ];

    return TenantNavScope(
      index: _index,
      setIndex: _setIndex,
      child: Scaffold(
        extendBody: true, // nav floats over background like mock
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: TenantBottomNav(
          index: _index,
          messagesBadgeCount: 3,
          onChanged: _setIndex,
        ),
      ),
    );
  }
}
DART

echo "🛠️ Writing: lib/features/tenant/explore/explore_screen.dart (restore Buy/Agents/Rent + Land/Commercial + buttons nav)"
cat > lib/features/tenant/explore/explore_screen.dart <<'DART'
import 'package:flutter/material.dart';

import '../../../core/ui/nav/tenant_nav_scope.dart';
import '../viewings/viewings_screen.dart';
import '../alerts/alerts_screen.dart';

const Color _green = Color(0xFF3C7C5A);
const Color _blue = Color(0xFF2E5E9A);

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _TopHeader()),
            SliverToBoxAdapter(
              child: _SearchBar(
                onTap: () {
                  // Switch to Search tab
                  final nav = TenantNavScope.maybeOf(context);
                  if (nav != null) nav.setIndex(1);
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            const SliverToBoxAdapter(child: _SectionTitle(title: 'Featured Listings')),
            const SliverToBoxAdapter(child: _FeaturedCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ✅ Buy / Agents / Rent row (RESTORED)
            const SliverToBoxAdapter(child: _PrimarySegments()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // ✅ Land / Commercial row (RESTORED)
            const SliverToBoxAdapter(child: _SecondarySegments()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // ✅ Saved / Viewings / Alerts buttons
            SliverToBoxAdapter(
              child: _QuickButtons(
                onSaved: () {
                  final nav = TenantNavScope.maybeOf(context);
                  if (nav != null) nav.setIndex(2);
                },
                onViewings: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ViewingsScreen()),
                  );
                },
                onAlerts: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            const SliverToBoxAdapter(child: _SectionTitle(title: 'Latest Listings')),

            SliverPadding(
              // space for floating nav overlay
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 140),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _ListingGridCard(
                    price: _fmtNaira([900000000, 129000000, 650000000, 280000000, 430000000, 120000000][i]),
                    meta: ['4 beds | 3 ba | 2,676 sqft', '3 beds | 2 ba | 1,900 sqft', '5 beds | 4 ba | 3,200 sqft', '2 beds | 2 ba | 1,150 sqft', 'Land | 600sqm', 'Shop | 120sqm'][i],
                    location: ['Lekki, Lagos', 'Ajah, Lagos', 'Wuse 2, Abuja', 'GRA, Port Harcourt', 'Ibeju-Lekki, Lagos', 'Aba, Abia'][i],
                  ),
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
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
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
            child: const Icon(Icons.home_rounded, color: _green),
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
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
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
          height: 48,
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
              const Icon(Icons.chevron_right_rounded, color: _green),
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
  const _FeaturedCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
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
                          color: _green.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Verified Deal',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₦1,150,000,000',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E2A3A),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lekki, Lagos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5B6677),
                          ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimarySegments extends StatelessWidget {
  const _PrimarySegments();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Row(
        children: const [
          Expanded(child: _BigPill(icon: Icons.home_rounded, label: 'Buy', filled: true, color: _blue)),
          SizedBox(width: 10),
          Expanded(child: _BigPill(icon: Icons.shield_outlined, label: 'Agents', filled: true, color: _green)),
          SizedBox(width: 10),
          Expanded(child: _BigPill(icon: Icons.key_rounded, label: 'Rent', filled: true, color: Color(0xFF3E7D7B))),
        ],
      ),
    );
  }
}

class _SecondarySegments extends StatelessWidget {
  const _SecondarySegments();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Row(
        children: const [
          Expanded(child: _SoftPill(label: 'Land')),
          SizedBox(width: 10),
          Expanded(child: _SoftPill(label: 'Commercial')),
        ],
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
            child: _SoftAction(icon: Icons.favorite_rounded, label: 'Saved', onTap: onSaved),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SoftAction(icon: Icons.calendar_month_rounded, label: 'Viewings', onTap: onViewings),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SoftAction(icon: Icons.notifications_rounded, label: 'Alerts', onTap: onAlerts),
          ),
        ],
      ),
    );
  }
}

class _BigPill extends StatelessWidget {
  const _BigPill({
    required this.icon,
    required this.label,
    required this.filled,
    required this.color,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.92) : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF3C4656),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SoftAction extends StatelessWidget {
  const _SoftAction({
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: _green.withValues(alpha: 0.92)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF3C4656),
                fontWeight: FontWeight.w800,
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
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        colors: [Color(0xFFCAD6E9), Color(0xFFA7B9D6)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.house_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.favorite_border_rounded, color: Colors.white.withValues(alpha: 0.95)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E2A3A),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.70),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.70),
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
DART

echo "🎨 dart format..."
dart format lib >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "��️ Backup saved in: $BACKUP_DIR"
