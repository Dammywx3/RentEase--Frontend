import 'package:flutter/material.dart';

import 'tenant_nav_scope.dart';

class TenantNav {
  // TenantShell pages:
  // 0 Explore, 1 Search, 2 Saved, 3 Messages, 4 More

  static void goToExplore(BuildContext context) => _setIndex(context, 0);
  static void goToSearch(BuildContext context) => _setIndex(context, 1);
  static void goToSaved(BuildContext context) => _setIndex(context, 2);
  static void goToMessages(BuildContext context) => _setIndex(context, 3);
  static void goToMore(BuildContext context) => _setIndex(context, 4);

  static void _setIndex(BuildContext context, int index) {
    final scope = context.dependOnInheritedWidgetOfExactType<TenantNavScope>();
    if (scope == null) return;

    scope.setIndex(index);

    // If this was called from inside a pushed route (like ListingDetails),
    // bring user back to the TenantShell root.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }
}