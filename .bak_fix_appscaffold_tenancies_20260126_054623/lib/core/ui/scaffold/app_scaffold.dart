import 'package:flutter/material.dart';

/// AppScaffold
/// - Safely constrains page layout to prevent "RenderBox was not laid out"
/// - Optional background image
/// - Optional topBar widget (your AppTopBar fits here)
/// - scroll=true wraps body in SingleChildScrollView (keeps old API working)
/// - backgroundColor allows transparent scaffold (for gradient backgrounds)
/// - safeAreaBottom allows bottom: false (useful inside shells / custom layouts)
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.topBar,
    this.padding,
    this.backgroundImagePath,
    this.scroll = false,
    this.backgroundColor,
    this.safeAreaBottom = true,
  });

  final Widget child;
  final Widget? topBar;
  final EdgeInsets? padding;
  final String? backgroundImagePath;
  final bool scroll;

  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final Color? backgroundColor;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? EdgeInsets.zero;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
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
