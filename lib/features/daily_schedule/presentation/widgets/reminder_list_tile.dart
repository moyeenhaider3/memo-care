import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/status_badge.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// A single reminder row in the daily schedule list (VIEW-01).
///
/// Shows time, medicine name, dosage, and [StatusBadge].
/// Tappable to navigate to chain context (wired in 07-05).
///
/// Touch target >= 56 dp via [ConstrainedBox].
class ReminderListTile extends StatelessWidget {
  const ReminderListTile({
    required this.reminder,
    this.confirmationStatus,
    super.key,
  });

  /// The reminder to display.
  final Reminder reminder;

  /// `null` means no terminal confirmation yet.
  final ConfirmationState? confirmationStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat.jm(); // e.g. "1:30 PM"
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
          // Navigate to chain context — route added in 07-05.
          unawaited(
            context.push(
              '/reminder/${reminder.id}/chain',
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: [
                // Time column
                SizedBox(
                  width: 80,
                  child: Text(
                    timeText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Medicine name + dosage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        reminder.medicineName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (reminder.dosage != null)
                        Text(
                          reminder.dosage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),

                // Status badge
                StatusBadge(
                  status: confirmationStatus,
                  isMissed: isMissed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    if (confirmationStatus == ConfirmationState.done) {
      return 'done';
    }
    if (confirmationStatus == ConfirmationState.skipped) {
      return 'skipped';
    }
    if (_isMissed) return 'missed';
    return 'pending';
  }
}
