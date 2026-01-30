import 'package:flutter/material.dart';

/// AppScaffold
/// - Bounded layout (prevents "RenderBox was not laid out")
/// - Optional background image
/// - Optional appBar (AppBar) OR topBar (any widget)
/// - Optional padding
/// - Optional scroll wrapper
///
/// Backwards-compatible:
/// - Supports `child:` (old usage)
/// - Supports `body:` (alias) for screens that were patched from Scaffold(body: ...)
/// - Supports `backgroundColor:` and `safeAreaBottom:` for gradient/transparent pages
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.child,
    this.body,
    this.topBar,
    this.appBar,
    this.padding,
    this.backgroundImagePath,
    this.scroll = false,
    this.backgroundColor,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
  });

  /// Preferred: use `child:` going forward.
  final Widget? child;

  /// Alias for `child:` to support patched screens that use `body:`.
  final Widget? body;

  /// Any widget header (custom top bars).
  final Widget? topBar;

  /// Standard app bar (takes priority over topBar if provided).
  final PreferredSizeWidget? appBar;

  final EdgeInsets? padding;
  final String? backgroundImagePath;
  final bool scroll;

  /// Scaffold background color (use transparent when you paint a gradient outside).
  final Color? backgroundColor;

  final bool safeAreaTop;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? EdgeInsets.zero;

    final content = child ?? body;
    assert(content != null, 'AppScaffold requires either child: or body:.');

    final header = appBar ?? topBar;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: Stack(
          children: [
            if (backgroundImagePath != null)
              Positioned.fill(
                child: Image.asset(backgroundImagePath!, fit: BoxFit.cover),
              ),

            // Column + Expanded ensures bounded height.
            Column(
              children: [
                if (header != null) header,
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      Widget contentWidget = Padding(
                        padding: pad,
                        child: content!,
                      );

                      if (scroll) {
                        contentWidget = SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: contentWidget,
                          ),
                        );
                      }

                      return contentWidget;
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
