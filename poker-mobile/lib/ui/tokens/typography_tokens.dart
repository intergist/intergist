// Poker Sharp — Typography Tokens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  // Display
  static TextStyle get displayXL => GoogleFonts.inter(
        fontSize: 40,
        height: 44 / 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      );

  static TextStyle get displayL => GoogleFonts.inter(
        fontSize: 32,
        height: 36 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  // Headline
  static TextStyle get headlineL => GoogleFonts.inter(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  static TextStyle get headlineM => GoogleFonts.inter(
        fontSize: 20,
        height: 26 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  // Title
  static TextStyle get titleL => GoogleFonts.inter(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  static TextStyle get titleM => GoogleFonts.inter(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  // Body
  static TextStyle get bodyL => GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyM => GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );

  // Label
  static TextStyle get labelL => GoogleFonts.inter(
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get labelM => GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  // Monospace
  static TextStyle get monoL => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  static TextStyle get monoM => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  static TextStyle get monoS => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      );
}
