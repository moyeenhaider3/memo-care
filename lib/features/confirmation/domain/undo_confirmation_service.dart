import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/features/confirmation/data/confirmation_repository.dart';
import 'package:memo_care/features/confirmation/domain/confirmation_service.dart';
import 'package:memo_care/features/confirmation/domain/models/undoable_confirmation.dart';
import 'package:memo_care/features/reminders/data/reminder_repository.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Result of an undo attempt.
sealed class UndoResult {
  const UndoResult();
}

/// Undo succeeded — the confirmation was deleted and all
/// side effects were reversed.
final class UndoSucceeded extends UndoResult {
  /// Creates an [UndoSucceeded] result.
  const UndoSucceeded();
}

/// Undo failed — the confirmation could not be deleted.
final class UndoFailed extends UndoResult {
  /// Creates an [UndoFailed] result.
  const UndoFailed({required this.reason});

  /// Human-readable reason for the failure.
  final String reason;
}

/// Reverses a medication confirmation (A11Y-07).
///
/// Given an [UndoableConfirmation], this service:
/// 1. Deletes the confirmation record from the database
/// 2. Reverses all side effects (alarm scheduling, `isActive`
///    toggling) based on the [ConfirmationOutcome]
///
/// This service is stateless — it receives its dependencies
/// via constructor injection and performs single-shot undo
/// operations.
class UndoConfirmationService {
  /// Creates an [UndoConfirmationService].
  const UndoConfirmationService({
    required this.confirmationRepository,
    required this.reminderRepository,
    required this.alarmScheduler,
  });

  /// Repository for deleting the confirmation record.
  final ConfirmationRepository confirmationRepository;

  /// Repository for toggling `isActive` on downstream
  /// reminders.
  final ReminderRepository reminderRepository;

  /// Scheduler for cancelling/rescheduling alarms.
  final AlarmScheduler alarmScheduler;

  /// Attempts to undo the given [undoable] confirmation.
  ///
  /// Returns [UndoSucceeded] on success, [UndoFailed] on
  /// error.
  Future<UndoResult> undo(UndoableConfirmation undoable) async {
    try {
      // Step 1: Delete the confirmation record.
      final deleted = await confirmationRepository.deleteConfirmation(
        undoable.confirmationId,
      );

      if (deleted == 0) {
        return const UndoFailed(
          reason: 'Confirmation record not found.',
        );
      }

      // Step 2: Reverse side effects based on outcome.
      final outcome = undoable.outcome;

      switch (outcome) {
        // DONE was confirmed → downstream was activated.
        // Undo: cancel downstream alarms + deactivate.
        case ActivateDownstream(:final reminders):
          await _cancelAlarms(reminders);
          await _deactivateReminders(reminders);

        // SKIP was confirmed → downstream was suspended.
        // Undo: reactivate downstream + reschedule alarms.
        case SuspendDownstream(:final reminders):
          await _activateReminders(reminders);
          await _scheduleAlarms(reminders);

        // SNOOZE rescheduled the same reminder.
        // Undo: cancel the snooze alarm.
        case RescheduleSnooze(:final reminder):
          await alarmScheduler.cancel(reminder.id);

        // Auto-skip suspended downstream reminders.
        // Undo: reactivate + reschedule.
        case AutoSkipped(:final suspendedReminders):
          await _activateReminders(suspendedReminders);
          await _scheduleAlarms(suspendedReminders);

        // Failure — nothing to undo.
        case ConfirmationFailed():
          break;
      }

      return const UndoSucceeded();
    } on Exception catch (e) {
      return UndoFailed(reason: e.toString());
    }
  }

  Future<void> _cancelAlarms(List<Reminder> reminders) async {
    for (final r in reminders) {
      await alarmScheduler.cancel(r.id);
    }
  }

  Future<void> _scheduleAlarms(List<Reminder> reminders) async {
    for (final r in reminders) {
      if (r.scheduledAt != null) {
        await alarmScheduler.schedule(
          reminderId: r.id,
          fireAt: r.scheduledAt!,
          callbackHandle: alarmFiredCallback,
        );
      }
    }
  }

  Future<void> _activateReminders(List<Reminder> reminders) async {
    for (final r in reminders) {
      await reminderRepository.updateReminder(
        r.copyWith(isActive: true),
      );
    }
  }

  Future<void> _deactivateReminders(List<Reminder> reminders) async {
    for (final r in reminders) {
      await reminderRepository.updateReminder(
        r.copyWith(isActive: false),
      );
    }
  }
}
