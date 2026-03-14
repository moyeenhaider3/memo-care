import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Row with a numeric dose input and a unit dropdown.
class DoseUnitFields extends StatelessWidget {
  const DoseUnitFields({
    required this.dose,
    required this.unit,
    required this.onDoseChanged,
    required this.onUnitChanged,
    super.key,
  });

  final String dose;
  final String unit;
  final ValueChanged<String> onDoseChanged;
  final ValueChanged<String> onUnitChanged;

  static const _units = [
    'mg',
    'ml',
    'tablets',
    'capsules',
    'drops',
    'puffs',
    'units',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: [
          // Dose number
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Dose',
                labelStyle: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              style: AppTypography.bodyLarge,
              controller: TextEditingController(text: dose)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: dose.length),
                ),
              onChanged: onDoseChanged,
            ),
          ),
          const SizedBox(width: 12),
          // Unit dropdown
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              initialValue: _units.contains(unit) ? unit : _units.first,
              decoration: InputDecoration(
                labelText: 'Unit',
                labelStyle: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              items: _units
                  .map(
                    (u) => DropdownMenuItem(value: u, child: Text(u)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onUnitChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
