import 'package:flutter/material.dart';

import '../../../core/ui/nav/tenant_bottom_nav.dart';
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../saved/saved_screen.dart';
import '../messages/messages_screen.dart';
import '../more/more_screen.dart';

/// Allows child pages (Explore quick buttons) to switch tabs without GoRouter changes.
class TenantShellController extends InheritedWidget {
  const TenantShellController({
    super.key,
    required this.setIndex,
    required super.child,
  });

  final void Function(int) setIndex;

  static TenantShellController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TenantShellController>();
  }

  @override
  bool updateShouldNotify(TenantShellController oldWidget) => false;
}

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

  void _setIndex(int i) {
    if (!mounted) return;
    setState(() => _index = i);
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

    return TenantShellController(
      setIndex: _setIndex,
      child: Scaffold(
        extendBody: true,
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
