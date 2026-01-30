import 'package:flutter/widgets.dart';

/// Allows inner screens (Explore etc.) to switch the Tenant bottom-nav tab.
class TenantNavScope extends InheritedWidget {
  const TenantNavScope({
    super.key,
    required this.index,
    required this.setIndex,
    required super.child,
  });

  final int index;
  final ValueChanged<int> setIndex;

  static TenantNavScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TenantNavScope>();
    assert(scope != null, 'TenantNavScope not found above this context.');
    return scope!;
  }

  static TenantNavScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TenantNavScope>();
  }

  @override
  bool updateShouldNotify(TenantNavScope oldWidget) => index != oldWidget.index;
}
