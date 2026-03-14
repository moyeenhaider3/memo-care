import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

/// Compact points display shown in the AppBar area.
/// Shows star icon + total points count.
class PointsDisplay extends StatelessWidget {
  const PointsDisplay({required this.points, super.key});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: KidsColors.warmYellow.withAlpha(50),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: KidsColors.warmYellow.withAlpha(100),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars_rounded,
            color: KidsColors.warmYellow,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$points pts',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: KidsColors.warmYellow.withAlpha(220),
            ),
          ),
        ],
      ),
    );
  }
}
