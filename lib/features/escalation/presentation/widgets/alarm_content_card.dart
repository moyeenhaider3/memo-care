import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_shadows.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/escalation/presentation/widgets/step_indicator.dart';

/// White rounded card showing medicine details in the alarm UI.
class AlarmContentCard extends StatelessWidget {
  const AlarmContentCard({
    required this.medicineName,
    required this.dosage,
    this.instructions,
    this.warningText,
    this.chainStep,
    this.chainTotal,
    super.key,
  });

  final String medicineName;
  final String dosage;
  final String? instructions;
  final String? warningText;
  final int? chainStep;
  final int? chainTotal;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Alarm: $medicineName, $dosage',
      sortKey: const OrdinalSortKey(1),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppShadows.elevated,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Medicine icon (decorative)
            ExcludeSemantics(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              medicineName,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              dosage,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (instructions != null) ...[
              const SizedBox(height: 8),
              Text(
                instructions!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (warningText != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warningText!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (chainStep != null && chainTotal != null) ...[
              const SizedBox(height: 16),
              StepIndicator(
                current: chainStep!,
                total: chainTotal!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
