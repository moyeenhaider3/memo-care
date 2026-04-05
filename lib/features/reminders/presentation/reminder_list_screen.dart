import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_spacing.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/daily_schedule/presentation/widgets/reminder_list_tile.dart';
import 'package:memo_care/features/reminders/application/providers.dart';

/// Screen listing all active reminders (Tab placeholder until full list view).
class ReminderListScreen extends ConsumerWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(activeRemindersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'All Reminders',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 72,
                    color: AppColors.textSecondary.withAlpha(80),
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  Text(
                    'No reminders yet',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to add your first reminder',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            itemCount: reminders.length,
            // ignore: unnecessary_underscores // workaround
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.cardGap),
            itemBuilder: (context, index) {
              final r = reminders[index];
              return ReminderListTile(
                reminder: r,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error loading reminders',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.danger,
            ),
          ),
        ),
      ),
    );
  }
}
