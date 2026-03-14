import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';

/// Horizontal progress bar showing daily quest completion.
/// Gradient fill: coral → green. Animated width on updates.
class QuestProgressBar extends StatelessWidget {
  const QuestProgressBar({
    required this.completed,
    required this.total,
    required this.childName,
    super.key,
  });

  final int completed;
  final int total;
  final String childName;

  double get _fraction => total > 0 ? completed / total : 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Morning Quest 🎯',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  width: constraints.maxWidth * _fraction,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        KidsColors.primary,
                        KidsColors.playfulGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: KidsColors.playfulGreen,
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              '$childName has done $completed out of $total tasks',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
