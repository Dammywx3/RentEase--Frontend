import 'package:flutter/material.dart';

class TenantBottomNav extends StatelessWidget {
  const TenantBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.savedBadgeCount,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int? savedBadgeCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget badge(Widget icon) {
      final n = savedBadgeCount ?? 0;
      if (n <= 0) return icon;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cs.surface, width: 2),
              ),
              child: Text(
                n > 99 ? '99+' : '$n',
                style: TextStyle(
                  color: cs.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      height: 68,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: 'Explore',
        ),
        const NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        NavigationDestination(
          icon: badge(const Icon(Icons.favorite_border_rounded)),
          selectedIcon: badge(const Icon(Icons.favorite_rounded)),
          label: 'Saved',
        ),
        const NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Messages',
        ),
        const NavigationDestination(
          icon: Icon(Icons.more_horiz_rounded),
          selectedIcon: Icon(Icons.more_horiz_rounded),
          label: 'More',
        ),
      ],
    );
  }
}
