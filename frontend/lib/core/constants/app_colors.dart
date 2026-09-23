import 'package:flutter/material.dart';

/// Design tokens for MediRoutine's editorial, high-end split-screen aesthetic.
class AppColors {
  AppColors._();

  // ----------------------------------------------------
  // BRAND PANEL (Left / Visual Area)
  // ----------------------------------------------------
  static const Color brandBackground = Color(0xFF0C101D);
  static const Color brandSurface = Color(0xFF13192B);
  static const Color brandSurfaceElevated = Color(0xFF1A223A);
  static const Color brandBorder = Color(0x1FFFFFFF);
  static const Color brandPrimary = Color(0xFF7C3AED);
  static const Color brandIndigo = Color(0xFF6366F1);
  static const Color brandCyan = Color(0xFF38BDF8);
  static const Color brandLavender = Color(0xFFA78BFA);

  // Aliases for Shared Widgets
  static const Color background = brandBackground;
  static const Color backgroundSecondary = brandSurface;
  static const Color surface = brandSurface;
  static const Color surfaceGlass = Color(0xCC13192B);
  static const Color accentCyan = brandCyan;
  static const Color accentLavender = brandLavender;
  static const Color accentIndigo = brandIndigo;

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandSculptureGradient = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ----------------------------------------------------
  // AUTH SURFACE (Right / Form Area - Clean, Crisp Light Surface)
  // ----------------------------------------------------
  static const Color surfaceBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceCard = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceInput = Color(0xFFF8FAFC); // Off-white input fill
  static const Color surfaceElevated = Color(0xFFF1F5F9); // Slate 100

  // Neutral & Slate Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textDisabled = Color(0xFFCBD5E1); // Slate 300

  // Form Borders & Outlines
  static const Color borderSubtle = Color(0xFFE2E8F0); // Slate 200
  static const Color borderMedium = Color(0xFFCBD5E1); // Slate 300
  static const Color borderFocus = Color(0xFF7C3AED); // Royal Violet
  static const Color borderFocusGlow = Color(0x2E7C3AED);

  // Primary CTA Button
  static const Color primary = Color(0xFF6D28D9); // Violet 700
  static const Color primaryHover = Color(0xFF5B21B6); // Violet 800
  static const Color primaryLight = Color(0xFF8B5CF6);

  // Semantic Feedback
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorBackground = Color(0x14EF4444);
  static const Color errorBorder = Color(0x66EF4444);

  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successBackground = Color(0x1410B981);

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningBackground = Color(0x14F59E0B);

  // Social Buttons
  static const Color socialButtonBg = Color(0xFFFFFFFF);
  static const Color socialButtonBorder = Color(0xFFE2E8F0);
  static const Color socialButtonHover = Color(0xFFF8FAFC);
}
