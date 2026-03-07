import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:memo_care/features/daily_schedule/application/daily_schedule_providers.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Prominent hero card displaying the next pending reminder
/// (VIEW-02).
///
/// Shows medicine name (24 pt bold), dosage, time, and large
/// DONE / SKIP buttons. If no pending reminder exists, shows an
/// "All done!" message.
///
/// Accessibility:
/// - Full card has a [Semantics] label
/// - Buttons are >= 56 dp height with text labels (not icon-only)
/// - High-contrast colours
class NextPendingHeroCard extends ConsumerWidget {
  const NextPendingHeroCard({
    required this.onDone,
    required this.onSkip,
    super.key,
  });

  /// Called when the user taps "I Took It" — receives reminder.
  final void Function(Reminder reminder) onDone;

  /// Called when the user taps "Skip" — receives reminder.
  final void Function(Reminder reminder) onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(nextPendingReminderProvider);
    final theme = Theme.of(context);

    if (reminder == null) {
      return _AllDoneCard(theme: theme);
    }

    return _PendingCard(
      reminder: reminder,
      theme: theme,
      onDone: () => onDone(reminder),
      onSkip: () => onSkip(reminder),
    );
  }
}

// ------------------------------------------------------------------
// Private helpers
// ------------------------------------------------------------------

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'All medications taken for today. Well done!',
      child: Card(
        margin: const EdgeInsets.all(16),
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'All done for today! ✓',
                style:
                    theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      theme.colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.reminder,
    required this.theme,
    required this.onDone,
    required this.onSkip,
  });

  final Reminder reminder;
  final ThemeData theme;
  final VoidCallback onDone;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    final timeText = reminder.scheduledAt != null
        ? timeFormat.format(reminder.scheduledAt!.toLocal())
        : 'Soon';

    return Semantics(
      label: 'Next medication: ${reminder.medicineName}, '
          '${reminder.dosage ?? ""}, at $timeText. '
          'Tap I Took It to confirm, or Skip.',
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "NEXT UP" label
              Text(
                'NEXT UP',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Medicine name (24pt bold)
              Text(
                '💊 ${reminder.medicineName}',
                style:
                    theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),

              // Dosage + time
              Text(
                [
                  if (reminder.dosage != null)
                    reminder.dosage!,
                  'at $timeText',
                ].join(' · '),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme
                      .colorScheme.onPrimaryContainer
                      .withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons (56 dp+ height, side by side)
              Row(
                children: [
                  // "I Took It ✓" button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: onDone,
                        icon:
                            const Icon(Icons.check, size: 24),
                        label: const Text(
                          'I Took It',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // "Skip ✗" button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: onSkip,
                        icon:
                            const Icon(Icons.close, size: 24),
                        label: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.red.shade700,
                          side: BorderSide(
                            color: Colors.red.shade700,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
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
      ),
    );
  }
}
