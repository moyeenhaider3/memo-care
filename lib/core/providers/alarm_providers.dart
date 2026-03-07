import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';

/// Provides a singleton [AlarmScheduler] instance.
///
/// [AlarmScheduler.initialize()] must be called in app bootstrap
/// before any provider reads this.
final alarmSchedulerProvider = Provider<AlarmScheduler>((ref) {
  return AlarmScheduler();
});
