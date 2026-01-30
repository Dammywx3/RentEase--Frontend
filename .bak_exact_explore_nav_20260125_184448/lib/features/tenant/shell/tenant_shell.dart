import 'package:flutter/material.dart';
import '../../../core/ui/nav/tenant_bottom_nav.dart';
import '../explore/explore_screen.dart';
import '../applications/applications_screen.dart';
import '../viewings/viewings_screen.dart';
import '../maintenance/maintenance_screen.dart';

/// TenantShell
/// Bottom-nav structure matching the mock:
/// 0 Explore
/// 1 Search (placeholder for now)
/// 2 Saved (using ApplicationsScreen as placeholder)
/// 3 Messages (using ViewingsScreen as placeholder)
/// 4 More (using ProfileScreen / MaintenanceScreen etc as placeholder)
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
      const _SearchPlaceholder(),
      const ApplicationsScreen(), // Saved placeholder
      const ViewingsScreen(), // Messages placeholder
      const _MorePlaceholder(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: TenantBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        savedBadgeCount: 3, // demo badge like the mock
      ),
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Center(child: Text('Search (coming soon)')));
  }
}

class _MorePlaceholder extends StatelessWidget {
  const _MorePlaceholder();

  @override
  Widget build(BuildContext context) {
    // You can swap this to your real More screen later
    return const MaintenanceScreen(); // quick “More” placeholder
  }
}
