import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Display settings section: text size slider, high contrast toggle,
/// dark mode toggle.
class DisplaySettingsSection extends StatelessWidget {
  const DisplaySettingsSection({
    required this.textScale,
    required this.highContrast,
    required this.darkMode,
    required this.onTextScaleChanged,
    required this.onHighContrastChanged,
    required this.onDarkModeChanged,
    super.key,
  });

  final double textScale;
  final bool highContrast;
  final bool darkMode;
  final ValueChanged<double> onTextScaleChanged;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Display'),

        // Text Size slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Text Size',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _sizeLabel,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              Slider(
                value: textScale,
                min: 0.8,
                max: 1.6,
                divisions: 4,
                label: _sizeLabel,
                onChanged: onTextScaleChanged,
              ),
            ],
          ),
        ),

        // High Contrast toggle
        SwitchListTile(
          title: Text(
            'High Contrast',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Increase contrast for better readability',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          value: highContrast,
          onChanged: onHighContrastChanged,
        ),

        // Dark Mode toggle
        SwitchListTile(
          title: Text(
            'Dark Mode',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Use dark theme (coming soon)',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          value: darkMode,
          onChanged: onDarkModeChanged,
        ),
      ],
    );
  }

  String get _sizeLabel {
    if (textScale <= 0.85) return 'Small';
    if (textScale <= 1.05) return 'Medium';
    if (textScale <= 1.25) return 'Large';
    return 'Extra Large';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
