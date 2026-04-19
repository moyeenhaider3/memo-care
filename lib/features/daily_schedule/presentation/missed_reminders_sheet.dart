import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/debug/bootstrap_trace.dart';
import 'package:memo_care/core/theme/app_colors.dart';
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

  Future<void> _markDone(Reminder reminder) async {
    await traceAsync('ui', 'MissedSheet.done', () async {
      final result = await ref
          .read(confirmationNotifierProvider.notifier)
          .confirm(
            reminderId: reminder.id,
            chainId: reminder.chainId,
            confirmState: ConfirmationState.done,
            medicineName: reminder.medicineName,
          );
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't update reminder. Try again."),
          ),
        );
        return;
      }
      setState(() => _resolvedIds.add(reminder.id));
      _checkAllResolved();
    });
  }

  Future<void> _markSkip(Reminder reminder) async {
    await traceAsync('ui', 'MissedSheet.skip', () async {
      final result = await ref
          .read(confirmationNotifierProvider.notifier)
          .confirm(
            reminderId: reminder.id,
            chainId: reminder.chainId,
            confirmState: ConfirmationState.skipped,
            medicineName: reminder.medicineName,
          );
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't update reminder. Try again."),
          ),
        );
        return;
      }
      setState(() => _resolvedIds.add(reminder.id));
      _checkAllResolved();
    });
  }

  Future<void> _markAllDone(List<Reminder> reminders) async {
    for (final r in reminders) {
      if (!_resolvedIds.contains(r.id)) {
        await _markDone(r);
      }
    }
  }

  Future<void> _skipAll(List<Reminder> reminders) async {
    for (final r in reminders) {
      if (!_resolvedIds.contains(r.id)) {
        await _markSkip(r);
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
    final media = MediaQuery.of(context);
    // FIXED: Column(mainAxisSize: min) + Flexible(ListView) got unbounded /
    // zero-width constraints — text rendered one character per line and
    // actions overlapped the FAB. Use a bounded height and Expanded list.
    final maxSheetHeight = media.size.height * 0.92;
    final bottomGap = media.padding.bottom + 72;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                Row(
                  children: [
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 32,
                        color: AppColors.warning,
                      ),
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

                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: unresolved.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: LayoutBuilder(
                            builder: (context, rowConstraints) {
                              final narrow = rowConstraints.maxWidth < 360;
                              final textBlock = Column(
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
                                    '${reminder.dosage != null ? " · ${reminder.dosage}" : ""}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              );
                              final actions = Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Semantics(
                                    label:
                                        'Mark ${reminder.medicineName} as done',
                                    button: true,
                                    child: SizedBox(
                                      height: 56,
                                      child: FilledButton(
                                        onPressed: () {
                                          unawaited(_markDone(reminder));
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                        ),
                                        child: const Text(
                                          'Done',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Semantics(
                                    label: 'Skip ${reminder.medicineName}',
                                    button: true,
                                    child: SizedBox(
                                      height: 56,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          unawaited(_markSkip(reminder));
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.danger,
                                          side: const BorderSide(
                                            color: AppColors.danger,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                        ),
                                        child: const Text(
                                          'Skip',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );

                              if (narrow) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    textBlock,
                                    const SizedBox(height: 8),
                                    actions,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: textBlock),
                                  actions,
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

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
                              backgroundColor: AppColors.success,
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
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(
                                color: AppColors.danger,
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
        ),
      ),
    );
  }
}
