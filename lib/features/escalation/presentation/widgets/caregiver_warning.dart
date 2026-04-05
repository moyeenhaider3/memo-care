import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Warning text shown during escalation tier 2+.
class CaregiverWarning extends StatelessWidget {
  const CaregiverWarning({
    required this.minutesRemaining,
    super.key,
  });

  final int minutesRemaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.danger.withAlpha(80),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No response in $minutesRemaining min will '
              'notify your caregiver.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
