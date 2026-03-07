import 'package:drift/drift.dart';
import 'package:memo_care/core/database/app_database.dart';

part 'confirmation_dao.g.dart';

/// Data access object for reminder confirmations (done/snoozed/skipped).
/// Confirmations are append-only.
@DriftAccessor(tables: [Confirmations])
class ConfirmationDao extends DatabaseAccessor<AppDatabase>
    with _$ConfirmationDaoMixin {
  ConfirmationDao(super.attachedDatabase);

  /// Watch all confirmations for a specific reminder, newest first.
  Stream<List<ConfirmationRow>> watchConfirmationsForReminder(int reminderId) {
    return (select(confirmations)
          ..where((c) => c.reminderId.equals(reminderId))
          ..orderBy([(c) => OrderingTerm.desc(c.confirmedAt)]))
        .watch();
  }

  /// Watch the most recent confirmation for a reminder.
  Stream<ConfirmationRow?> watchLatestConfirmation(int reminderId) {
    return (select(confirmations)
          ..where((c) => c.reminderId.equals(reminderId))
          ..orderBy([(c) => OrderingTerm.desc(c.confirmedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Insert a new confirmation record.
  Future<int> insertConfirmation(ConfirmationsCompanion companion) {
    return into(confirmations).insert(companion);
  }

  /// Count SNOOZED confirmations for a specific reminder.
  Future<int> countSnoozes(int reminderId) async {
    final countExp = confirmations.id.count();
    final query = selectOnly(confirmations)
      ..addColumns([countExp])
      ..where(confirmations.reminderId.equals(reminderId))
      ..where(confirmations.state.equals('snoozed'));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Delete a single confirmation by [id].
  ///
  /// Returns the number of deleted rows (0 or 1).
  Future<int> deleteConfirmation(int id) {
    return (delete(confirmations)..where((c) => c.id.equals(id))).go();
  }
}
