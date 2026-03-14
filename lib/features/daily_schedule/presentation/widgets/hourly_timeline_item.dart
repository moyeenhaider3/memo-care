import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/status_badge.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Hourly timeline row: time label left, colored border strip,
/// content card right.
class HourlyTimelineItem extends StatelessWidget {
  const HourlyTimelineItem({required this.reminder, super.key});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    final timeText = reminder.scheduledAt != null
        ? timeFormat.format(reminder.scheduledAt!.toLocal())
        : '--:--';
    final isMissed = _isMissed(reminder);
    final borderColor = isMissed ? AppColors.danger : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time label (left)
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  timeText,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // Colored border strip (4px)
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content card (right)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          if (reminder.chainId > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.link,
                                    size: 14,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Chain linked',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    StatusBadge(status: null, isMissed: isMissed),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isMissed(Reminder r) {
    final scheduledAt = r.scheduledAt;
    if (scheduledAt == null) return false;
    return scheduledAt.isBefore(DateTime.now().toUtc());
  }
}
