import 'package:flutter/material.dart';

class TenantAppShell extends StatefulWidget {
  const TenantAppShell({super.key});

  @override
  State<TenantAppShell> createState() => _TenantAppShellState();
}

class _TenantAppShellState extends State<TenantAppShell> {
  int _index = 0;

  final _pages = const <Widget>[
    _TenantHomeTab(),
    _TenantInboxTab(),
    _TenantTenanciesTab(),
    _TenantViewingsTab(),
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
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Tenancies'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Viewings'),
          NavigationDestination(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }
}

class _TenantHomeTab extends StatelessWidget {
  const _TenantHomeTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Tenant Home (Shell OK ✅)')),
    );
  }
}

class _TenantInboxTab extends StatelessWidget {
  const _TenantInboxTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Tenant Inbox')),
    );
  }
}

class _TenantTenanciesTab extends StatelessWidget {
  const _TenantTenanciesTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Tenant Tenancies')),
    );
  }
}

class _TenantViewingsTab extends StatelessWidget {
  const _TenantViewingsTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Tenant Viewings')),
    );
  }
}

class _TenantMoreTab extends StatelessWidget {
  const _TenantMoreTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Tenant More')),
    );
  }
}
