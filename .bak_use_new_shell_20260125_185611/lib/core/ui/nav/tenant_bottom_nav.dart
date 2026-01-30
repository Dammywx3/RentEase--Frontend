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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
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
                          color: const Color(
                            0xFFD07A53,
                          ), // orange badge like mock
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
