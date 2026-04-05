import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:memo_care/core/theme/app_typography.dart';

/// Alarm time hero: reminder label + 64px time + date line.
class AlarmTimeHero extends StatelessWidget {
  const AlarmTimeHero({
    required this.time,
    required this.medicineName,
    this.dateText,
    super.key,
  });

  final String time;
  final String medicineName;
  final String? dateText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Time to take $medicineName at $time',
      sortKey: const OrdinalSortKey(0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Reminder',
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: AppTypography.alarmTime.copyWith(
              color: Colors.white,
            ),
          ),
          if (dateText != null) ...[
            const SizedBox(height: 6),
            Text(
              dateText!,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
