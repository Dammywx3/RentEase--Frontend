import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  /// Soft, premium shadows for cards.
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

  /// Dark mode should have tighter shadows + subtle border contrast.
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
