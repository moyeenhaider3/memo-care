import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:memo_care/core/database/type_converters.dart';
import 'package:memo_care/features/anchors/data/anchor_dao.dart';
import 'package:memo_care/features/chain_engine/data/chain_dao.dart';
import 'package:memo_care/features/confirmation/data/confirmation_dao.dart';
import 'package:memo_care/features/reminders/data/reminder_dao.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions — match ARCHITECTURE.md §9 exactly
// ---------------------------------------------------------------------------

/// Chains group related reminders into a DAG structure.
@DataClassName('ReminderChainRow')
class ReminderChains extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer().map(const DateTimeConverter())();
}

/// Individual medication reminders belonging to a chain.
@DataClassName('ReminderRow')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chainId => integer().references(ReminderChains, #id)();
  TextColumn get medicineName => text()();
  TextColumn get medicineType => text()();
  TextColumn get dosage => text().nullable()();
  IntColumn get scheduledAt =>
      integer().nullable().map(const DateTimeConverter())();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  IntColumn get gapHours => integer().nullable()();
}

/// DAG edges connecting source → target reminders within a chain.
@DataClassName('ChainEdgeRow')
class ChainEdges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chainId => integer().references(ReminderChains, #id)();

  @ReferenceName('sourceEdges')
  IntColumn get sourceId => integer().references(Reminders, #id)();

  @ReferenceName('targetEdges')
  IntColumn get targetId => integer().references(Reminders, #id)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sourceId, targetId},
  ];
}

/// Logs each confirmation action (done / snoozed / skipped).
@DataClassName('ConfirmationRow')
class Confirmations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reminderId => integer().references(Reminders, #id)();
  TextColumn get state => text()();
  IntColumn get confirmedAt => integer().map(const DateTimeConverter())();
  IntColumn get snoozeUntil =>
      integer().nullable().map(const DateTimeConverter())();
}

/// Meal anchor times used to resolve fuzzy scheduling ("after lunch").
@DataClassName('MealAnchorRow')
class MealAnchors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mealType => text()();
  IntColumn get defaultTime => integer()();
  IntColumn get confirmedAt =>
      integer().nullable().map(const DateTimeConverter())();
}

// ---------------------------------------------------------------------------
// Database class
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    ReminderChains,
    Reminders,
    ChainEdges,
    Confirmations,
    MealAnchors,
  ],
  daos: [
    ChainDao,
    ReminderDao,
    ConfirmationDao,
    AnchorDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates a new [AppDatabase] with the default file-based connection.
  AppDatabase() : super(_openConnection());

  /// Test constructor — accepts an in-memory or custom executor.
  AppDatabase.forTesting(super.e);

  /// Schema version. Increment for each migration.
  /// Migration framework from day 1 (P-03).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Future migrations go here.
      // Example:
      // if (from < 2) {
      //   await m.addColumn(reminders, reminders.newColumn);
      // }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'memo_care.sqlite'));

    // Required on Android to find the bundled libsqlite3.so
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

    return NativeDatabase.createInBackground(file);
  });
}
