import 'package:drift/drift.dart';
import 'package:memo_care/core/database/app_database.dart';

part 'reminder_dao.g.dart';

/// Data access object for individual reminders within chains.
@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.attachedDatabase);

  /// Watch all active reminders, ordered by scheduled time (earliest first).
  Stream<List<ReminderRow>> watchActiveReminders() {
    return (select(reminders)
          ..where((r) => r.isActive.equals(true))
          ..orderBy([
            (r) => OrderingTerm.asc(r.scheduledAt, nulls: NullsOrder.last),
          ]))
        .watch();
  }

  /// Watch all reminders belonging to a specific chain.
  Stream<List<ReminderRow>> watchRemindersForChain(int chainId) {
    return (select(reminders)..where((r) => r.chainId.equals(chainId)))
        .watch();
  }

  /// Watch a single reminder by ID.
  Stream<ReminderRow?> watchReminderById(int id) {
    return (select(reminders)..where((r) => r.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Insert a new reminder.
  Future<int> insertReminder(RemindersCompanion companion) {
    return into(reminders).insert(companion);
  }

  /// Update an existing reminder.
  Future<bool> updateReminder(RemindersCompanion companion) {
    return update(reminders).replace(companion);
  }

  /// Delete a reminder by ID.
  Future<int> deleteReminder(int id) {
    return (delete(reminders)..where((r) => r.id.equals(id))).go();
  }

  /// Delete all reminders for a chain.
  Future<int> deleteRemindersForChain(int chainId) {
    return (delete(reminders)..where((r) => r.chainId.equals(chainId))).go();
  }
}
