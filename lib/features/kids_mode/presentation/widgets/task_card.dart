import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/features/kids_mode/domain/kids_models.dart';

/// Individual task card with animated completed/active/pending states.
///
/// - Completed: green check circle, strikethrough text.
/// - Active: coral-pink bottom border + ring glow.
/// - Pending: grey empty circle, muted style.
class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.quest,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  final Quest quest;
  final bool isActive;
  final VoidCallback onTap;

  IconData _categoryIcon(String category) {
    return switch (category) {
      'medicine' => Icons.medication_rounded,
      'meal' => Icons.restaurant_rounded,
      'health' => Icons.fitness_center_rounded,
      _ => Icons.task_alt_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDone = quest.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 72,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDone
              ? Border.all(
                  color: KidsColors.playfulGreen.withAlpha(80),
                  width: 2,
                )
              : isActive
              ? const Border(
                  bottom: BorderSide(
                    color: KidsColors.coralPink,
                    width: 4,
                  ),
                  left: BorderSide(
                    color: Colors.transparent,
                  ),
                  right: BorderSide(
                    color: Colors.transparent,
                  ),
                  top: BorderSide(
                    color: Colors.transparent,
                  ),
                )
              : Border.all(
                  color: const Color(0xFFF1F5F9),
                  width: 2,
                ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: KidsColors.coralPink.withAlpha(25),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Circle checkbox or done indicator.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isDone
                  ? Container(
                      key: const ValueKey('done'),
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: KidsColors.playfulGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    )
                  : Container(
                      key: const ValueKey('pending'),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? KidsColors.coralPink
                              : const Color(0xFFE2E8F0),
                          width: 4,
                        ),
                      ),
                      child: isActive
                          ? Icon(
                              _categoryIcon(quest.category),
                              color: KidsColors.coralPink,
                              size: 22,
                            )
                          : null,
                    ),
            ),
            const SizedBox(width: 14),
            // Task name.
            Expanded(
              child: Text(
                quest.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: isDone
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Time label.
            Text(
              quest.time,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDone
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
