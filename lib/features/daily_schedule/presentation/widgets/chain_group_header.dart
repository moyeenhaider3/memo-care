import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Header for a chain group in the schedule timeline.
class ChainGroupHeader extends StatelessWidget {
  const ChainGroupHeader({
    required this.chainName,
    this.completedCount = 0,
    this.totalCount = 0,
    super.key,
  });

  final String chainName;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.link, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            chainName,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Text(
            '$completedCount of $totalCount complete',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
