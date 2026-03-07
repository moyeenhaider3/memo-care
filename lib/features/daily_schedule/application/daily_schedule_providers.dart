import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Derived provider: just the next pending reminder (VIEW-02).
///
/// Only rebuilds when the next pending changes — not on every
/// status update. Used by the hero card widget.
final nextPendingReminderProvider = Provider<Reminder?>((ref) {
  return ref.watch(dailyScheduleNotifierProvider).value?.nextPending;
});

/// Derived provider: just the missed reminders list (VIEW-04).
///
/// Used by the missed reminders modal on app open.
final missedRemindersProvider = Provider<List<Reminder>>((ref) {
  return ref.watch(dailyScheduleNotifierProvider).value?.missedReminders ?? [];
});

/// Derived provider: today's reminders for the chronological
/// list (VIEW-01).
final todayRemindersProvider = Provider<List<Reminder>>((ref) {
  return ref.watch(dailyScheduleNotifierProvider).value?.todayReminders ?? [];
});

/// Whether there are any missed reminders — controls showing
/// the modal.
final hasMissedRemindersProvider = Provider<bool>((ref) {
  return ref.watch(missedRemindersProvider).isNotEmpty;
});
