import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';

/// Status indicator pill for a reminder.
///
/// Renders a coloured pill badge:
/// - Green "Done" for confirmed
/// - Amber "Pending" for upcoming
/// - Red "Missed" for past + unconfirmed
/// - Grey "Skipped" for explicitly skipped
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.status,
    this.isMissed = false,
    super.key,
  });

  final ConfirmationState? status;
  final bool isMissed;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _config;

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color, IconData) get _config {
    if (status == ConfirmationState.done) {
      return ('Done', AppColors.success, Icons.check_circle);
    }
    if (status == ConfirmationState.skipped) {
      return ('Skipped', AppColors.skippedGrey, Icons.cancel);
    }
    if (isMissed) {
      return ('Missed', AppColors.danger, Icons.warning_amber);
    }
    return ('Pending', AppColors.warning, Icons.schedule);
  }
}
