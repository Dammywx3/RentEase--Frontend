#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_explore_nav_exact_$TS"
mkdir -p "$BACKUP_DIR"

backup_file () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "📍 Repo: $ROOT_DIR"
echo "🗂️ Backing up files..."
backup_file "lib/features/tenant/shell/tenant_shell.dart"
backup_file "lib/core/ui/nav/tenant_bottom_nav.dart"
backup_file "lib/features/tenant/explore/explore_screen.dart"

echo "🛠️ Writing: lib/features/tenant/shell/tenant_shell.dart"
cat > lib/features/tenant/shell/tenant_shell.dart <<'DART'
import 'package:flutter/material.dart';

import '../../../core/ui/nav/tenant_bottom_nav.dart';
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../saved/saved_screen.dart';
import '../messages/messages_screen.dart';
import '../more/more_screen.dart';

/// Allows child pages (Explore quick buttons) to switch tabs without GoRouter changes.
class TenantShellController extends InheritedWidget {
  const TenantShellController({
    super.key,
    required this.setIndex,
    required super.child,
  });

  final void Function(int) setIndex;

  static TenantShellController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TenantShellController>();
  }

  @override
  bool updateShouldNotify(TenantShellController oldWidget) => false;
}

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

  void _setIndex(int i) {
    if (!mounted) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ExploreScreen(),
      const SearchScreen(),
      const SavedScreen(),
      const MessagesScreen(),
      const MoreScreen(),
    ];

    return TenantShellController(
      setIndex: _setIndex,
      child: Scaffold(
        extendBody: true,
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

echo "🛠️ Writing: lib/core/ui/nav/tenant_bottom_nav.dart"
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

  static const _active = Color(0xFF3C7C5A); // green
  static const _inactive = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // This keeps it sitting "on the bottom" like the mock:
    // - SafeArea protects iPhone gesture bar
    // - minimum adds a small consistent gap (not a big floating space)
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
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
                // if device has no inset, we add a tiny internal padding so it still looks like mock
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: bottomInset == 0 ? 10 : 9,
                ),
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
                  Icon(active ? iconActive : icon, color: c, size: 22),
                  if (badgeCount > 0)
                    Positioned(
                      top: 0,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD07A53),
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

echo "🛠️ Writing: lib/features/tenant/explore/explore_screen.dart"
cat > lib/features/tenant/explore/explore_screen.dart <<'DART'
import 'package:flutter/material.dart';
import '../shell/tenant_shell.dart';

// NOTE: this Explore is a UI mock screen.
// - Amounts shown in NGN
// - Addresses are Nigerian-style
// - Buttons switch tabs (Search/Saved/Viewings) using TenantShellController.

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);
  static const _green = Color(0xFF3C7C5A);
  static const _blue = Color(0xFF2E5FA7);

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
            SliverToBoxAdapter(child: _SearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            const SliverToBoxAdapter(child: _SectionTitle(title: 'Featured Listings')),
            SliverToBoxAdapter(child: _FeaturedCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _ActionRows()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: _SectionTitle(title: 'Latest Listings')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 140),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _ListingGridCard(index: i),
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
    // closer to mock: logo left, brand center-left, profile right
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
            child: const Icon(Icons.home_rounded, color: Color(0xFF3C7C5A)),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
              children: const [
                TextSpan(text: 'Home', style: TextStyle(color: Color(0xFF1E2A3A))),
                TextSpan(text: 'Stead', style: TextStyle(color: Color(0xFF3C7C5A))),
              ],
            ),
          ),
          const Spacer(),
          Container(
            height: 40,
            width: 40,
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
  @override
  Widget build(BuildContext context) {
    final shell = TenantShellController.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 2),
      child: InkWell(
        onTap: () => shell?.setIndex(1), // go to Search tab
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
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
  @override
  Widget build(BuildContext context) {
    // single featured card like mock
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
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
                            Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Verified Deal',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
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
                      '₦1,150,000,000',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E2A3A),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lekki, Lagos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

class _ActionRows extends StatelessWidget {
  static const _green = Color(0xFF3C7C5A);
  static const _blue = Color(0xFF2E5FA7);

  @override
  Widget build(BuildContext context) {
    final shell = TenantShellController.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Column(
        children: [
          // Row 1: Buy / Agents / Rent
          Row(
            children: [
              Expanded(
                child: _PillButton(
                  label: 'Buy',
                  icon: Icons.home_rounded,
                  bg: _blue,
                  fg: Colors.white,
                  onTap: () {}, // later: apply filter
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PillButton(
                  label: 'Agents',
                  icon: Icons.shield_rounded,
                  bg: _green,
                  fg: Colors.white,
                  onTap: () {}, // later: agents page
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PillButton(
                  label: 'Rent',
                  icon: Icons.search_rounded,
                  bg: const Color(0xFF2B7A78),
                  fg: Colors.white,
                  onTap: () {}, // later: apply filter
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Land / Commercial chips
          Row(
            children: const [
              Expanded(child: _ChipPill(label: 'Land')),
              SizedBox(width: 10),
              Expanded(child: _ChipPill(label: 'Commercial')),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Saved / Viewings / Alerts buttons (navigate)
          Row(
            children: [
              Expanded(
                child: _IconChip(
                  label: 'Saved',
                  icon: Icons.favorite_rounded,
                  iconColor: _green,
                  onTap: () => shell?.setIndex(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IconChip(
                  label: 'Viewings',
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFF2E5FA7),
                  onTap: () {
                    // If you have viewings in tab 4 or a dedicated viewings route later,
                    // for now, push to your tenant viewings screen if it exists.
                    Navigator.of(context).pushNamed('/tenant/viewings');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IconChip(
                  label: 'Alerts',
                  icon: Icons.notifications_rounded,
                  iconColor: const Color(0xFFD2A24C),
                  onTap: () {
                    Navigator.of(context).pushNamed('/tenant/alerts');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF334155),
            ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.70),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF334155),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingGridCard extends StatelessWidget {
  const _ListingGridCard({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    // Nigerian sample listings
    final items = const [
      ('₦900,000,000', '4 beds | 3 baths | 2,676 sqft', 'Ikoyi, Lagos'),
      ('₦129,000,000', '3 beds | 2 baths | 1,900 sqft', 'Ajah, Lagos'),
      ('₦210,000,000', '3 beds | 3 baths | 2,100 sqft', 'Gwarinpa, Abuja'),
      ('₦75,000,000', '2 beds | 2 baths | 1,200 sqft', 'Port Harcourt, Rivers'),
      ('₦480,000,000', '5 beds | 5 baths | 3,500 sqft', 'Lekki Phase 1, Lagos'),
      ('₦55,000,000', 'Land | 600 sqm', 'Ibeju-Lekki, Lagos'),
    ];

    final (price, meta, location) = items[index % items.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.house_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E2A3A),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF4E5A6D),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
echo "🗂️ Backup saved in: $BACKUP_DIR"
