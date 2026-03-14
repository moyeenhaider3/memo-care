import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

/// Vertical dotted timeline connector between reminder items.
///
/// Renders a column of small circles (4px) spaced 8px apart.
/// Active/current segments use accent colour, inactive grey.
class TimelineConnector extends StatelessWidget {
  const TimelineConnector({
    this.height = 32,
    this.isActive = false,
    super.key,
  });

  /// Height of the connector.
  final double height;

  /// Whether this segment is active (accent) or inactive (grey).
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.accent : AppColors.skippedGrey;
    final dotCount = (height / 12).floor(); // 4px dot + 8px space

    return SizedBox(
      height: height,
      width: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          dotCount,
          (_) => Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
