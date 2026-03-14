import 'package:flutter/material.dart';

/// Design-token color palette derived from Stitch UI designs.
///
/// All values match the Stitch HTML design files exactly.
/// See `.planning/PLANNING_RULES.md` Rule 2 for the authoritative list.
abstract final class AppColors {
  // ── Primary palette ───────────────────────────────────
  /// Deep Navy — headers, primary CTAs, icons.
  static const Color primary = Color(0xFF1A3C5B);

  /// Sky Blue — active states, links, progress indicators.
  static const Color accent = Color(0xFF4A90D9);

  /// On-primary (text/icon on primary surface).
  static const Color onPrimary = Colors.white;

  // ── Status colours ────────────────────────────────────
  /// Calm Green — done / confirmed states.
  static const Color success = Color(0xFF22C55E);

  /// Amber — snoozed, pending states.
  static const Color warning = Color(0xFFF59E0B);

  /// Soft Red — missed, escalation states.
  static const Color danger = Color(0xFFEF4444);

  // ── Surfaces ──────────────────────────────────────────
  /// Off-White app background.
  static const Color background = Color(0xFFF7F9FC);

  /// Card / sheet background.
  static const Color cardBg = Color(0xFFFFFFFF);

  /// Slate grey for skipped, disabled, secondary text.
  static const Color skippedGrey = Color(0xFF94A3B8);

  // ── Accent variants ───────────────────────────────────
  /// Gold — fasting toggles, Ramadan accents, reward badges.
  static const Color accentGold = Color(0xFFD4AF37);

  /// Teal — caregiver actions, NLP confirmation buttons.
  static const Color accentTeal = Color(0xFF0D9488);

  // ── Derived helpers ───────────────────────────────────
  /// Darker navy for AppBar / status bar contrast.
  static const Color primaryDark = Color(0xFF12283D);

  /// Light primary tint for selected list tiles, chip bg, etc.
  static const Color primaryLight = Color(0xFFE8EFF7);

  /// Surface variant for dividers and borders.
  static const Color border = Color(0xFFE2E8F0);

  /// Text on light backgrounds — near-black.
  static const Color textPrimary = Color(0xFF1E293B);

  /// Secondary text — muted.
  static const Color textSecondary = Color(0xFF64748B);
}

/// Kids Mode colour palette (Phase 11).
abstract final class KidsColors {
  static const Color primary = Color(0xFF7C3AED);
  static const Color warmYellow = Color(0xFFFBBF24);
  static const Color playfulGreen = Color(0xFF22C55E);
  static const Color coralPink = Color(0xFFFB7185);
  static const Color background = Color(0xFFFDFCFE);
}

/// Ramadan / Fasting Mode colour palette (Phase 11).
abstract final class RamadanColors {
  static const Color primaryGold = Color(0xFFF0A500);
  static const Color background = Color(0xFF0D1B2A);
  static const Color cardBg = Color(0xFF1A2E44);
  static const Color sehriBlue = Color(0xFF4A90E2);
  static const Color iftarGold = Color(0xFFF0A500);
}
