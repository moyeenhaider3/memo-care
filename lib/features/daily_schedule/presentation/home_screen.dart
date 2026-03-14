import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/confirmation/application/confirmation_notifier.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/confirmation/domain/models/undoable_confirmation.dart';
import 'package:memo_care/features/confirmation/presentation/widgets/undo_confirmation_bar.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_providers.dart';
import 'package:memo_care/features/daily_schedule/application/hydration_notifier.dart';
import 'package:memo_care/features/daily_schedule/presentation/missed_reminders_sheet.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/hydration_counter.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/next_pending_hero_card.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/progress_ring.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/reminder_list_tile.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/timeline_connector.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/user_greeting_header.dart';
import 'package:memo_care/features/fasting/application/fasting_notifier.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Home dashboard — greeting + progress ring + navy hero + timeline.
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

  Future<void> _confirm(Reminder reminder, ConfirmationState state) async {
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
    if (mounted) setState(() => _undoable = null);
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(dailyScheduleNotifierProvider);
    final fastingState = ref.watch(fastingNotifierProvider);
    final hydration = ref.watch(hydrationNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          scheduleAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong. Pull down to retry.',
                  style: AppTypography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (schedule) {
              final confirmedCount = schedule.todayReminders
                  .where(
                    (r) => !schedule.missedReminders.any(
                      (m) => m.id == r.id,
                    ),
                  )
                  .length;

              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(dailyScheduleNotifierProvider);
                  },
                  child: CustomScrollView(
                    slivers: [
                      // Greeting header
                      SliverToBoxAdapter(
                        child: Semantics(
                          sortKey: const OrdinalSortKey(0),
                          child: const UserGreetingHeader(),
                        ),
                      ),

                      // Progress ring — centered
                      SliverToBoxAdapter(
                        child: Semantics(
                          sortKey: const OrdinalSortKey(1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: ProgressRing(
                                completed: confirmedCount,
                                total: schedule.todayReminders.length,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Navy hero card
                      SliverToBoxAdapter(
                        child: Semantics(
                          sortKey: const OrdinalSortKey(2),
                          child: NextPendingHeroCard(
                            onDone: _handleDone,
                            onSkip: _handleSkip,
                          ),
                        ),
                      ),

                      if (fastingState.isActive)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF7E8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFF0A500),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.nightlight_round,
                                        color: Color(0xFFF0A500),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Fasting mode on. Next: Iftar medicines '
                                        'at ${_fmtTime(fastingState.iftarTime)}',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.go('/ramadan'),
                                    child: const Text('Open Ramadan'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (fastingState.isActive || hydration.glasses > 0)
                        const SliverToBoxAdapter(
                          child: HydrationCounter(),
                        ),

                      // "Today's Schedule" header
                      SliverToBoxAdapter(
                        child: Semantics(
                          header: true,
                          sortKey: const OrdinalSortKey(3),
                          label:
                              "Today's Schedule, "
                              '${schedule.todayReminders.length} items',
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              children: [
                                Text(
                                  "Today's Schedule",
                                  style: AppTypography.titleLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ExcludeSemantics(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${schedule.todayReminders.length}',
                                      style: AppTypography.labelLarge.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Timeline list or empty state
                      if (schedule.todayReminders.isEmpty)
                        SliverToBoxAdapter(child: _buildEmptyState())
                      else
                        SliverList.builder(
                          itemCount: schedule.todayReminders.length * 2 - 1,
                          itemBuilder: (context, index) {
                            // Even indices = reminder tiles, odd = connectors
                            if (index.isOdd) {
                              return const Padding(
                                padding: EdgeInsets.only(left: 34),
                                child: TimelineConnector(isActive: true),
                              );
                            }
                            final reminderIndex = index ~/ 2;
                            final reminder =
                                schedule.todayReminders[reminderIndex];
                            final isMissed = schedule.missedReminders.any(
                              (m) => m.id == reminder.id,
                            );
                            return Semantics(
                              sortKey: OrdinalSortKey(4.0 + reminderIndex),
                              child: ReminderListTile(
                                reminder: reminder,
                                confirmationStatus: isMissed ? null : null,
                              ),
                            );
                          },
                        ),

                      // Bottom padding
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              );
            },
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: AppColors.skippedGrey.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders scheduled for today.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first reminder',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.skippedGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime? time) {
    if (time == null) return '--:--';
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final normalized = hour == 0 ? 12 : hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$normalized:$minute $ampm';
  }
}
