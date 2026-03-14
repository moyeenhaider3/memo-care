/// Component-size and spacing tokens from Stitch design system.
///
/// See PLANNING_RULES.md Rule 2 for authoritative values.
abstract final class AppSpacing {
  // ── Border radii ──────────────────────────────────────
  /// Cards, sheets.
  static const double cardRadius = 16;

  /// Primary / secondary buttons.
  static const double buttonRadius = 14;

  /// Chips, tags, pills.
  static const double chipRadius = 999;

  /// Text fields, dropdowns.
  static const double inputRadius = 12;

  // ── Heights ───────────────────────────────────────────
  /// Standard button height.
  static const double buttonHeight = 56;

  /// Full-screen alert buttons (DONE / SNOOZE).
  static const double alertButtonHeight = 88;

  /// Kids mode oversized buttons.
  static const double kidsButtonHeight = 64;

  /// Minimum touch target (WCAG AA).
  static const double minTouchTarget = 44;

  // ── FAB ───────────────────────────────────────────────
  /// Floating action button diameter.
  static const double fabSize = 56;

  // ── Navigation ────────────────────────────────────────
  /// Bottom NavigationBar height.
  static const double navBarHeight = 72;

  // ── Common padding / margin values ────────────────────
  /// Horizontal screen padding.
  static const double screenHorizontal = 16;

  /// Vertical spacing between cards.
  static const double cardGap = 12;

  /// Section spacing.
  static const double sectionGap = 24;

  /// Icon size inside bottom nav.
  static const double navIconSize = 24;
}
