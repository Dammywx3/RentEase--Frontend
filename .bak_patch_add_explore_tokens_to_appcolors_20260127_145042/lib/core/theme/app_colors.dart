import 'package:flutter/material.dart';

/// HomeStead brand + UI palette
class AppColors {
  AppColors._();

  // === Brand ===
  static const brandBlue = Color(0xFF1E4E8C); // deep, premium blue
  static const brandGreen = Color(0xFF2BB673); // clean green accent

  /// Subtle background tint used in your mocks (light lavender/ice)
  static const mist = Color(0xFFF2F0FA);

  // === Light surfaces ===
  static const lightBg = Color(0xFFF6F5FB); // very soft
  static const lightSurface = Colors.white;
  static const lightSurface2 = Color(0xFFF7F7FF); // for elevated cards
  static const lightBorder = Color(0xFFE6E3F2);

  // === Dark surfaces ===
  static const darkBg = Color(0xFF0B1020);
  static const darkSurface = Color(0xFF121A2E);
  static const darkSurface2 = Color(0xFF17213A);
  static const darkBorder = Color(0xFF223055);

  // === Text ===
  static const textDark = Color(0xFF0F172A); // slate 900
  static const textDark2 = Color(0xFF334155); // slate 600
  static const textLight = Color(0xFFF1F5F9); // slate 100
  static const textLight2 = Color(0xFFB7C2D3); // muted light

  // === Status ===
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // === Common ===
  static const transparent = Colors.transparent;

  // For gradients (buttons / highlight chips)
  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [brandBlue, brandGreen],
  );

  // Soft overlay used for icons, chips, and subtle sections
  static Color lightOverlay([double a = 0.10]) =>
      Colors.black.withValues(alpha: a);
  static Color darkOverlay([double a = 0.10]) =>
      Colors.white.withValues(alpha: a);
  static const dividerLight = Color(0xFFE6E8EF);
  static const dividerDark = Color(0xFF2A2F3A);
  static const brandBlueSoft = Color(0xFF2E5E9A);
  static const textMutedLight = Color(0xFF6F7785);
  static const textMutedDark = Color(0xFFA0A7B3);
  static const navy = Color(0xFF0D1B2A);
  static const brandOrange = Color(0xFFF59E0B);
}
