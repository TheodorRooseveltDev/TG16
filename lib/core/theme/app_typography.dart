import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Font Families
  static const String fontPrimary = 'Inter';
  static const String fontDisplay = 'Cinzel';

  // ════════════════════════════════════════════════════════════
  // DISPLAY STYLES (Hero sections, large titles)
  // ════════════════════════════════════════════════════════════
  static TextStyle get displayLarge => GoogleFonts.cinzel(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 6.0,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.cinzel(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 4.0,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.cinzel(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.0,
        color: AppColors.textPrimary,
      );

  // ════════════════════════════════════════════════════════════
  // HEADINGS
  // ════════════════════════════════════════════════════════════
  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ════════════════════════════════════════════════════════════
  // BODY
  // ════════════════════════════════════════════════════════════
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  // ════════════════════════════════════════════════════════════
  // LABELS & BUTTONS
  // ════════════════════════════════════════════════════════════
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  // ════════════════════════════════════════════════════════════
  // CAPTION
  // ════════════════════════════════════════════════════════════
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // ════════════════════════════════════════════════════════════
  // NAVIGATION
  // ════════════════════════════════════════════════════════════
  static TextStyle get navActive => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get navInactive => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      );

  // ════════════════════════════════════════════════════════════
  // TAGS
  // ════════════════════════════════════════════════════════════
  static TextStyle get tag => GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.textPrimary,
      );

  // ════════════════════════════════════════════════════════════
  // BUTTON STYLES
  // ════════════════════════════════════════════════════════════
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
