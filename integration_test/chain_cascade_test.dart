import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/app.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:patrol/patrol.dart';

import 'test_helpers.dart';

void main() {
  patrolSetUp(testSetUp);
  patrolTearDown(testTearDown);

  group('Chain Cascade', () {
    patrolTest(
      'confirming DONE on chain node fires '
      'downstream notification',
      ($) async {
        // ── Arrange: seed a 2-node chain ──
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );
        await _seedDiabeticChain(db);

        await $.pumpWidgetAndSettle(
          _scopedApp(db),
        );

        // ── Act: confirm the first node ──
        // The hero card should show the upstream
        // reminder (insulin) as next pending.
        await $.call('Insulin').waitUntilVisible();
        await $.call('I Took It').tap();
        await $.pumpAndSettle();

        // ── Assert: downstream node becomes pending ──
        // After confirming insulin, metformin should
        // appear as the next pending reminder.
        await $.call('Metformin').waitUntilVisible();

        await db.close();
      },
    );

    patrolTest(
      'skipping chain node suspends all '
      'downstream nodes',
      ($) async {
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );
        await _seedDiabeticChain(db);

        await $.pumpWidgetAndSettle(
          _scopedApp(db),
        );

        // ── Act: skip the first node ──
        await $.call('Insulin').waitUntilVisible();
        await $.call('Skip').tap();
        await $.pumpAndSettle();

        // ── Assert: home shows Skipped status ──
        await $.call('Skipped').waitUntilVisible();
      },
    );

    patrolTest(
      'missed reminders surface on app open',
      ($) async {
        // ── Arrange: seed a past-due reminder ──
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );
        await _seedPastDueReminder(db);

        await $.pumpWidgetAndSettle(
          _scopedApp(db),
        );
        await $.pumpAndSettle();

        // ── Assert: missed reminder sheet appears ──
        await $.call('Missed Reminders').waitUntilVisible();
      },
    );
  });
}

// ── Helpers ────────────────────────────────────────────

/// Wraps [MemoCareApp] in a [ProviderScope] with the
/// given test [db].
Widget _scopedApp(AppDatabase db) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const MemoCareApp(),
  );
}

/// Seeds a 2-node chain: insulin → metformin.
Future<void> _seedDiabeticChain(AppDatabase db) async {
  // Create the chain.
  await db
      .into(db.reminderChains)
      .insert(
        ReminderChainsCompanion.insert(
          name: 'Diabetic Morning',
          createdAt: DateTime.now(),
        ),
      );

  // Create reminders.
  final now = DateTime.now();
  final insulinTime = now.add(
    const Duration(minutes: 1),
  );

  await db
      .into(db.reminders)
      .insert(
        RemindersCompanion.insert(
          chainId: 1,
          medicineName: 'Insulin',
          medicineType: MedicineType.beforeMeal.dbValue,
          dosage: const Value('10 units'),
          scheduledAt: Value(insulinTime),
          isActive: const Value(true),
        ),
      );

  await db
      .into(db.reminders)
      .insert(
        RemindersCompanion.insert(
          chainId: 1,
          medicineName: 'Metformin',
          medicineType: MedicineType.afterMeal.dbValue,
          dosage: const Value('500 mg'),
          // Not scheduled until insulin is confirmed.
          isActive: const Value(false),
        ),
      );

  // Edge: insulin(1) → metformin(2)
  await db
      .into(db.chainEdges)
      .insert(
        ChainEdgesCompanion.insert(
          chainId: 1,
          sourceId: 1,
          targetId: 2,
        ),
      );
}

/// Seeds a single reminder that is past-due.
Future<void> _seedPastDueReminder(
  AppDatabase db,
) async {
  await db
      .into(db.reminderChains)
      .insert(
        ReminderChainsCompanion.insert(
          name: 'Morning Routine',
          createdAt: DateTime.now(),
        ),
      );

  final pastTime = DateTime.now().subtract(
    const Duration(hours: 2),
  );
  await db
      .into(db.reminders)
      .insert(
        RemindersCompanion.insert(
          chainId: 1,
          medicineName: 'Aspirin',
          medicineType: MedicineType.fixedTime.dbValue,
          dosage: const Value('75 mg'),
          scheduledAt: Value(pastTime),
          isActive: const Value(true),
        ),
      );
}
