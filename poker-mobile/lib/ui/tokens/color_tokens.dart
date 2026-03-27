// Poker Sharp — Foundation Color Tokens

import 'dart:ui';

abstract final class AppColors {
  // Core
  static const black = Color(0xFF05070A);
  static const white = Color(0xFFF7FAFC);

  // Graphite scale
  static const graphite900 = Color(0xFF0A0F14);
  static const graphite850 = Color(0xFF111821);
  static const graphite800 = Color(0xFF16202B);
  static const graphite700 = Color(0xFF203040);

  // Steel scale
  static const steel500 = Color(0xFF536579);
  static const steel300 = Color(0xFF91A1B3);
  static const steel200 = Color(0xFFAAB8C6);
  static const steel100 = Color(0xFFC7D2DD);

  // Accent colors
  static const cyan500 = Color(0xFF35D9FF);
  static const cyan400 = Color(0xFF5FE4FF);
  static const cyan300 = Color(0xFF8CEEFF);

  static const lime500 = Color(0xFFA7FF3C);
  static const lime400 = Color(0xFFBEFF67);

  static const amber500 = Color(0xFFFFBF3C);
  static const amber400 = Color(0xFFFFD36B);

  static const red500 = Color(0xFFFF5A5F);
  static const red400 = Color(0xFFFF7C81);

  static const violet500 = Color(0xFF8A7DFF);
  static const teal500 = Color(0xFF33D1C6);

  // Overlay
  static const overlay70 = Color(0xB3000000);
  static const overlay50 = Color(0x80000000);
  static const overlay30 = Color(0x4D000000);

  // Effect colors
  static const glowPrimary = Color(0x6635D9FF);
  static const glowWarning = Color(0x66FFBF3C);
  static const glowError = Color(0x66FF5A5F);
  static const ringShadow = Color(0x33000000);
  static const gridLine = Color(0x14C7D2DD);
  static const scanLine = Color(0x145FE4FF);
}
