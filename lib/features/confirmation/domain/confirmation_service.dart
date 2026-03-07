import 'package:memo_care/features/chain_engine/data/chain_repository.dart';
import 'package:memo_care/features/chain_engine/domain/chain_engine.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';
import 'package:memo_care/features/confirmation/data/confirmation_repository.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/confirmation/domain/snooze_limiter.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Outcome of a confirmation action — describes what the
/// caller (ConfirmationNotifier) should do next.
sealed class ConfirmationOutcome {
  const ConfirmationOutcome();
}

/// Downstream reminders should be scheduled (DONE case).
final class ActivateDownstream extends ConfirmationOutcome {
  /// Creates an [ActivateDownstream] outcome.
  const ActivateDownstream({required this.reminders});

  /// Reminders to activate and schedule via AlarmScheduler.
  final List<Reminder> reminders;
}

/// Downstream reminders should be suspended (SKIPPED case).
final class SuspendDownstream extends ConfirmationOutcome {
  /// Creates a [SuspendDownstream] outcome.
  const SuspendDownstream({required this.reminders});

  /// Reminders to deactivate and cancel alarms for.
  final List<Reminder> reminders;
}

/// Same reminder should be rescheduled with snooze offset.
final class RescheduleSnooze extends ConfirmationOutcome {
  /// Creates a [RescheduleSnooze] outcome.
  const RescheduleSnooze({
    required this.reminder,
    required this.remainingSnoozes,
  });

  /// The reminder to reschedule.
  final Reminder reminder;

  /// Number of snoozes remaining after this one.
  final int remainingSnoozes;
}

/// Snooze was auto-converted to SKIP because max snoozes
/// exceeded (CHAIN-06).
final class AutoSkipped extends ConfirmationOutcome {
  /// Creates an [AutoSkipped] outcome.
  const AutoSkipped({
    required this.reason,
    required this.suspendedReminders,
  });

  /// Reason for the auto-skip.
  final String reason;

  /// Downstream reminders to suspend (same as SKIPPED).
  final List<Reminder> suspendedReminders;
}

/// Confirmation failed due to a chain error.
final class ConfirmationFailed extends ConfirmationOutcome {
  /// Creates a [ConfirmationFailed] outcome.
  const ConfirmationFailed({required this.error});

  /// The chain error that caused the failure.
  final ChainError error;
}

/// Orchestrates the full confirmation flow:
/// snooze limit check → record → chain evaluation → outcome.
///
/// Does NOT call AlarmScheduler — returns
/// [ConfirmationOutcome] for the caller to act on.
///
/// Pure domain logic — no Flutter imports.
class ConfirmationService {
  /// Creates a [ConfirmationService].
  ConfirmationService({
    required this.chainEngine,
    required this.snoozeLimiter,
    required this.confirmationRepository,
    required this.chainRepository,
  });

  /// The chain engine for DAG evaluation.
  final ChainEngine chainEngine;

  /// The snooze limiter for enforcing max snoozes.
  final SnoozeLimiter snoozeLimiter;

  /// Repository for reading/writing confirmations.
  final ConfirmationRepository confirmationRepository;

  /// Repository for reading chain data.
  final ChainRepository chainRepository;

  /// Processes a user confirmation for [reminderId]
  /// belonging to chain [chainId].
  ///
  /// Flow:
  /// 1. If SNOOZED: check snooze limit
  ///    - If exhausted: auto-transition to SKIPPED
  /// 2. Record confirmation in database
  /// 3. Evaluate chain engine for downstream effects
  /// 4. Return [ConfirmationOutcome]
  Future<ConfirmationOutcome> confirm({
    required int reminderId,
    required int chainId,
    required ConfirmationState state,
    DateTime? snoozeUntil,
  }) async {
    // Step 1: Snooze limit check.
    var effectiveState = state;
    String? autoSkipReason;
    var snoozeRemaining = 0;

    if (state == ConfirmationState.snoozed) {
      final snoozeCount = await confirmationRepository.countSnoozes(reminderId);
      final decision = snoozeLimiter.evaluate(snoozeCount);

      switch (decision) {
        case SnoozeAllowed(:final remainingSnoozes):
          effectiveState = ConfirmationState.snoozed;
          snoozeRemaining = remainingSnoozes;
        case SnoozeExhausted(:final reason):
          effectiveState = ConfirmationState.skipped;
          autoSkipReason = reason;
          snoozeUntil = null;
      }
    }

    // Step 2: Record confirmation.
    final now = DateTime.now().toUtc();
    await confirmationRepository.createConfirmation(
      reminderId: reminderId,
      state: effectiveState,
      confirmedAt: now,
      snoozeUntil: effectiveState == ConfirmationState.snoozed
          ? snoozeUntil
          : null,
    );

    // Step 3: Evaluate chain engine.
    final reminders = await chainRepository.getReminders(chainId);
    final edges = await chainRepository.getEdges(chainId);

    final evalResult = chainEngine.evaluate(
      reminders: reminders,
      edges: edges,
      confirmedId: reminderId,
      state: effectiveState,
    );

    // Step 4: Return outcome.
    return evalResult.fold(
      (error) => ConfirmationFailed(error: error),
      (affectedReminders) {
        if (autoSkipReason != null) {
          return AutoSkipped(
            reason: autoSkipReason,
            suspendedReminders: affectedReminders,
          );
        }

        return switch (effectiveState) {
          ConfirmationState.done => ActivateDownstream(
            reminders: affectedReminders,
          ),
          ConfirmationState.skipped => SuspendDownstream(
            reminders: affectedReminders,
          ),
          ConfirmationState.snoozed => RescheduleSnooze(
            reminder: affectedReminders.first,
            remainingSnoozes: snoozeRemaining,
          ),
        };
      },
    );
  }
}
