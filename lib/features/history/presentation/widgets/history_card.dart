import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_shadows.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/history/domain/models/history_entry.dart';

/// History card with colored status dot (HIST-01, 10-05).
///
/// Shows medicine name, scheduled time, confirmation time, dosage,
/// and a colored status dot on the left.
class HistoryCard extends StatelessWidget {
  const HistoryCard({
    required this.entry,
    super.key,
  });

  final HistoryEntry entry;

  Color get _statusColor => switch (entry.status) {
    ConfirmationState.done => AppColors.success,
    ConfirmationState.skipped => AppColors.skippedGrey,
    ConfirmationState.snoozed => AppColors.warning,
    null => AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    final timeText = timeFormat.format(entry.scheduledAt.toLocal());
    final confirmedText = entry.confirmedAt != null
        ? 'Confirmed ${timeFormat.format(entry.confirmedAt!.toLocal())}'
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: AppShadows.card,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Colored status dot strip
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.cardRadius),
                  bottomLeft: Radius.circular(AppSpacing.cardRadius),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Status dot
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.medicineName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$timeText'
                      '${entry.dosage != null ? " · ${entry.dosage}" : ""}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (confirmedText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        confirmedText,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Status label
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(
                  entry.statusLabel,
                  style: AppTypography.labelMedium.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
