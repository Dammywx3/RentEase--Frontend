import 'package:flutter/material.dart';

import 'tenant_nav_scope.dart';

class TenantNav {
  // TenantShell pages:
  // 0 Explore, 1 Search, 2 Saved, 3 Messages, 4 More

  static void goToExplore(BuildContext context, {bool popToRoot = false}) =>
      _setIndex(context, 0, popToRoot: popToRoot);

  static void goToSearch(BuildContext context, {bool popToRoot = false}) =>
      _setIndex(context, 1, popToRoot: popToRoot);

  static void goToSaved(BuildContext context, {bool popToRoot = false}) =>
      _setIndex(context, 2, popToRoot: popToRoot);

  static void goToMessages(BuildContext context, {bool popToRoot = false}) =>
      _setIndex(context, 3, popToRoot: popToRoot);

  static void goToMore(BuildContext context, {bool popToRoot = false}) =>
      _setIndex(context, 4, popToRoot: popToRoot);

  static void _setIndex(
    BuildContext context,
    int index, {
    required bool popToRoot,
  }) {
    // ✅ Use maybeOf so it won't crash if called outside TenantShell.
    final scope = TenantNavScope.maybeOf(context);
    if (scope == null) return;

    // ✅ Switch tab.
    scope.setIndex(index);

    // ✅ Only pop routes when you explicitly want to return to shell root
    // (e.g. you are inside ListingDetails and want to jump back to Search tab).
    if (!popToRoot) return;

    final nav = Navigator.of(context);
    if (!nav.canPop()) return;

    nav.popUntil((r) => r.isFirst);
  }
}