import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Heading fonts
  static TextStyle get heading1 => GoogleFonts.cinzel(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: 0.5,
  );

  static TextStyle get heading2 => GoogleFonts.cinzel(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: 0.5,
  );

  static TextStyle get heading3 => GoogleFonts.cinzel(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: 0.5,
  );

  // Body fonts
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  // Card title fonts
  static TextStyle get cardTitle => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // Label fonts
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  // Planetary degrees (monospaced/tabular numeric)
  static TextStyle get planetaryDegrees => GoogleFonts.inconsolata(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );
}