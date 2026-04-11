import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/core/platform/audio_service.dart';

/// Provides the audio service used by escalation (alarm loop).
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

/// Provides a singleton [AlarmScheduler] instance.
///
/// [AlarmScheduler.initialize()] must be called in app bootstrap
/// before any provider reads this.
final alarmSchedulerProvider = Provider<AlarmScheduler>((ref) {
  return AlarmScheduler();
});
