import 'package:flutter/material.dart';

import '../../../core/ui/nav/tenant_bottom_nav.dart';
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../saved/saved_screen.dart';
import '../messages/messages_screen.dart';
import '../more/more_screen.dart';

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
      const SearchScreen(),
      const SavedScreen(),
      const MessagesScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      extendBody: true, // needed for frosted nav overlay
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: TenantBottomNav(
        index: _index,
        savedBadgeCount: 3,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}
