import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Step indicator showing chain position with dots.
///
/// Current step: accent, completed: success, future: grey outline.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    required this.current,
    required this.total,
    super.key,
  });

  /// 1-based current step index.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (i) {
            final step = i + 1;
            final Color color;
            final bool filled;

            if (step < current) {
              color = AppColors.success;
              filled = true;
            } else if (step == current) {
              color = AppColors.accent;
              filled = true;
            } else {
              color = AppColors.skippedGrey;
              filled = false;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: filled ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          'Step $current of $total',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
