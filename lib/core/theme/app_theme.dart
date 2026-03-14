import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart' show AppColors;

// Re-export new design-system tokens so existing
// `import 'app_theme.dart'` statements pick them up.
export 'app_colors.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

/// Legacy WCAG AAA colour aliases.
///
/// All properties are **@Deprecated** and forward to the new
/// [AppColors] constants from `app_colors.dart`. Existing screens
/// continue to compile while each is migrated in plans 10-02 → 10-08.
@Deprecated('Import app_colors.dart and use AppColors directly')
abstract final class LegacyAppColors {
  // ── Primary palette ───────────────────────────────────
  @Deprecated('Use AppColors.primary from app_colors.dart')
  static const Color primary = Color(0xFF004D40);

  @Deprecated('Use AppColors.onPrimary from app_colors.dart')
  static const Color onPrimary = Colors.white;

  // ── Status badge colours ──────────────────────────────
  @Deprecated('Use AppColors.success from app_colors.dart')
  static const Color doneGreen = Color(0xFF1B5E20);

  @Deprecated('Use AppColors.danger from app_colors.dart')
  static const Color missedRed = Color(0xFFB71C1C);

  @Deprecated('Use AppColors.warning from app_colors.dart')
  static const Color pendingOrange = Color(0xFFE65100);

  @Deprecated('Use AppColors.skippedGrey from app_colors.dart')
  static const Color skippedGrey = Color(0xFF424242);

  // ── Action button colours ─────────────────────────────
  @Deprecated('Use AppColors.success from app_colors.dart')
  static const Color doneButtonBackground = Color(0xFF1B5E20);

  @Deprecated('Use AppColors.danger from app_colors.dart')
  static const Color skipButtonForeground = Color(0xFFB71C1C);

  @Deprecated('Use AppColors.warning from app_colors.dart')
  static const Color warningAmber = Color(0xFFE65100);

  // ── Banner / SnackBar backgrounds (white text) ────────
  @Deprecated('Use AppColors.danger from app_colors.dart')
  static const Color warningBackground = Color(0xFF7B1F00);

  @Deprecated('Use AppColors.danger from app_colors.dart')
  static const Color warningBackgroundDark = Color(0xFF5D1700);

  @Deprecated('Use AppColors.danger from app_colors.dart')
  static const Color errorBackground = Color(0xFF7F0000);
}
