import 'package:flutter/material.dart';

import '../../../core/ui/nav/tenant_bottom_nav.dart';
import '../../../core/ui/nav/tenant_nav_scope.dart';

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

  void _setIndex(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ExploreScreen(),
      const SearchScreen(),
      const SavedScreen(),
      const MessagesScreen(),
      const MoreScreen(),
    ];

    return TenantNavScope(
      index: _index,
      setIndex: _setIndex,
      child: Scaffold(
        extendBody: true, // nav floats over background like mock
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: TenantBottomNav(
          index: _index,
          messagesBadgeCount: 3,
          onChanged: _setIndex,
        ),
      ),
    );
  }
}
