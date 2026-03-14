import 'package:flutter/material.dart';

/// Shadow definitions matching Stitch design system.
abstract final class AppShadows {
  /// Default card shadow — subtle elevation.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000), // ~8% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Elevated shadow — modals, FAB, sheets.
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1F000000), // ~12% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000), // ~4% black
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Bottom navigation bar shadow.
  static const List<BoxShadow> navBar = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, -2),
    ),
  ];
}
