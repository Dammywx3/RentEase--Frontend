import 'package:flutter/material.dart';

/// AppScaffold
/// - Optional background (widget) OR backgroundImagePath
/// - Optional appBar and optional custom topBar (widget under appBar)
/// - Optional bottomNavigationBar
/// - Optional safe area controls (top/bottom)
/// - scroll=true wraps child in SingleChildScrollView
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.topBar,
    this.appBar,
    this.bottomNavigationBar,
    this.background,
    this.backgroundImagePath,
    this.backgroundColor,
    this.padding,
    this.scroll = false,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
  });

  final Widget child;

  /// A widget shown at the top of the page content (below the appBar if any).
  final Widget? topBar;

  /// Standard Scaffold appBar
  final PreferredSizeWidget? appBar;

  /// Standard Scaffold bottomNavigationBar
  final Widget? bottomNavigationBar;

  /// A background widget placed behind content (e.g., gradient DecoratedBox).
  final Widget? background;

  /// Optional background image path placed behind content.
  final String? backgroundImagePath;

  /// Scaffold backgroundColor
  final Color? backgroundColor;

  final EdgeInsets? padding;
  final bool scroll;

  /// SafeArea toggles
  final bool safeAreaTop;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? EdgeInsets.zero;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: Stack(
          children: [
            if (background != null) Positioned.fill(child: background!),
            if (backgroundImagePath != null)
              Positioned.fill(
                child: Image.asset(backgroundImagePath!, fit: BoxFit.cover),
              ),

            // Column + Expanded ensures bounded height.
            Column(
              children: [
                if (topBar != null) topBar!,
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      Widget content = Padding(padding: pad, child: child);

                      if (scroll) {
                        content = SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: content,
                          ),
                        );
                      }

                      return content;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
