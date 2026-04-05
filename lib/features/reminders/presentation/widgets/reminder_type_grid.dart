import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Reminder type enumeration.
enum ReminderType {
  medicine(Icons.medication, 'Medicine', AppColors.accent),
  meal(Icons.restaurant, 'Meal', AppColors.success),
  activity(Icons.directions_run, 'Activity', Color(0xFFEA580C)),
  call(Icons.phone, 'Call', Color(0xFF8B5CF6)),
  exercise(Icons.fitness_center, 'Exercise', AppColors.accentTeal),
  custom(Icons.edit, 'Custom', AppColors.skippedGrey)
  ;

  const ReminderType(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
}

/// 2x3 grid of reminder type selection cards.
class ReminderTypeGrid extends StatelessWidget {
  const ReminderTypeGrid({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ReminderType? selected;
  final ValueChanged<ReminderType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.cardGap,
        crossAxisSpacing: AppSpacing.cardGap,
        children: ReminderType.values.map((type) {
          final isSelected = type == selected;
          return GestureDetector(
            onTap: () => onSelected(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? type.color.withAlpha(20) : AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(
                  color: isSelected ? type.color : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: type.color.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      type.icon,
                      color: type.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? type.color : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
