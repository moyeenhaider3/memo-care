import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/daily_schedule/application/full_schedule_providers.dart';
import 'package:memo_care/features/fasting/application/fasting_notifier.dart';
import 'package:memo_care/features/fasting/application/fasting_state.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/hourly_timeline_item.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/schedule_empty_state.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/schedule_status_chips.dart';

/// Today's Full Schedule screen — hourly timeline view.
///
/// Mounted at /schedule (shell branch index 1).
class TodaysFullScheduleScreen extends ConsumerWidget {
  const TodaysFullScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(dailyScheduleNotifierProvider);
    final stats = ref.watch(scheduleStatsProvider);
    final hourlyGroups = ref.watch(hourlyGroupsProvider);
    final fasting = ref.watch(fastingNotifierProvider);
    final dateText = DateFormat.yMMMd().format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Schedule",
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              dateText,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Failed to load schedule',
            style: AppTypography.bodyLarge,
          ),
        ),
        data: (schedule) {
          if (schedule.todayReminders.isEmpty) {
            return const ScheduleEmptyState();
          }

          return Column(
            children: [
              ScheduleStatusChips(stats: stats),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: _itemCount(hourlyGroups),
                  itemBuilder: (context, index) {
                    return _buildItem(hourlyGroups, index, fasting);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _itemCount(List<HourlyGroup> groups) {
    // Each group has a header + N reminder items
    var count = 0;
    for (final g in groups) {
      count += 1 + g.reminders.length;
    }
    return count;
  }

  Widget _buildItem(
    List<HourlyGroup> groups,
    int index,
    FastingState fasting,
  ) {
    var current = 0;
    for (final group in groups) {
      if (index == current) {
        // Hour header
        final hourFormat = DateFormat.j();
        final time = DateTime(2024, 1, 1, group.hour);
        final sehriTime = fasting.sehriTime;
        final iftarTime = fasting.iftarTime;
        final showSehriMarker = fasting.isActive &&
          sehriTime != null &&
          sehriTime.hour == group.hour;
        final showIftarMarker = fasting.isActive &&
          iftarTime != null &&
          iftarTime.hour == group.hour;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hourFormat.format(time),
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (showSehriMarker || showIftarMarker)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  height: 2,
                  width: double.infinity,
                  color: const Color(0xFFF0A500),
                ),
            ],
          ),
        );
      }
      current++;

      for (var i = 0; i < group.reminders.length; i++) {
        if (index == current) {
          return HourlyTimelineItem(reminder: group.reminders[i]);
        }
        current++;
      }
    }
    return const SizedBox.shrink();
  }
}
