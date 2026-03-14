import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Fasting-mode toggle tile with gold accent moon icon.
class FastingToggleTile extends StatelessWidget {
  const FastingToggleTile({
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.accentGold.withAlpha(26)
              : AppColors.border.withAlpha(40),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.nightlight_round,
          color: enabled ? AppColors.accentGold : AppColors.textSecondary,
          size: 22,
        ),
      ),
      title: Text(
        'Ramadan Fasting Mode',
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        enabled
            ? 'Reminders adjusted for fasting hours'
            : 'Adjust reminders around fasting hours',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      value: enabled,
      onChanged: onChanged,
      activeThumbColor: AppColors.accentGold,
    );
  }
}
