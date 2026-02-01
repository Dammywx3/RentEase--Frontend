import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color overlay(BuildContext context, [double a = 0.10]) =>
      isDark(context)
      ? Colors.white.withValues(alpha: a)
      : Colors.black.withValues(alpha: a);

  /// ✅ Theme-aware card shadow
  static List<BoxShadow> card(BuildContext context) =>
      isDark(context) ? cardDark : cardLight;

  static List<BoxShadow> lift(
    BuildContext context, {
    double blur = 18,
    double y = 10,
    double alpha = 0.08,
  }) {
    return [
      BoxShadow(
        blurRadius: blur,
        offset: Offset(0, y),
        color: overlay(context, alpha),
      ),
    ];
  }

  static List<BoxShadow> soft(
    BuildContext context, {
    double blur = 16,
    double y = 10,
    double alpha = 0.08,
  }) {
    return [
      BoxShadow(
        blurRadius: blur,
        offset: Offset(0, y),
        color: overlay(context, alpha),
      ),
    ];
  }

  static List<BoxShadow> cardLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> buttonLight = [
    BoxShadow(
      color: AppColors.brandBlue.withValues(alpha: 0.18),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> buttonDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 10),
    ),
  ];

  static const softLight = <BoxShadow>[
    BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Color(0x14000000)),
  ];
  static const softDark = <BoxShadow>[
    BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Color(0x33000000)),
  ];
}
