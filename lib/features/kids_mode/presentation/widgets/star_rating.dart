import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

/// Row of 5 stars showing daily rating (filled based on [rating] 0-5).
class StarRating extends StatelessWidget {
  const StarRating({required this.rating, super.key});

  /// Number of filled stars (0-5).
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final isFilled = i < rating;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            key: ValueKey('$i-$isFilled'),
            color: isFilled ? KidsColors.warmYellow : const Color(0xFFCBD5E1),
            size: 26,
          ),
        );
      }),
    );
  }
}
