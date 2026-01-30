import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AgentShell extends StatelessWidget {
  const AgentShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_work_rounded), label: 'Listings'),
          NavigationDestination(icon: Icon(Icons.inbox_rounded), label: 'Apps'),
          NavigationDestination(icon: Icon(Icons.event_rounded), label: 'Viewings'),
          NavigationDestination(icon: Icon(Icons.handshake_rounded), label: 'Tenancies'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Payments'),
          NavigationDestination(icon: Icon(Icons.verified_rounded), label: 'Verify'),
        ],
      ),
    );
  }
}
