import 'package:flutter/material.dart';

// ✅ Real tenant screens that exist in your codebase
import '../home/home_screen.dart';
import '../viewings/viewings_screen.dart';

class TenantAppShell extends StatefulWidget {
  const TenantAppShell({super.key});

  @override
  State<TenantAppShell> createState() => _TenantAppShellState();
}

class _TenantAppShellState extends State<TenantAppShell> {
  int _index = 0;

  // NOTE:
  // - HomeScreen() is real (Explore)
  // - ViewingsScreen() is real
  // - Others are placeholders until you point them to your real screens
  final _pages = const <Widget>[
    HomeScreen(),
    _TenantInboxTab(),
    _TenantTenanciesTab(),
    ViewingsScreen(),
    _TenantMoreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_rounded), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Tenancies'),
          NavigationDestination(icon: Icon(Icons.event_available_rounded), label: 'Viewings'),
          NavigationDestination(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }
}

class _TenantInboxTab extends StatelessWidget {
  const _TenantInboxTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Tenant Inbox (placeholder)')),
    );
  }
}

class _TenantTenanciesTab extends StatelessWidget {
  const _TenantTenanciesTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Tenant Tenancies (placeholder)')),
    );
  }
}

class _TenantMoreTab extends StatelessWidget {
  const _TenantMoreTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Tenant More (placeholder)')),
    );
  }
}
