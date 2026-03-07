import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/theme/app_theme.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/history/domain/models/history_entry.dart';

/// A single entry card in the medication history list (HIST-01).
///
/// Shows medicine name, dosage, scheduled date/time, status, and
/// confirmation timestamp.
/// Touch target >= 56 dp.
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    required this.entry,
    super.key,
  });

  /// The history entry to display.
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(); // "Mar 7, 2026"
    final timeFormat = DateFormat.jm(); // "1:30 PM"

    final dateText = dateFormat.format(entry.scheduledAt.toLocal());
    final timeText = timeFormat.format(entry.scheduledAt.toLocal());
    final confirmedText = entry.confirmedAt != null
        ? 'at ${timeFormat.format(entry.confirmedAt!.toLocal())}'
        : '';
    final statusLabel = entry.statusLabel;

    return Semantics(
      label:
          '${entry.medicineName}, '
          '${entry.dosage ?? ""}, '
          '$dateText at $timeText, '
          'status: $statusLabel'
          '${confirmedText.isNotEmpty ? ", confirmed $confirmedText" : ""}',
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medicine info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.medicineName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateText · $timeText'
                        '${entry.dosage != null ? " · ${entry.dosage}" : ""}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (confirmedText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Confirmed $confirmedText',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status chip
                _StatusChip(
                  status: entry.status,
                  label: statusLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.label,
  });

  final ConfirmationState? status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      ConfirmationState.done => (
        AppColors.doneGreen,
        Icons.check_circle,
      ),
      ConfirmationState.skipped => (
        AppColors.skippedGrey,
        Icons.cancel,
      ),
      ConfirmationState.snoozed => (
        AppColors.pendingOrange,
        Icons.snooze,
      ),
      null => (
        AppColors.missedRed,
        Icons.warning_amber,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
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
    );
  }
}
