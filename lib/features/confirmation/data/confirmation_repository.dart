import 'package:drift/drift.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/features/confirmation/data/confirmation_dao.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';

/// Repository bridging [ConfirmationDao] → [Confirmation] domain models.
///
/// Confirmations are append-only — new confirmations are created, never
/// updated.
class ConfirmationRepository {
  ConfirmationRepository(this._dao);
  final ConfirmationDao _dao;

  /// Watch all confirmations for a reminder, newest first.
  Stream<List<Confirmation>> watchForReminder(int reminderId) {
    return _dao
        .watchConfirmationsForReminder(reminderId)
        .map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  /// Watch the latest confirmation for a reminder.
  Stream<Confirmation?> watchLatest(int reminderId) {
    return _dao
        .watchLatestConfirmation(reminderId)
        .map(
          (row) => row == null ? null : _fromRow(row),
        );
  }

  /// Create a new confirmation. Returns the auto-generated ID.
  Future<int> createConfirmation({
    required int reminderId,
    required ConfirmationState state,
    required DateTime confirmedAt,
    DateTime? snoozeUntil,
  }) {
    return _dao.insertConfirmation(
      ConfirmationsCompanion.insert(
        reminderId: reminderId,
        state: state.dbValue,
        confirmedAt: confirmedAt,
        snoozeUntil: Value(snoozeUntil),
      ),
    );
  }

  /// Count how many times [reminderId] has been snoozed.
  Future<int> countSnoozes(int reminderId) {
    return _dao.countSnoozes(reminderId);
  }

  // --------------- Mapping ---------------

  Confirmation _fromRow(ConfirmationRow row) => Confirmation(
    id: row.id,
    reminderId: row.reminderId,
    state: ConfirmationState.fromDbString(row.state),
    confirmedAt: row.confirmedAt,
    snoozeUntil: row.snoozeUntil,
  );
}
