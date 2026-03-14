import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter-based text styles matching Stitch design tokens.
///
/// Rule 3: Follow design sizes exactly — no 18px minimum override.
/// Rule 11: Inter replaces Noto Sans globally.
abstract final class AppTypography {
  /// Display Large — 28pt Bold (H1).
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// Display Medium — 22pt SemiBold (H2).
  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// Title Large — 20pt SemiBold.
  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Title Medium — 17pt SemiBold.
  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Title Small — 15pt Medium.
  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// Body Large — 17pt Regular.
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body Medium — 15pt Regular.
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body Small — 14pt Regular.
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Label Large — 14pt SemiBold (buttons, nav labels).
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Label Medium — 13pt Medium (chips, tags).
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// Label Small — 11pt Regular (captions, timestamps).
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Alarm hero time — 64px Extra Bold.
  static TextStyle get alarmTime => GoogleFonts.inter(
    fontSize: 64,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  /// Hero medicine name — 32px Extra Bold.
  static TextStyle get heroMedicine => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  /// Returns a complete [TextTheme] built from the styles above.
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
