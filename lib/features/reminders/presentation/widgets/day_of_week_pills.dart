import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Row of 7 circular day-of-week toggle pills.
class DayOfWeekPills extends StatelessWidget {
  const DayOfWeekPills({
    required this.selectedDays,
    required this.onToggle,
    super.key,
  });

  /// Set of selected day indices (0=Mon, 6=Sun).
  final Set<int> selectedDays;
  final ValueChanged<int> onToggle;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  bool get _everyDay => selectedDays.length == 7;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Every Day" toggle
          GestureDetector(
            onTap: () {
              if (_everyDay) {
                // Deselect all
                for (var i = 0; i < 7; i++) {
                  if (selectedDays.contains(i)) onToggle(i);
                }
              } else {
                // Select all
                for (var i = 0; i < 7; i++) {
                  if (!selectedDays.contains(i)) onToggle(i);
                }
              }
            },
            child: Row(
              children: [
                Icon(
                  _everyDay
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: _everyDay ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Every Day',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final selected = selectedDays.contains(i);
              return GestureDetector(
                onTap: () => onToggle(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _labels[i],
                      style: AppTypography.labelLarge.copyWith(
                        color: selected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
