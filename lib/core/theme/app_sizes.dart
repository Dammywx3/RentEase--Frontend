import 'package:flutter/material.dart';
import 'app_spacing.dart';

/// AppSizes = layout sizing tokens derived from your existing spacing scale.
/// Goal: NO magic numbers inside screens/widgets.
class AppSizes {
  AppSizes._();

  // Top bar height: 64 = 32 + 32
  static const double topBarHeight = AppSpacing.xxxl + AppSpacing.xxxl;

  // Common control heights
  static const double pillButtonHeight = AppSpacing.s44; // 44

  // Search height: 52 = 44 + 8
  static const double searchFieldHeight = AppSpacing.s44 + AppSpacing.sm;

  // Round icon button box: 42 = 34 + 8
  static const double iconButtonBox = AppSpacing.s34 + AppSpacing.sm;

  // List thumbnail: 62 = 44 + 16 + 2
  static const double listThumbSize =
      AppSpacing.s44 + AppSpacing.lg + AppSpacing.s2;

  // Bottom content padding (avoid being covered by sticky buttons / bottom nav)
  // 140 = 32*4 + 12
  static const double screenBottomPad = (AppSpacing.xxxl * 4) + AppSpacing.md;

  // Featured cards:
  // Use an aspect ratio token so we can compute height from width.
  static const double featuredCardAspect = 0.78;

  // Helpful minimums / maximums for card width (tokens live here, not in screens)
  static const double featuredCardMinW = AppSpacing.xxxl * 5; // 160
  static const double featuredCardMaxW = AppSpacing.xxxl * 14; // 448

  static const double minTap = kMinInteractiveDimension; // 48
}
