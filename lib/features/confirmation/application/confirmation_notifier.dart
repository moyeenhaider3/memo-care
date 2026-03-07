// Riverpod autoDispose builder return types are not publicly
// exported.
// ignore_for_file: specify_nonobvious_property_types

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/providers/alarm_providers.dart';
import 'package:memo_care/features/chain_engine/application/chain_notifier.dart';
import 'package:memo_care/features/confirmation/application/providers.dart';
import 'package:memo_care/features/confirmation/domain/confirmation_service.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/confirmation/domain/models/undoable_confirmation.dart';
import 'package:memo_care/features/reminders/application/providers.dart';
import 'package:memo_care/features/reminders/data/reminder_repository.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Handles user confirmation actions (DONE / SNOOZE / SKIP)
/// end-to-end.
///
/// Flow:
/// 1. Calls [ConfirmationService.confirm()] for domain logic
/// 2. Dispatches `AlarmScheduler` side effects based on
///    [ConfirmationOutcome]
/// 3. Updates `ReminderRepository` for `isActive` changes
/// 4. Invalidates chain state to refresh UI
class ConfirmationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Action-driven — no initial async state.
  }

  /// Confirms a reminder with the given [confirmState].
  ///
  /// Returns an [UndoableConfirmation] if the action succeeded
  /// (null on failure), enabling the caller to show an undo bar.
  ///
  /// [medicineName] is used for the undo bar display text.
  /// [snoozeUntil] is required when [confirmState] is
  /// [ConfirmationState.snoozed].
  Future<UndoableConfirmation?> confirm({
    required int reminderId,
    required int chainId,
    required ConfirmationState confirmState,
    required String medicineName,
    DateTime? snoozeUntil,
  }) async {
    state = const AsyncLoading<void>();

    try {
      final service = ref.read(confirmationServiceProvider);
      final scheduler = ref.read(alarmSchedulerProvider);
      final reminderRepo = ref.read(reminderRepositoryProvider);

      final result = await service.confirm(
        reminderId: reminderId,
        chainId: chainId,
        state: confirmState,
        snoozeUntil: snoozeUntil,
      );

      final outcome = result.outcome;

      switch (outcome) {
        case ActivateDownstream(:final reminders):
          await _scheduleReminders(reminders);
          await _setActive(reminders, reminderRepo);

        case SuspendDownstream(:final reminders):
          await _cancelReminders(reminders);
          await _setInactive(reminders, reminderRepo);

        case RescheduleSnooze(
          :final reminder,
          remainingSnoozes: _,
        ):
          if (snoozeUntil != null) {
            await scheduler.schedule(
              reminderId: reminder.id,
              fireAt: snoozeUntil,
              callbackHandle: alarmFiredCallback,
            );
          }

        case AutoSkipped(:final suspendedReminders):
          await _cancelReminders(suspendedReminders);
          await _setInactive(
            suspendedReminders,
            reminderRepo,
          );

        case ConfirmationFailed(:final error):
          state = AsyncError<void>(error, StackTrace.current);
          return null;
      }

      // Refresh chain state for watchers.
      ref.invalidate(chainNotifierProvider(chainId));
      state = const AsyncData<void>(null);

      return UndoableConfirmation(
        confirmationId: result.confirmationId,
        reminderId: reminderId,
        chainId: chainId,
        medicineName: medicineName,
        confirmState: confirmState,
        outcome: outcome,
      );
    } on Exception catch (e, st) {
      state = AsyncError<void>(e, st);
      return null;
    }
  }

  // ----------- private helpers ----------- //

  Future<void> _scheduleReminders(
    List<Reminder> reminders,
  ) async {
    final scheduler = ref.read(alarmSchedulerProvider);
    for (final reminder in reminders) {
      if (reminder.scheduledAt != null) {
        await scheduler.schedule(
          reminderId: reminder.id,
          fireAt: reminder.scheduledAt!,
          callbackHandle: alarmFiredCallback,
        );
      }
    }
  }

  Future<void> _cancelReminders(
    List<Reminder> reminders,
  ) async {
    final scheduler = ref.read(alarmSchedulerProvider);
    for (final reminder in reminders) {
      await scheduler.cancel(reminder.id);
    }
  }

  Future<void> _setActive(
    List<Reminder> reminders,
    ReminderRepository repo,
  ) async {
    for (final r in reminders) {
      await repo.updateReminder(
        r.copyWith(isActive: true),
      );
    }
  }

  Future<void> _setInactive(
    List<Reminder> reminders,
    ReminderRepository repo,
  ) async {
    for (final r in reminders) {
      await repo.updateReminder(
        r.copyWith(isActive: false),
      );
    }
  }
}

/// Provider for [ConfirmationNotifier].
///
/// Auto-disposes when no longer watched.
final confirmationNotifierProvider =
    AsyncNotifierProvider.autoDispose<ConfirmationNotifier, void>(
      ConfirmationNotifier.new,
    );
