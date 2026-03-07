import 'package:flutter/foundation.dart';

/// A computed schedule update for a single reminder.
///
/// Produced by `AnchorResolver.resolve()` — each instance
/// tells the caller to update the given reminder's
/// `scheduled_at` to the computed [scheduledAt].
///
/// This is the return value bridge between pure domain
/// computation and side-effectful operations (Drift update
/// + AlarmScheduler).
@immutable
class ReminderScheduleUpdate {
  /// Creates a [ReminderScheduleUpdate].
  const ReminderScheduleUpdate({
    required this.reminderId,
    required this.scheduledAt,
  });

  /// The ID of the reminder whose schedule should be
  /// updated.
  final int reminderId;

  /// The computed fire time for this reminder.
  ///
  /// Always UTC — matches Drift `DateTimeConverter`
  /// convention.
  final DateTime scheduledAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderScheduleUpdate &&
          reminderId == other.reminderId &&
          scheduledAt == other.scheduledAt;

  @override
  int get hashCode => Object.hash(reminderId, scheduledAt);

  @override
  String toString() =>
      'ReminderScheduleUpdate('
      'reminderId: $reminderId, '
      'scheduledAt: $scheduledAt)';
}
