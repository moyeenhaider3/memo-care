import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/confirmation/application/confirmation_notifier.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/confirmation/domain/models/undoable_confirmation.dart';
import 'package:memo_care/features/confirmation/presentation/widgets/undo_confirmation_bar.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_providers.dart';
import 'package:memo_care/features/daily_schedule/presentation/missed_reminders_sheet.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/next_pending_hero_card.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/reminder_list_tile.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Main home screen showing today's medication schedule
/// (VIEW-01, VIEW-02, VIEW-04).
///
/// Layout:
/// 1. [NextPendingHeroCard] (pinned at top)
/// 2. Scrollable list of all today's reminders with status badges
///
/// On first build, checks for missed reminders and shows
/// [MissedRemindersSheet].
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _missedChecked = false;
  UndoableConfirmation? _undoable;

  @override
  void initState() {
    super.initState();
    // Check for missed reminders after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMissedReminders();
    });
  }

  void _checkMissedReminders() {
    if (_missedChecked) return;
    _missedChecked = true;

    final hasMissed = ref.read(hasMissedRemindersProvider);
    if (hasMissed) {
      unawaited(
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          builder: (context) => const MissedRemindersSheet(),
        ),
      );
    }
  }

  void _handleDone(Reminder reminder) {
    unawaited(_confirm(reminder, ConfirmationState.done));
  }

  void _handleSkip(Reminder reminder) {
    unawaited(_confirm(reminder, ConfirmationState.skipped));
  }

  Future<void> _confirm(
    Reminder reminder,
    ConfirmationState state,
  ) async {
    final result = await ref
        .read(confirmationNotifierProvider.notifier)
        .confirm(
          reminderId: reminder.id,
          chainId: reminder.chainId,
          confirmState: state,
          medicineName: reminder.medicineName,
        );

    if (result != null && mounted) {
      setState(() => _undoable = result);
    }
  }

  void _dismissUndo() {
    if (mounted) {
      setState(() => _undoable = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(dailyScheduleNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MemoCare',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          scheduleAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong. '
                  'Pull down to retry.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (schedule) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  dailyScheduleNotifierProvider,
                );
              },
              child: CustomScrollView(
                slivers: [
                  // Hero card (pinned at top)
                  SliverToBoxAdapter(
                    child: NextPendingHeroCard(
                      onDone: _handleDone,
                      onSkip: _handleSkip,
                    ),
                  ),

                  // "Today's Schedule" header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Today's Schedule",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${schedule.todayReminders.length}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Reminder list
                  if (schedule.todayReminders.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No reminders scheduled for '
                          'today.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    SliverList.separated(
                      itemCount: schedule.todayReminders.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final reminder = schedule.todayReminders[index];
                        // Determine if this reminder is missed.
                        final isMissed = schedule.missedReminders.any(
                          (m) => m.id == reminder.id,
                        );
                        return ReminderListTile(
                          reminder: reminder,
                          // If missed, pass null so StatusBadge
                          // uses isMissed flag logic. Otherwise
                          // also null (pending).
                          confirmationStatus: isMissed ? null : null,
                        );
                      },
                    ),

                  // Bottom padding for scroll comfort
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
          ),

          // Undo confirmation bar
          if (_undoable != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: UndoConfirmationBar(
                undoable: _undoable!,
                onDismissed: _dismissUndo,
              ),
            ),
        ],
      ),
    );
  }
}
