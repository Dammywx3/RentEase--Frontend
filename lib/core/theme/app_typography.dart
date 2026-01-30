import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  // Common font sizes (avoid hardcoding in screens)
  static const double size12 = 12;
  static const double size16 = 16;
  static const double size18 = 18;

  AppTypography._();

  static const _baseFont = 'SF Pro Display';

  /// Light text theme (premium, slightly bold headings)
  static TextTheme lightTextTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.6),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4),
    headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.2),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.1),
    titleLarge: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
    titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, height: 1.35),
    bodyMedium: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.35),
    bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.30),
    labelLarge: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, letterSpacing: 0.2),
    labelMedium: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.2),
    labelSmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.2),
  );

  static TextTheme darkTextTheme = lightTextTheme;

  static TextTheme applyFont(TextTheme base) => base.apply(fontFamily: _baseFont);

  static TextTheme withLightColors(TextTheme base) => base.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      );

  static TextTheme withDarkColors(TextTheme base) => base.apply(
        bodyColor: AppColors.textLight,
        displayColor: AppColors.textLight,
      );

  // ---------------------------------------------------------------------------
  // Convenience helpers used across screens (these are what your UI expects)
  // ---------------------------------------------------------------------------

  static TextStyle h1(BuildContext context) =>
      (Theme.of(context).textTheme.displaySmall ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.w800));

  static TextStyle h2(BuildContext context) =>
      (Theme.of(context).textTheme.headlineLarge ?? const TextStyle(fontSize: 22, fontWeight: FontWeight.w800));

  static TextStyle h3(BuildContext context) =>
      (Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w800));

  static TextStyle h4(BuildContext context) =>
      (Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w800));

  static TextStyle body(BuildContext context) =>
      (Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500));

  static TextStyle caption(BuildContext context) =>
      (Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w500));

  static TextStyle label(BuildContext context) =>
      (Theme.of(context).textTheme.labelLarge ?? const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800));

  static TextStyle button(BuildContext context) =>
      (Theme.of(context).textTheme.labelLarge ?? const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800));
}
