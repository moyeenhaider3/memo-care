import 'package:drift/drift.dart';
import 'package:memo_care/core/database/app_database.dart';

part 'reminder_dao.g.dart';

/// Data access object for individual reminders within chains.
@DriftAccessor(tables: [Reminders, Confirmations])
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
    return (select(reminders)..where((r) => r.chainId.equals(chainId))).watch();
  }

  /// Watch a single reminder by ID.
  Stream<ReminderRow?> watchReminderById(int id) {
    return (select(
      reminders,
    )..where((r) => r.id.equals(id))).watchSingleOrNull();
  }

  /// Get a single reminder by ID (one-shot).
  Future<ReminderRow?> getReminderById(int id) {
    return (select(reminders)..where((r) => r.id.equals(id))).getSingleOrNull();
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

  /// Watches today's reminders in chronological order (VIEW-01).
  ///
  /// Filters to reminders with `scheduled_at` between
  /// [todayStartUtcMs] and [todayEndUtcMs] in UTC epoch millis.
  /// Auto-emits on any change to the reminders table.
  Stream<List<ReminderRow>> watchTodayReminders({
    required int todayStartUtcMs,
    required int todayEndUtcMs,
  }) {
    return (select(reminders)
          ..where(
            (r) =>
                r.scheduledAt.isBiggerOrEqualValue(todayStartUtcMs) &
                r.scheduledAt.isSmallerThanValue(todayEndUtcMs) &
                r.isActive.equals(true),
          )
          ..orderBy([
            (r) => OrderingTerm.asc(r.scheduledAt),
          ]))
        .watch();
  }

  /// Watches missed reminders (VIEW-04).
  ///
  /// A reminder is "missed" if `scheduled_at < now` AND
  /// no terminal (done/skipped) confirmation exists.
  Stream<List<ReminderRow>> watchMissedReminders({
    required int nowUtcMs,
  }) {
    final query = customSelect(
      'SELECT r.* FROM reminders r '
      'LEFT JOIN confirmations c '
      "ON c.reminder_id = r.id AND c.state IN ('done', 'skipped') "
      'WHERE r.scheduled_at < ? '
      'AND r.is_active = 1 '
      'AND c.id IS NULL '
      'ORDER BY r.scheduled_at ASC',
      variables: [Variable.withInt(nowUtcMs)],
      readsFrom: {reminders, confirmations},
    );
    return query.watch().map(
      (rows) => rows.map((row) => reminders.map(row.data)).toList(),
    );
  }

  /// Result row from the history page query.
  Future<List<HistoryQueryRow>> getHistoryPage({
    required int limit,
    required int offset,
    String? medicineNameFilter,
  }) {
    final filterClause = medicineNameFilter != null
        ? 'AND r.medicine_name LIKE ?'
        : '';
    final variables = <Variable<Object>>[
      if (medicineNameFilter != null)
        Variable.withString('%$medicineNameFilter%'),
      Variable.withInt(limit),
      Variable.withInt(offset),
    ];

    return customSelect(
      'SELECT r.id AS r_id, r.medicine_name, r.dosage, '
      'r.scheduled_at, '
      'c.state AS confirmation_state, c.confirmed_at '
      'FROM reminders r '
      'LEFT JOIN confirmations c ON c.reminder_id = r.id '
      "AND c.state IN ('done', 'skipped') "
      'WHERE 1=1 $filterClause '
      'ORDER BY r.scheduled_at DESC '
      'LIMIT ? OFFSET ?',
      variables: variables,
      readsFrom: {reminders, confirmations},
    ).get().then(
      (rows) => rows
          .map(
            (row) => HistoryQueryRow(
              reminderId: row.read<int>('r_id'),
              medicineName: row.read<String>('medicine_name'),
              dosage: row.readNullable<String>('dosage'),
              scheduledAt: row.read<int>('scheduled_at'),
              confirmationState: row.readNullable<String>(
                'confirmation_state',
              ),
              confirmedAt: row.readNullable<int>(
                'confirmed_at',
              ),
            ),
          )
          .toList(),
    );
  }

  /// Returns total count of history entries matching
  /// [medicineNameFilter] — for pagination UI.
  Future<int> getHistoryTotalCount({
    String? medicineNameFilter,
  }) {
    final filterClause = medicineNameFilter != null
        ? 'AND r.medicine_name LIKE ?'
        : '';
    final variables = <Variable<Object>>[
      if (medicineNameFilter != null)
        Variable.withString('%$medicineNameFilter%'),
    ];

    return customSelect(
      'SELECT COUNT(*) AS cnt FROM reminders r '
      'WHERE 1=1 $filterClause',
      variables: variables,
      readsFrom: {reminders},
    ).getSingle().then((row) => row.read<int>('cnt'));
  }

  /// Returns distinct medicine names for the history filter
  /// dropdown (HIST-03).
  Future<List<String>> getDistinctMedicineNames() {
    return customSelect(
      'SELECT DISTINCT medicine_name '
      'FROM reminders '
      'ORDER BY medicine_name ASC',
      readsFrom: {reminders},
    ).get().then(
      (rows) => rows.map((row) => row.read<String>('medicine_name')).toList(),
    );
  }
}

/// Result row from the history page query.
///
/// Bridges the raw SQL join result into a typed Dart object
/// before the repository maps it to a domain `HistoryEntry`.
class HistoryQueryRow {
  /// Creates a [HistoryQueryRow].
  const HistoryQueryRow({
    required this.reminderId,
    required this.medicineName,
    required this.scheduledAt,
    this.dosage,
    this.confirmationState,
    this.confirmedAt,
  });

  /// Reminder primary key.
  final int reminderId;

  /// Medicine name.
  final String medicineName;

  /// Optional dosage text.
  final String? dosage;

  /// Scheduled time as epoch milliseconds.
  final int scheduledAt;

  /// `'done'`, `'skipped'`, or null.
  final String? confirmationState;

  /// Confirmation time as epoch milliseconds, or null.
  final int? confirmedAt;
}
