import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Groups today's reminders by hour for the full schedule view.
class HourlyGroup {
  const HourlyGroup({required this.hour, required this.reminders});

  /// The hour (0-23).
  final int hour;

  /// Reminders scheduled in this hour.
  final List<Reminder> reminders;
}

/// Schedule statistics for status chips.
class ScheduleStats {
  const ScheduleStats({
    required this.done,
    required this.pending,
    required this.missed,
  });

  final int done;
  final int pending;
  final int missed;
}

/// Provides today's reminders grouped by hour.
final hourlyGroupsProvider = Provider<List<HourlyGroup>>((ref) {
  final scheduleAsync = ref.watch(dailyScheduleNotifierProvider);
  final schedule = scheduleAsync.value;
  if (schedule == null) return [];

  final reminders = schedule.todayReminders;
  final groups = <int, List<Reminder>>{};

  for (final r in reminders) {
    final hour = r.scheduledAt?.toLocal().hour ?? 0;
    groups.putIfAbsent(hour, () => []).add(r);
  }

  final sortedHours = groups.keys.toList()..sort();
  return sortedHours
      .map((h) => HourlyGroup(hour: h, reminders: groups[h]!))
      .toList();
});

/// Provides schedule statistics for status chips.
final scheduleStatsProvider = Provider<ScheduleStats>((ref) {
  final scheduleAsync = ref.watch(dailyScheduleNotifierProvider);
  final schedule = scheduleAsync.value;
  if (schedule == null) {
    return const ScheduleStats(done: 0, pending: 0, missed: 0);
  }

  final missed = schedule.missedReminders.length;
  final total = schedule.todayReminders.length;
  // For now, done = 0 (will be accurate when confirmation state is tracked)
  // pending = total - missed
  return ScheduleStats(done: 0, pending: total - missed, missed: missed);
});
