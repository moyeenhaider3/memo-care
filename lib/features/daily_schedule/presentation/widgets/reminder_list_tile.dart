import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/status_badge.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// A single reminder row in the daily schedule list.
///
/// Shows colored left border strip (4px), time, medicine name,
/// dosage, and pill-shaped [StatusBadge].
/// Touch target >= 56 dp via [ConstrainedBox].
class ReminderListTile extends StatelessWidget {
  const ReminderListTile({
    required this.reminder,
    this.confirmationStatus,
    super.key,
  });

  final Reminder reminder;
  final ConfirmationState? confirmationStatus;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    final timeText = reminder.scheduledAt != null
        ? timeFormat.format(reminder.scheduledAt!.toLocal())
        : '--:--';
    final isMissed = _isMissed;

    return Semantics(
      label:
          '${reminder.medicineName}, '
          '${reminder.dosage ?? "no dosage"}, '
          'scheduled at $timeText, '
          'status: $_statusLabel',
      button: true,
      child: InkWell(
        onTap: () {
          unawaited(context.push('/reminder/${reminder.id}/chain'));
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Colored left border strip (4px)
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: _borderColor(isMissed),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Time column (14pt caption)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 58),
                    child: Text(
                      timeText,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Medicine name + dosage (17pt body)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          reminder.medicineName,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (reminder.dosage != null)
                          Text(
                            reminder.dosage!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Status badge (pill)
                  StatusBadge(
                    status: confirmationStatus,
                    isMissed: isMissed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _borderColor(bool isMissed) {
    if (confirmationStatus == ConfirmationState.done) return AppColors.success;
    if (confirmationStatus == ConfirmationState.skipped) {
      return AppColors.skippedGrey;
    }
    if (isMissed) return AppColors.danger;
    return AppColors.warning;
  }

  bool get _isMissed {
    if (confirmationStatus == ConfirmationState.done ||
        confirmationStatus == ConfirmationState.skipped) {
      return false;
    }
    final scheduledAt = reminder.scheduledAt;
    if (scheduledAt == null) return false;
    return scheduledAt.isBefore(DateTime.now().toUtc());
  }

  String get _statusLabel {
    if (confirmationStatus == ConfirmationState.done) return 'done';
    if (confirmationStatus == ConfirmationState.skipped) return 'skipped';
    if (_isMissed) return 'missed';
    return 'pending';
  }
}
