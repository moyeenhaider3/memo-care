import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

/// Ramadan screen header with crescent moon icon + day counter.
class RamadanHeader extends StatelessWidget {
  const RamadanHeader({
    required this.fastingDay,
    required this.totalDays,
    super.key,
  });

  final int fastingDay;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Gold moon icon.
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: RamadanColors.primaryGold.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.brightness_3_rounded,
            color: RamadanColors.primaryGold,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ramadan Mode',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Day $fastingDay of $totalDays',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
