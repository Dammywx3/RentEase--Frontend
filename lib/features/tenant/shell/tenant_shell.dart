// lib/features/tenant/shell/tenant_shell.dart
import 'package:flutter/material.dart';

import '../../../core/ui/nav/tenant_bottom_nav.dart';
import '../../../core/ui/nav/tenant_nav_scope.dart';

import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../saved/saved_screen.dart';
import '../messages/messages_screen.dart';
import '../messages/tenant_chat_screen.dart'; // for ChatMessageVM demo data
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
    // ✅ Put demo data here (or provider), not inside MessagesScreen.
    // Replace this later with your backend/state.
    final demoConversations = <ConversationVM>[
      ConversationVM(
        id: 'c1',
        kind: ConversationKind.agent,
        displayName: 'Chinedu Okafor',
        isVerified: true,
        listingTitle: 'Lekki Phase 1 • Unit 3B',
        listingPriceText: '₦420,000/mo',
        listingThumbAsset: 'assets/images/listing_011.png',
        lastMessagePreview: 'Viewing confirmed for Sat 2pm. Please...',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 8)),
        unreadCount: 3,
        messages: [
          ChatMessageVM.system(
            id: 's1',
            text: 'Viewing confirmed',
            at: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessageVM.other(
            id: 'a1',
            text: 'Your application has been received!',
            at: DateTime.now().subtract(const Duration(hours: 2, minutes: 6)),
          ),
          ChatMessageVM.other(
            id: 'a2',
            text:
                'Viewing confirmed for Sat 2pm. Please make sure to bring any necessary documents.',
            at: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          ChatMessageVM.user(
            id: 'u1',
            text: 'Thank you! What paperwork should I bring?',
            at: DateTime.now().subtract(const Duration(minutes: 28)),
          ),
          ChatMessageVM.user(
            id: 'u2',
            text: 'See you Saturday!',
            at: DateTime.now().subtract(const Duration(minutes: 25)),
          ),
        ],
      ),
    ];

    final messagesBadgeCount =
        demoConversations.fold<int>(0, (sum, c) => sum + c.unreadCount);

    final pages = <Widget>[
      const ExploreScreen(),
      const SearchScreen(),
      const SavedScreen(),
      MessagesScreen(
        conversations: demoConversations,
        onExploreHomes: () => _setIndex(0), // go back to Explore
      ),
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
          messagesBadgeCount: messagesBadgeCount,
          onChanged: _setIndex,
        ),
      ),
    );
  }
}