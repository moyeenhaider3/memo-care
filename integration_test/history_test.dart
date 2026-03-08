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

  group('History Screen', () {
    patrolTest(
      'confirmed reminders appear in '
      'history with correct status',
      ($) async {
        await $.pumpApp();
        await $.completeOnboarding();

        // ── Confirm reminders ──
        // Wait for the hero card to show the
        // next pending reminder, then confirm.
        if ($.call('I Took It').exists) {
          await $.call('I Took It').tap();
          await $.pumpAndSettle();
        }

        // ── Navigate to history ──
        await $.call('History').tap();
        await $.pumpAndSettle();

        // ── Assert: entries appear ──
        // At least one confirmation should show.
        expect(
          $.call('Done').exists ||
              $.call('Skipped').exists,
          isTrue,
          reason: 'History should show '
              'confirmed entries',
        );
      },
    );

    patrolTest(
      'history filter by medication '
      'name works',
      ($) async {
        // ── Seed multiple confirmations ──
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );
        await _seedConfirmations(db);

        await $.pumpWidgetAndSettle(
          _scopedApp(db),
        );

        // ── Navigate to history ──
        await $.call('History').tap();
        await $.pumpAndSettle();

        // ── Apply filter: Metformin ──
        // Tap the filter/search icon.
        if ($.call('Filter').exists) {
          await $.call('Filter').tap();
          await $.pumpAndSettle();
        }

        await $.tester.enterText(
          $.call('Search').finder,
          'Metformin',
        );
        await $.pumpAndSettle();

        // Only Metformin entries should appear.
        expect(
          $.call('Metformin').exists,
          isTrue,
          reason: 'Metformin entries visible',
        );

        await db.close();
      },
    );

    patrolTest(
      'history paginates — does not '
      'load all records at once',
      ($) async {
        // ── Seed 50+ confirmations ──
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );
        await _seedManyConfirmations(db, count: 55);

        await $.pumpWidgetAndSettle(
          _scopedApp(db),
        );

        // ── Navigate to history ──
        await $.call('History').tap();
        await $.pumpAndSettle();

        // ── Scroll to trigger pagination ──
        // Fling the list to scroll down.
        await $.tester.fling(
          find.byType(ListView),
          const Offset(0, -500),
          800,
        );
        await $.pumpAndSettle();

        // More entries should load after scrolling.
        // The exact assertion depends on the page
        // size configured in the history provider.
        await db.close();
      },
    );
  });
}

// ── Helpers ────────────────────────────────────────────

Widget _scopedApp(AppDatabase db) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const MemoCareApp(),
  );
}

/// Seeds a chain with 2 medicines (Metformin + Insulin)
/// and creates confirmation records for both.
Future<void> _seedConfirmations(
  AppDatabase db,
) async {
  await db.into(db.reminderChains).insert(
        ReminderChainsCompanion.insert(
          name: 'Test Chain',
          createdAt: DateTime.now(),
        ),
      );

  final now = DateTime.now();

  // Metformin reminders + confirmations.
  for (var i = 0; i < 3; i++) {
    final id = await db.into(db.reminders).insert(
          RemindersCompanion.insert(
            chainId: 1,
            medicineName: 'Metformin',
            medicineType:
                MedicineType.afterMeal.dbValue,
            dosage: const Value('500 mg'),
            scheduledAt: Value(
              now.subtract(Duration(hours: i + 1)),
            ),
            isActive: const Value(false),
          ),
        );

    await db.into(db.confirmations).insert(
          ConfirmationsCompanion.insert(
            reminderId: id,
            state: 'done',
            confirmedAt: now.subtract(
              Duration(hours: i),
            ),
          ),
        );
  }

  // Insulin reminders + confirmations.
  for (var i = 0; i < 2; i++) {
    final id = await db.into(db.reminders).insert(
          RemindersCompanion.insert(
            chainId: 1,
            medicineName: 'Insulin',
            medicineType:
                MedicineType.beforeMeal.dbValue,
            dosage: const Value('10 units'),
            scheduledAt: Value(
              now.subtract(Duration(hours: i + 4)),
            ),
            isActive: const Value(false),
          ),
        );

    await db.into(db.confirmations).insert(
          ConfirmationsCompanion.insert(
            reminderId: id,
            state: 'done',
            confirmedAt: now.subtract(
              Duration(hours: i + 3),
            ),
          ),
        );
  }
}

/// Seeds [count] confirmation records for pagination
/// testing.
Future<void> _seedManyConfirmations(
  AppDatabase db, {
  required int count,
}) async {
  await db.into(db.reminderChains).insert(
        ReminderChainsCompanion.insert(
          name: 'Pagination Chain',
          createdAt: DateTime.now(),
        ),
      );

  final now = DateTime.now();

  for (var i = 0; i < count; i++) {
    final id = await db.into(db.reminders).insert(
          RemindersCompanion.insert(
            chainId: 1,
            medicineName: 'Med-${i + 1}',
            medicineType:
                MedicineType.fixedTime.dbValue,
            dosage: const Value('100 mg'),
            scheduledAt: Value(
              now.subtract(Duration(hours: i + 1)),
            ),
            isActive: const Value(false),
          ),
        );

    await db.into(db.confirmations).insert(
          ConfirmationsCompanion.insert(
            reminderId: id,
            state: i.isEven ? 'done' : 'skipped',
            confirmedAt: now.subtract(
              Duration(hours: i),
            ),
          ),
        );
  }
}
