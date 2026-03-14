import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Small pill badge showing "Day X of Y" for course-based templates.
class CourseTrackerBadge extends StatelessWidget {
  const CourseTrackerBadge({
    required this.currentDay,
    required this.totalDays,
    super.key,
  });

  final int currentDay;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(
        'Day $currentDay of $totalDays',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
