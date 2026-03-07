// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirmation_dao.dart';

// ignore_for_file: type=lint
mixin _$ConfirmationDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReminderChainsTable get reminderChains => attachedDatabase.reminderChains;
  $RemindersTable get reminders => attachedDatabase.reminders;
  $ConfirmationsTable get confirmations => attachedDatabase.confirmations;
  ConfirmationDaoManager get managers => ConfirmationDaoManager(this);
}

class ConfirmationDaoManager {
  final _$ConfirmationDaoMixin _db;
  ConfirmationDaoManager(this._db);
  $$ReminderChainsTableTableManager get reminderChains =>
      $$ReminderChainsTableTableManager(
        _db.attachedDatabase,
        _db.reminderChains,
      );
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
  $$ConfirmationsTableTableManager get confirmations =>
      $$ConfirmationsTableTableManager(_db.attachedDatabase, _db.confirmations);
}
