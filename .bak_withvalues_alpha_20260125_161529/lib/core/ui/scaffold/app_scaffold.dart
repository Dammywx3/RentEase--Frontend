import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.topBar,
    this.bottomNav,
    this.padding,
    this.scroll = true,
    this.safeTop = true,
    this.safeBottom = true,
    this.bgColor,
  });

  final Widget child;
  final PreferredSizeWidget? topBar;
  final Widget? bottomNav;
  final EdgeInsets? padding;
  final bool scroll;
  final bool safeTop;
  final bool safeBottom;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = _MaxWidth(
      child: Padding(
        padding:
            padding ??
            const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.screenV,
              AppSpacing.screenH,
              AppSpacing.screenV,
            ),
        child: child,
      ),
    );

    final body = scroll
        ? SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: content,
          )
        : content;

    return Scaffold(
      backgroundColor: bgColor ?? theme.scaffoldBackgroundColor,
      appBar: topBar,
      bottomNavigationBar: bottomNav,
      body: SafeArea(top: safeTop, bottom: safeBottom, child: body),
    );
  }
}

/// Keeps content nice on big screens (tablet/web) while still mobile-first.
class _MaxWidth extends StatelessWidget {
  const _MaxWidth({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;

        // Mobile first; limit on larger screens for premium feel.
        final maxW = w < 520
            ? w
            : w < 900
            ? 520.0
            : 620.0;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: child,
          ),
        );
      },
    );
  }
}
