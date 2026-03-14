import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Empty state widget for the schedule screen.
///
/// Shows when all reminders are complete or none exist.
class ScheduleEmptyState extends StatelessWidget {
  const ScheduleEmptyState({this.allComplete = false, super.key});

  /// True when all reminders are complete (vs. no reminders at all).
  final bool allComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            allComplete ? Icons.emoji_food_beverage : Icons.event_available,
            size: 72,
            color: AppColors.skippedGrey.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            allComplete
                ? 'Rest of the day is free!'
                : 'No reminders for today',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            allComplete
                ? "You've completed all your medications. Great job!"
                : 'Tap the + button to add your first reminder.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
