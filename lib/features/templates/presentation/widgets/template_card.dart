import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_shadows.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/templates/domain/models/template_pack.dart';

/// Template card for 2-column grid (120pt height).
///
/// Shows colored icon circle, template name, category tag pill.
class TemplateCard extends StatelessWidget {
  const TemplateCard({
    required this.pack,
    required this.onTap,
    super.key,
  });

  final TemplatePack pack;
  final VoidCallback onTap;

  Color get _categoryColor => switch (pack.condition) {
    'diabetes' => AppColors.accent,
    'blood_pressure' => AppColors.danger,
    'heart' => AppColors.danger,
    'hydration' => AppColors.accentTeal,
    'wellness' || 'elderly_wellness' => AppColors.success,
    'eye_care' => const Color(0xFF8B5CF6),
    'school_morning' => AppColors.warning,
    _ => AppColors.textSecondary,
  };

  IconData get _categoryIcon => switch (pack.condition) {
    'diabetes' => Icons.bloodtype,
    'blood_pressure' => Icons.favorite,
    'heart' => Icons.monitor_heart,
    'hydration' => Icons.water_drop,
    'wellness' || 'elderly_wellness' => Icons.spa,
    'eye_care' => Icons.visibility,
    'school_morning' => Icons.school,
    _ => Icons.medical_services,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _categoryColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon,
                color: _categoryColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Expanded(
              child: Text(
                pack.name,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Category pip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _categoryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Text(
                pack.condition.replaceAll('_', ' '),
                style: AppTypography.labelSmall.copyWith(
                  color: _categoryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
