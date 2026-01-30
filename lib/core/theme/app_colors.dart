import 'package:flutter/material.dart';

/// HomeStead brand + UI palette
class AppColors {
  AppColors._();

  // === Brand ===
  static const brandBlue = Color(0xFF1E4E8C); // deep, premium blue
  static const brandGreen = Color(0xFF2BB673); // clean green accent
  static const brandBlueSoft = Color(
    0xFF2E5E9A,
  ); // used across Explore/nav vibe

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
  static const textMutedLight = Color(0xFF6F7785);
  static const textMutedDark = Color(0xFFA0A7B3);

  // === Status ===
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // === Common ===
  static const transparent = Colors.transparent;
  static const navy = Color(0xFF0D1B2A);
  static const brandOrange = Color(0xFFF59E0B);

  static const dividerLight = Color(0xFFE6E8EF);
  static const dividerDark = Color(0xFF2A2F3A);

  // For gradients (buttons / highlight chips)
  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [brandBlue, brandGreen],
  );

  /// Soft overlay used for icons, chips, and subtle sections
  static Color lightOverlay([double a = 0.10]) =>
      Colors.black.withValues(alpha: a);
  static Color darkOverlay([double a = 0.10]) =>
      Colors.white.withValues(alpha: a);

  // === Theme-aware helpers (use these from screens instead of light*/dark* tokens) ===
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) => isDark(context) ? darkBg : lightBg;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color surface2(BuildContext context) =>
      isDark(context) ? darkSurface2 : lightSurface2;

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color divider(BuildContext context) =>
      isDark(context) ? dividerDark : dividerLight;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? textLight : textDark;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? textLight2 : textDark2;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? textMutedDark : textMutedLight;

  /// Overlay that flips automatically (dark -> white overlay, light -> black overlay)
  static Color overlay(BuildContext context, [double a = 0.10]) =>
      isDark(context) ? darkOverlay(a) : lightOverlay(a);

  /// Common page gradient (matches your Explore vibe)
  static LinearGradient pageBgGradient(BuildContext context) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark(context) ? [darkBg, darkSurface] : [lightBg, mist],
      );

  // ===========================================================================
  // Tenant / Mock Legacy Tokens (to remove hardcoded hex from tenant screens)
  // ===========================================================================

  static const tenantBgTop = Color(0xFFF1F3F8);
  static const tenantBgBottom = Color(0xFFE9ECF4);
  static const tenantPanel = Color(0xFFCFDBEA);
  static const tenantBorderMuted = Color(0xFFB9C1CF);
  static const tenantDividerSoft = Color(0xFFBFD0DA);
  static const tenantMutedInk = Color(0xFF4E5A6D);
  static const tenantIconMuted = Color(0xFF5C6677);
  static const tenantPrimaryDeep = Color(0xFF2D5E9C);
  static const tenantInk = Color(0xFF1E2A3A);
  static const tenantActionBlue = Color(0xFF6E87B8);
  static const tenantActionGreen = Color(0xFF6E8E7A);
  static const tenantDangerSoft = Color(0xFFB54A4A);
  static const tenantDangerDeep = Color(0xFFB24A5A);
  static const tenantGray600 = Color(0xFF6B6B6B);

  static const tenantIconBgBlue = Color(0xFFCFDBEA);
  static const tenantIconBgGreen = Color(0xFFD7E6DD);
  static const tenantIconBgSand = Color(0xFFE7E3D1);
  static const tenantIconBgGray = Color(0xFFD9D9D9);

  // === Explore demo tokens (already used) ===
  static const brandGreenDeep = Color(0xFF3C7C5A);
  static const dotInactive = Color(0xFFB8C0CF);

  static const demoCardGradientA = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB9C7DD), Color(0xFF879BB8)],
  );

  static const demoCardGradientB = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC8D3E6), Color(0xFF93A8C6)],
  );

  // ===========================================================================
  // Compatibility aliases (so old screens compile)
  //
  // Your UI files expect these names. We map them to your real palette so you
  // don't have to refactor every screen right now.
  // ===========================================================================

  static const Color white = Colors.white;
  static const Color black = Colors.black;

  /// Some screens use `mutedMid` for secondary text/labels.
  static const Color mutedMid = textMutedDark;

  /// Status aliases used by older code.
  static const Color dangerRed = danger;
  static const Color successGreen = success;
  static const Color warningAmber = warning;

  /// Generic border token older screens used.
  static const Color borderLight = lightBorder;
  static const Color borderDark = darkBorder;
}
