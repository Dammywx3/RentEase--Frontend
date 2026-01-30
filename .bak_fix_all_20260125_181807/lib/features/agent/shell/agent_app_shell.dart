import 'package:flutter/material.dart';

import '../listings/listings_screen.dart';
import '../applications/applications_screen.dart';
import '../viewings/viewings_screen.dart';
import '../tenancies/tenancies_screen.dart';
import '../payments_payouts/wallet_summary_screen.dart';
import '../verification/verification_dashboard_screen.dart';

class AgentAppShell extends StatefulWidget {
  const AgentAppShell({super.key});

  @override
  State<AgentAppShell> createState() => _AgentAppShellState();
}

class _AgentAppShellState extends State<AgentAppShell> {
  int _index = 0;

  final _pages = const <Widget>[
    ListingsScreen(),
    ApplicationsScreen(),
    ViewingsScreen(),
    TenanciesScreen(),
    WalletSummaryScreen(),
    VerificationDashboardScreen(),
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
            icon: Icon(Icons.home_work_rounded),
            label: 'Listings',
          ),
          NavigationDestination(icon: Icon(Icons.inbox_rounded), label: 'Apps'),
          NavigationDestination(
            icon: Icon(Icons.event_available_rounded),
            label: 'Viewings',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_rounded),
            label: 'Tenancies',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_rounded),
            label: 'Verify',
          ),
        ],
      ),
    );
  }
}
