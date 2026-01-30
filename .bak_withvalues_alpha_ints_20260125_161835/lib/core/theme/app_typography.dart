import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme light = const TextTheme(
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 16, height: 1.35),
    bodyMedium: TextStyle(fontSize: 14, height: 1.35),
    bodySmall: TextStyle(fontSize: 12, height: 1.35),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );

  static TextTheme dark = light;
}
