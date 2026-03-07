import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

/// Wraps [AndroidAlarmManager] to schedule exact alarms for reminders.
///
/// Each alarm fires a top-level callback in a background isolate.
/// Only the reminder ID (int) is passed across the isolate boundary.
///
/// Usage:
/// ```dart
/// await AlarmScheduler.initialize();
/// final scheduler = AlarmScheduler();
/// await scheduler.schedule(
///   reminderId: 42,
///   fireAt: DateTime.now().add(Duration(hours: 1)),
///   callbackHandle: alarmFiredCallback,
/// );
/// ```
class AlarmScheduler {
  /// Must be called once at app startup before any scheduling.
  static Future<bool> initialize() async {
    return AndroidAlarmManager.initialize();
  }

  /// Schedules an exact alarm for [reminderId] at [fireAt].
  ///
  /// Uses `oneShotAt` with `exact: true` and `allowWhileIdle: true`
  /// to ensure delivery in Doze mode.
  /// The alarm ID equals [reminderId] for 1:1 cancel mapping.
  ///
  /// [callbackHandle] must be a top-level or static function.
  Future<bool> schedule({
    required int reminderId,
    required DateTime fireAt,
    required Function callbackHandle,
  }) async {
    // Ensure fire time is in the future.
    final now = DateTime.now();
    final adjustedFireAt = fireAt.isBefore(now)
        ? now.add(const Duration(seconds: 5))
        : fireAt;

    return AndroidAlarmManager.oneShotAt(
      adjustedFireAt,
      reminderId,
      callbackHandle,
      exact: true,
      allowWhileIdle: true,
      wakeup: true,
    );
  }

  /// Schedules multiple reminders at once.
  ///
  /// Returns the count of successfully scheduled alarms.
  Future<int> scheduleAll({
    required List<({int reminderId, DateTime fireAt})> reminders,
    required Function callbackHandle,
  }) async {
    var successCount = 0;
    for (final r in reminders) {
      final ok = await schedule(
        reminderId: r.reminderId,
        fireAt: r.fireAt,
        callbackHandle: callbackHandle,
      );
      if (ok) successCount++;
    }
    return successCount;
  }

  /// Cancels the alarm for the given [reminderId].
  Future<bool> cancel(int reminderId) async {
    return AndroidAlarmManager.cancel(reminderId);
  }

  /// Cancels alarms for all provided reminder IDs.
  Future<int> cancelAll(List<int> reminderIds) async {
    var cancelCount = 0;
    for (final id in reminderIds) {
      final ok = await cancel(id);
      if (ok) cancelCount++;
    }
    return cancelCount;
  }
}
