import 'package:flutter/material.dart';

/// AppScaffold
/// - Safely constrains page layout to prevent "RenderBox was not laid out"
/// - Optional background image
/// - Optional topBar widget (your AppTopBar fits here)
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.topBar,
    this.padding,
    this.backgroundImagePath,
  });

  final Widget child;
  final Widget? topBar;
  final EdgeInsets? padding;
  final String? backgroundImagePath;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? EdgeInsets.zero;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (backgroundImagePath != null)
              Positioned.fill(
                child: Image.asset(backgroundImagePath!, fit: BoxFit.cover),
              ),

            // The key piece: Column + Expanded -> gives the body a bounded height
            Column(
              children: [
                if (topBar != null) topBar!,
                Expanded(
                  child: Padding(padding: pad, child: child),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
