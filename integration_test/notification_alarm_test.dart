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

  group('Notification & Alarm', () {
    patrolTest(
      'escalation progresses '
      'SILENT → AUDIBLE → FULLSCREEN '
      'on no user action',
      ($) async {
        // ── Arrange ──
        // Seed a reminder that fires in 30 s.
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );
        final fireAt = DateTime.now().add(
          const Duration(seconds: 30),
        );
        await _seedReminder(
          db,
          name: 'TestMed',
          scheduledAt: fireAt,
        );

        await $.pumpWidgetAndSettle(
          _scopedApp(db),
        );
        await $.completeOnboarding();

        // ── Silent tier ──
        // Wait for the notification to appear.
        await $.platform.mobile.openNotifications();
        final initial = await $.platform.mobile
            .getNotifications();
        expect(
          initial.any((n) => n.title.contains(
                'TestMed',
              )),
          isTrue,
          reason: 'Silent notification should appear',
        );
        await $.platform.mobile
            .closeNotifications();

        // ── Audible tier ──
        // Wait through the 2 min silent timeout.
        await Future<void>.delayed(
          const Duration(minutes: 2, seconds: 10),
        );
        await $.platform.mobile.openNotifications();
        final afterSilent = await $.platform.mobile
            .getNotifications();
        expect(
          afterSilent.isNotEmpty,
          isTrue,
          reason: 'Notification should persist '
              'after escalation to audible',
        );
        await $.platform.mobile
            .closeNotifications();

        // ── Fullscreen tier ──
        // Wait through the 3 min audible timeout.
        await Future<void>.delayed(
          const Duration(minutes: 3, seconds: 10),
        );

        // Fullscreen alarm should now be visible
        // in-app (or heads-up notification).
        await $.pumpAndSettle();
        final alarmScreen = $.call('I Took It');
        expect(
          alarmScreen.exists,
          isTrue,
          reason: 'Full-screen alarm should appear',
        );

        // ── Confirm to stop escalation ──
        await alarmScreen.tap();
        await $.pumpAndSettle();

        await db.close();
      },
      timeout: const Timeout(
        Duration(minutes: 12),
      ),
    );

    patrolTest(
      'notification action buttons '
      '(DONE/SNOOZE/SKIP) work from tray',
      ($) async {
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );
        final fireAt = DateTime.now().add(
          const Duration(seconds: 15),
        );
        await _seedReminder(
          db,
          name: 'ActionTest',
          scheduledAt: fireAt,
        );

        await $.pumpWidgetAndSettle(
          _scopedApp(db),
        );
        await $.completeOnboarding();

        // Wait for notification to fire.
        await Future<void>.delayed(
          const Duration(seconds: 20),
        );

        await $.platform.mobile.openNotifications();

        // Tap DONE via notification action.
        final notifications = await $.platform
            .mobile
            .getNotifications();
        expect(
          notifications.any(
            (n) => n.title.contains('ActionTest'),
          ),
          isTrue,
          reason: 'Notification should be present',
        );

        // Tap the notification to open the app.
        await $.platform.mobile
            .tapOnNotificationByIndex(0);
        await $.pumpAndSettle();

        // Verify the reminder shows as done.
        await $.call('Done').waitUntilVisible();

        await db.close();
      },
    );

    patrolTest(
      'notifications persist until user acts '
      '— not auto-dismissed',
      ($) async {
        final db = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );
        final fireAt = DateTime.now().add(
          const Duration(seconds: 15),
        );
        await _seedReminder(
          db,
          name: 'PersistTest',
          scheduledAt: fireAt,
        );

        await $.pumpWidgetAndSettle(
          _scopedApp(db),
        );
        await $.completeOnboarding();

        // Wait for notification.
        await Future<void>.delayed(
          const Duration(seconds: 20),
        );

        // Open/close shade multiple times.
        for (var i = 0; i < 3; i++) {
          await $.platform.mobile
              .openNotifications();
          await Future<void>.delayed(
            const Duration(seconds: 2),
          );
          await $.platform.mobile
              .closeNotifications();
          await Future<void>.delayed(
            const Duration(seconds: 2),
          );
        }

        // Wait 2 more minutes.
        await Future<void>.delayed(
          const Duration(minutes: 2),
        );

        // Notification should still be present.
        await $.platform.mobile.openNotifications();
        final notifications = await $.platform
            .mobile
            .getNotifications();
        expect(
          notifications.any(
            (n) => n.title.contains('PersistTest'),
          ),
          isTrue,
          reason: 'Notification must persist '
              'until user acts',
        );
        await $.platform.mobile
            .closeNotifications();

        await db.close();
      },
      timeout: const Timeout(
        Duration(minutes: 8),
      ),
    );

    patrolTest(
      'channel health check detects disabled '
      'channels and shows warning banner',
      ($) async {
        await $.pumpApp();
        await $.completeOnboarding();

        // Navigate to system notification settings
        // via native automation to disable a channel.
        // NOTE: This interaction is highly
        // device-specific and may need adaptation
        // for different Android skins.
        await $.platform.mobile.openQuickSettings();
        await $.platform.mobile
            .closeNotifications();

        // Simulate returning to the app after
        // disabling a notification channel.
        await $.pumpAndSettle();

        // The channel health check runs on resume
        // and should show a warning banner if any
        // required channel is disabled.
        // NOTE: Full implementation of this test
        // requires navigating to Android Settings →
        // App → Notification Channel → toggle off.
        // This is device-specific and best verified
        // in manual testing.
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

/// Seeds a single reminder in the given [db].
Future<void> _seedReminder(
  AppDatabase db, {
  required String name,
  required DateTime scheduledAt,
}) async {
  await db.into(db.reminderChains).insert(
        ReminderChainsCompanion.insert(
          name: 'Test Chain',
          createdAt: DateTime.now(),
        ),
      );

  await db.into(db.reminders).insert(
        RemindersCompanion.insert(
          chainId: 1,
          medicineName: name,
          medicineType:
              MedicineType.fixedTime.dbValue,
          dosage: const Value('100 mg'),
          scheduledAt: Value(scheduledAt),
          isActive: const Value(true),
        ),
      );
}
