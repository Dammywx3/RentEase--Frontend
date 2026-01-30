import 'package:flutter/material.dart';

class AppColors {
  // Brand palette (from your logo)
  static const navy = Color(0xFF1B3174);
  static const brandBlue = Color(0xFF3D75BF);
  static const brandBlueSoft = Color(0xFF7DB7E9);
  static const brandGreen = Color(0xFF54953C);
  static const brandOrange = Color(0xFFDB8945);

  // Light surfaces
  static const lightBg = Color(0xFFF4F6FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFEFF4FF);

  // Dark surfaces (match your dark logo vibe)
  static const darkBg = Color(0xFF0B1020);
  static const darkSurface = Color(0xFF121A33);
  static const darkSurface2 = Color(0xFF182147);

  // Text
  static const textDark = Color(0xFF0F172A);
  static const textLight = Color(0xFFF8FAFC);
  static const textMutedLight = Color(0xFFCBD5E1);
  static const textMutedDark = Color(0xFF64748B);

  // Semantics
  static const success = brandGreen;
  static const warning = brandOrange;
  static const danger = Color(0xFFEF4444);
  static const info = brandBlue;

  static const dividerLight = Color(0xFFE2E8F0);
  static const dividerDark = Color(0xFF24325B);

  static Color withAlpha(Color c, int a) => c.withAlpha(a);
}
