import 'package:flutter/material.dart';

// ✅ Real agent screens that exist in your codebase
import '../tenancies/tenancies_screen.dart';
import '../viewings/viewings_screen.dart';

class AgentAppShell extends StatefulWidget {
  const AgentAppShell({super.key});

  @override
  State<AgentAppShell> createState() => _AgentAppShellState();
}

class _AgentAppShellState extends State<AgentAppShell> {
  int _index = 0;

  final _pages = const <Widget>[
    _AgentHomeTab(),
    _AgentInboxTab(),
    _AgentListingsTab(),
    ViewingsScreen(),     // real (placeholder content but real screen)
    TenanciesScreen(),    // real
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
          NavigationDestination(icon: Icon(Icons.apartment_rounded), label: 'Listings'),
          NavigationDestination(icon: Icon(Icons.event_available_rounded), label: 'Viewings'),
          NavigationDestination(icon: Icon(Icons.assignment_rounded), label: 'Tenancies'),
        ],
      ),
    );
  }
}

class _AgentHomeTab extends StatelessWidget {
  const _AgentHomeTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Agent Home (placeholder)')),
    );
  }
}

class _AgentInboxTab extends StatelessWidget {
  const _AgentInboxTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Agent Inbox (placeholder)')),
    );
  }
}

class _AgentListingsTab extends StatelessWidget {
  const _AgentListingsTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('Agent Listings (placeholder)')),
    );
  }
}
