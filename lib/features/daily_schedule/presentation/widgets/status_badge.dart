import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_theme.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';

/// Status indicator chip for a reminder (VIEW-01).
///
/// Renders a colored badge:
/// - Green "Done" for confirmed
/// - Orange "Pending" for upcoming
/// - Red "Missed" for past + unconfirmed
/// - Grey "Skipped" for explicitly skipped
///
/// `status` is the confirmation state (null means no terminal
/// confirmation). `isMissed` is true if scheduledAt < now AND no
/// terminal confirmation.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.status,
    this.isMissed = false,
    super.key,
  });

  /// The confirmation state from the database (null = pending).
  final ConfirmationState? status;

  /// Whether this reminder is past-due with no confirmation.
  final bool isMissed;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _config;

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color, IconData) get _config {
    if (status == ConfirmationState.done) {
      return ('Done', AppColors.doneGreen, Icons.check_circle);
    }
    if (status == ConfirmationState.skipped) {
      return (
        'Skipped',
        AppColors.skippedGrey,
        Icons.cancel,
      );
    }
    if (isMissed) {
      return (
        'Missed',
        AppColors.missedRed,
        Icons.warning_amber,
      );
    }
    return (
      'Pending',
      AppColors.pendingOrange,
      Icons.schedule,
    );
  }
}
