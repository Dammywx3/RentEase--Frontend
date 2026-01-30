import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';

class AgentBottomNav extends StatelessWidget {
  const AgentBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.dividerDark : AppColors.dividerLight)
                .withAlpha(200),
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadii.lg),
          topRight: Radius.circular(AppRadii.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: isDark
              ? AppColors.brandBlueSoft
              : AppColors.brandBlue,
          unselectedItemColor: isDark
              ? AppColors.textMutedLight
              : AppColors.textMutedDark,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_work_rounded),
              label: 'Listings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: 'Apps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available_rounded),
              label: 'Viewings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman_rounded),
              label: 'Maintenance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet_rounded),
              label: 'Wallet',
            ),
          ],
        ),
      ),
    );
  }
}
