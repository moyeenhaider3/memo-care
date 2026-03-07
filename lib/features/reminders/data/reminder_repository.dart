import 'package:drift/drift.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/features/reminders/data/reminder_dao.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Repository bridging [ReminderDao] → [Reminder] domain models.
class ReminderRepository {
  ReminderRepository(this._dao);
  final ReminderDao _dao;

  /// Watch all active reminders as domain models, ordered by scheduled time.
  Stream<List<Reminder>> watchActive() {
    return _dao.watchActiveReminders().map(
      (rows) => rows.map(_fromRow).toList(),
    );
  }

  /// Watch all reminders for a specific chain.
  Stream<List<Reminder>> watchForChain(int chainId) {
    return _dao
        .watchRemindersForChain(chainId)
        .map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  /// Watch a single reminder by ID.
  Stream<Reminder?> watchById(int id) {
    return _dao
        .watchReminderById(id)
        .map(
          (row) => row == null ? null : _fromRow(row),
        );
  }

  /// Create a new reminder. Returns the auto-generated ID.
  Future<int> createReminder({
    required int chainId,
    required String medicineName,
    required MedicineType medicineType,
    String? dosage,
    DateTime? scheduledAt,
    bool isActive = false,
    int? gapHours,
  }) {
    return _dao.insertReminder(
      RemindersCompanion.insert(
        chainId: chainId,
        medicineName: medicineName,
        medicineType: medicineType.dbValue,
        dosage: Value(dosage),
        scheduledAt: Value(scheduledAt),
        isActive: Value(isActive),
        gapHours: Value(gapHours),
      ),
    );
  }

  /// Update a reminder from a domain model.
  Future<bool> updateReminder(Reminder reminder) {
    return _dao.updateReminder(
      RemindersCompanion(
        id: Value(reminder.id),
        chainId: Value(reminder.chainId),
        medicineName: Value(reminder.medicineName),
        medicineType: Value(reminder.medicineType.dbValue),
        dosage: Value(reminder.dosage),
        scheduledAt: Value(reminder.scheduledAt),
        isActive: Value(reminder.isActive),
        gapHours: Value(reminder.gapHours),
      ),
    );
  }

  /// Delete a reminder by ID.
  Future<int> deleteReminder(int id) => _dao.deleteReminder(id);

  // --------------- Mapping ---------------

  Reminder _fromRow(ReminderRow row) => Reminder(
    id: row.id,
    chainId: row.chainId,
    medicineName: row.medicineName,
    medicineType: MedicineType.fromDbString(row.medicineType),
    dosage: row.dosage,
    scheduledAt: row.scheduledAt,
    isActive: row.isActive,
    gapHours: row.gapHours,
  );
}
