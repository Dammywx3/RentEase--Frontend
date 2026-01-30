import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../applications/applications_screen.dart';
import '../viewings/viewings_screen.dart';
import '../payments/payments_screen.dart';
import '../profile/profile_screen.dart';

class TenantAppShell extends StatefulWidget {
  const TenantAppShell({super.key});

  @override
  State<TenantAppShell> createState() => _TenantAppShellState();
}

class _TenantAppShellState extends State<TenantAppShell> {
  int _index = 0;

  final _pages = const <Widget>[
    HomeScreen(), // Explore
    ApplicationsScreen(), // Applications
    ViewingsScreen(), // Viewings
    PaymentsScreen(), // Payments
    ProfileScreen(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_rounded),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_rounded),
            label: 'Viewings',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_rounded),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
