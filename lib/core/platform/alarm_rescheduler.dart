import 'package:flutter/widgets.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';

/// Entry point called by the native boot/update broadcast
/// receivers via a headless FlutterEngine.
///
/// This function:
/// 1. Opens a fresh Drift database
/// 2. Queries all pending reminders (scheduled_at > now)
/// 3. Reschedules each via AlarmScheduler
/// 4. Marks missed reminders for display on next app open
///
/// **MUST be a top-level function** and annotated with
/// `@pragma('vm:entry-point')` to survive tree-shaking in
/// release builds.
@pragma('vm:entry-point')
Future<void> rescheduleAlarmsOnBoot() async {
  // Ensure Flutter binding is initialized in headless mode.
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  try {
    final allReminders = await (db.select(db.reminders)
          ..where((r) => r.isActive.equals(true)))
        .get();

    final now = DateTime.now().toUtc();
    final scheduler = AlarmScheduler();

    for (final r in allReminders) {
      if (r.scheduledAt != null && r.scheduledAt!.isAfter(now)) {
        await scheduler.schedule(
          reminderId: r.id,
          fireAt: r.scheduledAt!,
          callbackHandle: alarmFiredCallback,
        );
      }
    }

    debugPrint('MemoCare: Boot rescheduler completed');
  } on Exception catch (e, st) {
    debugPrint(
      'MemoCare: Boot rescheduler failed: $e\n$st',
    );
  } finally {
    await db.close();
  }
}

/// Utility to detect if rescheduling is needed on app open.
///
/// Uses a heartbeat timestamp to catch cases where the boot
/// receiver failed or was killed by OEM battery management.
// ignore: unreachable_from_main
class AlarmRescheduler {
  /// Checks if rescheduling is needed based on heartbeat gap.
  ///
  /// Returns true if last heartbeat is > [maxGap] ago.
  // ignore: unreachable_from_main
  static Future<bool> isRescheduleNeeded({
    Duration maxGap = const Duration(minutes: 30),
  }) async {
    // TODO(phukon): Wire to SharedPreferences in Phase 04.
    return false;
  }

  /// Records a heartbeat. Call on every successful alarm fire
  /// and on every app resume.
  // ignore: unreachable_from_main
  static Future<void> recordHeartbeat() async {
    // TODO(phukon): Wire to SharedPreferences in Phase 04.
  }
}
