import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ════════════════════════════════════════════════════════════
  // BACKGROUNDS
  // ════════════════════════════════════════════════════════════
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);
  static const Color backgroundTertiary = Color(0xFF242424);
  static const Color backgroundCard = Color(0xFF1E1E1E);
  static const Color backgroundInput = Color(0xFF2A2A2A);

  // ════════════════════════════════════════════════════════════
  // PRIMARY ACCENT - CYAN (This is the ONLY accent color)
  // ════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF00D4E5);
  static const Color primaryLight = Color(0xFF33DFED);
  static const Color primaryDark = Color(0xFF00B8C7);
  static const Color primaryGlow = Color(0x4D00D4E5);
  static const Color primarySubtle = Color(0x1A00D4E5);

  // ════════════════════════════════════════════════════════════
  // TEXT
  // ════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textPlaceholder = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF4D4D4D);

  // ════════════════════════════════════════════════════════════
  // SILVER/PLATINUM METALLIC (Luxury theme - realistic metal)
  // ════════════════════════════════════════════════════════════
  static const Color silverHighlight = Color(0xFFFFFFFF);  // Brightest highlight
  static const Color silverLight = Color(0xFFF0F0F0);      // Light silver
  static const Color silver = Color(0xFFD8D8D8);           // Main silver
  static const Color silverMedium = Color(0xFFB8B8B8);     // Medium tone
  static const Color platinum = Color(0xFFE0E0E0);         // Platinum shine
  static const Color silverDark = Color(0xFF909090);       // Dark silver edge
  static const Color silverDeep = Color(0xFF707070);       // Deepest shadow
  static const Color silverGlow = Color(0x66D8D8D8);       // Glow effect
  
  // Premium metallic gradient colors (for that polished look)
  static const List<Color> silverMetallicGradient = [
    Color(0xFF909090),  // Dark edge
    Color(0xFFB8B8B8),  // Medium
    Color(0xFFE8E8E8),  // Light
    Color(0xFFFFFFFF),  // Bright center highlight
    Color(0xFFE8E8E8),  // Light
    Color(0xFFB8B8B8),  // Medium
    Color(0xFF909090),  // Dark edge
  ];

  // ════════════════════════════════════════════════════════════
  // BORDERS & DIVIDERS
  // ════════════════════════════════════════════════════════════
  static const Color border = Color(0xFF333333);
  static const Color borderLight = Color(0xFF404040);
  static const Color borderButton = Color(0xFF4D4D4D);
  static const Color borderSilver = Color(0xFF707070);
  static const Color divider = Color(0xFF2A2A2A);

  // ════════════════════════════════════════════════════════════
  // SEMANTIC COLORS (for tags/badges only)
  // ════════════════════════════════════════════════════════════
  static const Color tagNew = Color(0xFFEF4444);
  static const Color tagHot = Color(0xFFF97316);
  static const Color tagExclusive = Color(0xFF22C55E);
  static const Color tagFeatured = Color(0xFF00D4E5);
}
