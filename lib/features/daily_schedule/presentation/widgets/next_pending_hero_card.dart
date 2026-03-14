import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_shadows.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_providers.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Navy hero card displaying the next pending reminder.
///
/// Uses AppColors.primary (navy) background with white text.
/// Two action buttons: DONE (green, 56px) and SNOOZE (amber outline, 56px).
class NextPendingHeroCard extends ConsumerWidget {
  const NextPendingHeroCard({
    required this.onDone,
    required this.onSnooze,
    super.key,
  });

  final void Function(Reminder reminder) onDone;
  final void Function(Reminder reminder) onSnooze;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(nextPendingReminderProvider);

    if (reminder == null) {
      return const _AllDoneCard();
    }

    return _PendingCard(
      reminder: reminder,
      onDone: () => onDone(reminder),
      onSnooze: () => onSnooze(reminder),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'All medications taken for today. Well done!',
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.check_circle_outline,
                size: 56,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'All done for today!',
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.success,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.reminder,
    required this.onDone,
    required this.onSnooze,
  });

  final Reminder reminder;
  final VoidCallback onDone;
  final VoidCallback onSnooze;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    final timeText = reminder.scheduledAt != null
        ? timeFormat.format(reminder.scheduledAt!.toLocal())
        : 'Soon';

    return Semantics(
      label:
          'Next medication: ${reminder.medicineName}, '
          '${reminder.dosage ?? ""}, at $timeText. '
          'Tap I Took It to confirm, or Snooze.',
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppShadows.elevated,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "NEXT UP" label
            Text(
              'NEXT UP',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.accent,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Medicine name — white, large
            Text(
              '💊 ${reminder.medicineName}',
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Dosage + time — white, lighter
            Text(
              [
                if (reminder.dosage != null) reminder.dosage!,
                'at $timeText',
              ].join(' · '),
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons (56px height)
            Row(
              children: [
                // DONE button — green
                Expanded(
                  child: Semantics(
                    sortKey: const OrdinalSortKey(2),
                    label: 'Confirm taking ${reminder.medicineName}',
                    button: true,
                    child: SizedBox(
                      height: AppSpacing.buttonHeight,
                      child: FilledButton.icon(
                        onPressed: onDone,
                        icon: const Icon(Icons.check, size: 24),
                        label: const Text(
                          'I Took It',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // SNOOZE button — amber outline
                Expanded(
                  child: Semantics(
                    sortKey: const OrdinalSortKey(3),
                    label: 'Snooze ${reminder.medicineName}',
                    button: true,
                    child: SizedBox(
                      height: AppSpacing.buttonHeight,
                      child: OutlinedButton.icon(
                        onPressed: onSnooze,
                        icon: const Icon(Icons.snooze, size: 24),
                        label: const Text(
                          'Snooze',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(
                            color: AppColors.warning,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
