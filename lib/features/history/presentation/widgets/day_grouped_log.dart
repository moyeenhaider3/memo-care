import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/core/theme/app_typography.dart';
import 'package:memo_care/features/history/domain/models/history_entry.dart';
import 'package:memo_care/features/history/presentation/widgets/history_card.dart';

/// Groups history entries by date with section headers.
class DayGroupedLog extends StatelessWidget {
  const DayGroupedLog({required this.entries, super.key});

  final List<HistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<HistoryEntry>>{};
    for (final entry in entries) {
      final key = DateFormat.yMMMEd().format(entry.scheduledAt.toLocal());
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    final dayKeys = grouped.keys.toList();

    return SliverList.builder(
      itemCount: dayKeys.length,
      itemBuilder: (context, index) {
        final dayLabel = dayKeys[index];
        final dayEntries = grouped[dayLabel]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dayLabel,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${dayEntries.length} items',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Day entries
            ...dayEntries.map(
              (e) => HistoryCard(entry: e),
            ),
          ],
        );
      },
    );
  }
}
