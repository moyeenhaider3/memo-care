import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Horizontal scrollable week selector strip.
///
/// Shows 7 day cells (Mon-Sun) for the selected week.
/// Arrows navigate between weeks.
class WeekSelectorStrip extends StatelessWidget {
  const WeekSelectorStrip({
    required this.weekStart,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    super.key,
  });

  /// Monday of the displayed week.
  final DateTime weekStart;

  /// Currently selected day (null = whole week).
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(
      7,
      (i) => weekStart.add(Duration(days: i)),
    );
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onPreviousWeek,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textSecondary,
            iconSize: 20,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) {
                final isSelected =
                    selectedDay != null &&
                    day.year == selectedDay!.year &&
                    day.month == selectedDay!.month &&
                    day.day == selectedDay!.day;
                final isToday =
                    day.year == today.year &&
                    day.month == today.month &&
                    day.day == today.day;

                return GestureDetector(
                  onTap: () => onDaySelected(day),
                  child: Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.cardRadius,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat.E().format(day).substring(0, 2),
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.day}',
                          style: AppTypography.labelLarge.copyWith(
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? AppColors.accent
                                : AppColors.textPrimary,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            onPressed: onNextWeek,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textSecondary,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
