import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/theme/app_theme.dart';
import 'package:memo_care/features/confirmation/application/confirmation_notifier.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_providers.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Modal bottom sheet surfacing missed reminders on app open
/// (VIEW-04).
///
/// Shows all reminders where scheduledAt < now AND no terminal
/// confirmation. Provides per-item DONE / SKIP and bulk
/// "Mark All Done" / "Skip All" actions.
///
/// Accessibility:
/// - Header text 24 pt
/// - All buttons >= 56 dp touch targets
/// - Semantics labels on every interactive element
/// - Amber warning icon for visual urgency
class MissedRemindersSheet extends ConsumerStatefulWidget {
  const MissedRemindersSheet({super.key});

  @override
  ConsumerState<MissedRemindersSheet> createState() =>
      _MissedRemindersSheetState();
}

class _MissedRemindersSheetState extends ConsumerState<MissedRemindersSheet> {
  final Set<int> _resolvedIds = {};

  void _markDone(Reminder reminder) {
    unawaited(
      ref
          .read(confirmationNotifierProvider.notifier)
          .confirm(
            reminderId: reminder.id,
            chainId: reminder.chainId,
            confirmState: ConfirmationState.done,
            medicineName: reminder.medicineName,
          ),
    );
    setState(() => _resolvedIds.add(reminder.id));
    _checkAllResolved();
  }

  void _markSkip(Reminder reminder) {
    unawaited(
      ref
          .read(confirmationNotifierProvider.notifier)
          .confirm(
            reminderId: reminder.id,
            chainId: reminder.chainId,
            confirmState: ConfirmationState.skipped,
            medicineName: reminder.medicineName,
          ),
    );
    setState(() => _resolvedIds.add(reminder.id));
    _checkAllResolved();
  }

  void _markAllDone(List<Reminder> reminders) {
    for (final r in reminders) {
      if (!_resolvedIds.contains(r.id)) {
        _markDone(r);
      }
    }
  }

  void _skipAll(List<Reminder> reminders) {
    for (final r in reminders) {
      if (!_resolvedIds.contains(r.id)) {
        _markSkip(r);
      }
    }
  }

  void _checkAllResolved() {
    final missed = ref.read(missedRemindersProvider);
    if (missed.every((r) => _resolvedIds.contains(r.id))) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final missed = ref.watch(missedRemindersProvider);
    final unresolved = missed
        .where((r) => !_resolvedIds.contains(r.id))
        .toList();
    final theme = Theme.of(context);
    final timeFormat = DateFormat.jm();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: AppColors.warningAmber,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      'You have ${unresolved.length} missed '
                      'reminder${unresolved.length == 1 ? "" : "s"}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Missed items list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: unresolved.length,
                itemBuilder: (context, index) {
                  final reminder = unresolved[index];
                  final timeText = reminder.scheduledAt != null
                      ? timeFormat.format(
                          reminder.scheduledAt!.toLocal(),
                        )
                      : '--:--';

                  return Semantics(
                    label:
                        'Missed: ${reminder.medicineName}, '
                        '${reminder.dosage ?? ""}, '
                        'was due at $timeText',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Name + time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.medicineName,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$timeText'
                                  '${reminder.dosage != null ? " · "
                                      "${reminder.dosage}" : ""}',
                                  style: theme
                                      .textTheme.bodyMedium
                                      ?.copyWith(
                                    color: theme
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Done button
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: () => _markDone(reminder),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    AppColors.doneButtonBackground,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Skip button
                          SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => _markSkip(reminder),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    AppColors.skipButtonForeground,
                                side: const BorderSide(
                                  color: AppColors.skipButtonForeground,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Bulk action buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: Semantics(
                      label: 'Mark all missed reminders as done',
                      button: true,
                      child: FilledButton.icon(
                        onPressed: unresolved.isNotEmpty
                            ? () => _markAllDone(unresolved)
                            : null,
                        icon: const Icon(
                          Icons.check_circle,
                          size: 24,
                        ),
                        label: const Text(
                          'Mark All Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              AppColors.doneButtonBackground,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: Semantics(
                      label: 'Skip all missed reminders',
                      button: true,
                      child: OutlinedButton.icon(
                        onPressed: unresolved.isNotEmpty
                            ? () => _skipAll(unresolved)
                            : null,
                        icon: const Icon(
                          Icons.skip_next,
                          size: 24,
                        ),
                        label: const Text(
                          'Skip All',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              AppColors.skipButtonForeground,
                          side: const BorderSide(
                            color: AppColors.skipButtonForeground,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
