// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_dao.dart';

// ignore_for_file: type=lint
mixin _$ChainDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReminderChainsTable get reminderChains => attachedDatabase.reminderChains;
  $RemindersTable get reminders => attachedDatabase.reminders;
  $ChainEdgesTable get chainEdges => attachedDatabase.chainEdges;
  ChainDaoManager get managers => ChainDaoManager(this);
}

class ChainDaoManager {
  final _$ChainDaoMixin _db;
  ChainDaoManager(this._db);
  $$ReminderChainsTableTableManager get reminderChains =>
      $$ReminderChainsTableTableManager(
        _db.attachedDatabase,
        _db.reminderChains,
      );
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
  $$ChainEdgesTableTableManager get chainEdges =>
      $$ChainEdgesTableTableManager(_db.attachedDatabase, _db.chainEdges);
}
