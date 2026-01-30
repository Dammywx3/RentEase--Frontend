#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_exact_explore_nav_$TS"
mkdir -p "$BACKUP_DIR"

backup() {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "📍 Repo: $ROOT_DIR"
echo "��️ Backup dir: $BACKUP_DIR"

# Files we will write/replace
TARGETS=(
  "lib/core/ui/nav/tenant_bottom_nav.dart"
  "lib/features/tenant/shell/tenant_shell.dart"
  "lib/features/tenant/explore/explore_screen.dart"
  "lib/features/tenant/search/search_screen.dart"
  "lib/features/tenant/saved/saved_screen.dart"
  "lib/features/tenant/messages/messages_screen.dart"
  "lib/features/tenant/more/more_screen.dart"
)

for f in "${TARGETS[@]}"; do backup "$f"; done

mkdir -p lib/core/ui/nav
mkdir -p lib/features/tenant/shell
mkdir -p lib/features/tenant/explore
mkdir -p lib/features/tenant/search
mkdir -p lib/features/tenant/saved
mkdir -p lib/features/tenant/messages
mkdir -p lib/features/tenant/more

echo "🛠️ Writing: lib/core/ui/nav/tenant_bottom_nav.dart"
cat > lib/core/ui/nav/tenant_bottom_nav.dart <<'DART'
import 'dart:ui';
import 'package:flutter/material.dart';

class TenantBottomNav extends StatelessWidget {
  const TenantBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    this.messagesBadgeCount = 3,
  });

  final int index;
  final ValueChanged<int> onChanged;

  /// Set to 0 if you want no badge.
  final int messagesBadgeCount;

  static const _active = Color(0xFF3C7C5A); // green like mock
  static const _inactive = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottom = media.padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, 10 + (bottom == 0 ? 8 : 0)),
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
                  if (active)
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: activeColor.withValues(alpha: 0.55), width: 1.6),
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

echo "🛠️ Writing: lib/features/tenant/shell/tenant_shell.dart"
cat > lib/features/tenant/shell/tenant_shell.dart <<'DART'
import 'package:flutter/material.dart';

import '../../../core/ui/nav/tenant_bottom_nav.dart';
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

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ExploreScreen(),
      const SearchScreen(),
      const SavedScreen(),
      const MessagesScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      extendBody: true, // needed for frosted nav overlay
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: TenantBottomNav(
        index: _index,
        messagesBadgeCount: 3,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}
DART

echo "🛠️ Writing: lib/features/tenant/explore/explore_screen.dart"
cat > lib/features/tenant/explore/explore_screen.dart <<'DART'
import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

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
            SliverToBoxAdapter(child: _SectionTitle(title: 'Featured Listings')),
            SliverToBoxAdapter(child: _FeaturedCarousel()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(child: _QuickActions()),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(child: _SectionTitle(title: 'Latest Listings')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 140), // space for bottom nav overlay
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          // Logo + brand (match mock vibe)
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
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
              color: Colors.white.withValues(alpha: 0.9),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 2),
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
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF3C7C5A)),
          ],
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

class _FeaturedCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Single card like mock (you can later swap into PageView)
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
                    // image placeholder (swap to your listing image asset later)
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFB9C7DD),
                            Color(0xFF879BB8),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.villa_rounded, size: 54, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(Icons.favorite_border_rounded, color: Colors.white.withValues(alpha: 0.95), size: 26),
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
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
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
                      'US\$1,150,000',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E2A3A),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tulsa, OK',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5C6677),
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

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Buy / Agents / Rent (colored pills)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Row(
            children: const [
              Expanded(child: _Pill(icon: Icons.home_rounded, label: 'Buy', kind: _PillKind.blue)),
              SizedBox(width: 10),
              Expanded(child: _Pill(icon: Icons.shield_rounded, label: 'Agents', kind: _PillKind.green)),
              SizedBox(width: 10),
              Expanded(child: _Pill(icon: Icons.key_rounded, label: 'Rent', kind: _PillKind.teal)),
            ],
          ),
        ),

        // Land / Commercial (light pills)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Row(
            children: const [
              Expanded(child: _SoftPill(label: 'Land')),
              SizedBox(width: 10),
              Expanded(child: _SoftPill(label: 'Commercial')),
            ],
          ),
        ),

        // Saved / Viewings / Alerts (light pills with icons)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Row(
            children: const [
              Expanded(child: _IconSoftPill(icon: Icons.favorite_rounded, label: 'Saved', tint: Color(0xFF3C7C5A))),
              SizedBox(width: 10),
              Expanded(child: _IconSoftPill(icon: Icons.calendar_month_rounded, label: 'Viewings', tint: Color(0xFF2E6EF7))),
              SizedBox(width: 10),
              Expanded(child: _IconSoftPill(icon: Icons.notifications_rounded, label: 'Alerts', tint: Color(0xFFD0A44F))),
            ],
          ),
        ),
      ],
    );
  }
}

enum _PillKind { blue, green, teal }

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.kind});
  final IconData icon;
  final String label;
  final _PillKind kind;

  @override
  Widget build(BuildContext context) {
    final bg = () {
      switch (kind) {
        case _PillKind.blue:
          return const Color(0xFF3E6EA8);
        case _PillKind.green:
          return const Color(0xFF5E7E66);
        case _PillKind.teal:
          return const Color(0xFF4B7E7C);
      }
    }();

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.95), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
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
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4E5A6D),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconSoftPill extends StatelessWidget {
  const _IconSoftPill({required this.icon, required this.label, required this.tint});
  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: tint, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4E5A6D),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingGridCard extends StatelessWidget {
  const _ListingGridCard({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final price = index.isEven ? 'US\$900,000' : 'US\$129,000';
    final meta = index.isEven ? '4 bds | 3 ba | 2,676 sqft' : '3 bds | 2 ba | 1,900 sqft';
    final location = index.isEven ? 'Sand Springs, OK' : 'Jenks, OK';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.10),
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
                        colors: [
                          Color(0xFFBFD0EA),
                          Color(0xFF8AA0C2),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.house_rounded, size: 46, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.favorite_border_rounded, color: Colors.white.withValues(alpha: 0.95), size: 22),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          color: const Color(0xFF5C6677),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF5C6677),
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

# Simple placeholders (so nav works immediately)
echo "🛠️ Writing placeholder screens..."
cat > lib/features/tenant/search/search_screen.dart <<'DART'
import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Search (placeholder)'),
        ),
      ),
    );
  }
}
DART

cat > lib/features/tenant/saved/saved_screen.dart <<'DART'
import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Saved (placeholder)'),
        ),
      ),
    );
  }
}
DART

cat > lib/features/tenant/messages/messages_screen.dart <<'DART'
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Messages (placeholder)'),
        ),
      ),
    );
  }
}
DART

cat > lib/features/tenant/more/more_screen.dart <<'DART'
import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('More (placeholder)'),
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
echo "🗂️ Backups saved in: $BACKUP_DIR"
echo "▶️ Now run: flutter run"
