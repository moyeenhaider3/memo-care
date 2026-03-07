import 'package:memo_care/features/confirmation/domain/confirmation_service.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';

/// Holds the information needed to undo a confirmation action.
///
/// Created by `ConfirmationNotifier.confirm()` and consumed by
/// `UndoConfirmationService.undo()` to reverse the side effects
/// (alarm scheduling, isActive toggling, confirmation record).
class UndoableConfirmation {
  /// Creates an [UndoableConfirmation].
  const UndoableConfirmation({
    required this.confirmationId,
    required this.reminderId,
    required this.chainId,
    required this.medicineName,
    required this.confirmState,
    required this.outcome,
  });

  /// Database ID of the confirmation record to delete.
  final int confirmationId;

  /// The reminder that was confirmed.
  final int reminderId;

  /// The chain this reminder belongs to.
  final int chainId;

  /// Display name of the medicine (for SnackBar text).
  final String medicineName;

  /// The confirmation state that was applied (done/skipped/snoozed).
  final ConfirmationState confirmState;

  /// The outcome that was produced — used to reverse side effects.
  final ConfirmationOutcome outcome;
}
