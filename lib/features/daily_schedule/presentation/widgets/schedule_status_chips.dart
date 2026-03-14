import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/daily_schedule/application/full_schedule_providers.dart';

/// Horizontal row of 3 status chips: Done, Pending, Missed.
class ScheduleStatusChips extends StatelessWidget {
  const ScheduleStatusChips({required this.stats, super.key});

  final ScheduleStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _StatusChip(
            label: '${stats.done} Done',
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: '${stats.pending} Pending',
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: '${stats.missed} Missed',
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(color: color),
        ),
      ),
    );
  }
}
