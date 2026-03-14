import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Alarm time hero: 64px time + 32px medicine name in white.
class AlarmTimeHero extends StatelessWidget {
  const AlarmTimeHero({
    required this.time,
    required this.medicineName,
    super.key,
  });

  final String time;
  final String medicineName;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Time to take $medicineName at $time',
      sortKey: const OrdinalSortKey(0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: AppTypography.alarmTime.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            medicineName,
            style: AppTypography.heroMedicine.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
