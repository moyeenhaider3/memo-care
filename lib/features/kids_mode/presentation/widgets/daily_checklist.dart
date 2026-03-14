import 'package:flutter/material.dart';
import 'package:memo_care/core/theme/app_colors.dart';
import 'package:memo_care/features/kids_mode/domain/kids_models.dart';
import 'package:memo_care/features/kids_mode/presentation/widgets/task_card.dart';

/// Column of [TaskCard] widgets for the daily quest checklist.
class DailyChecklist extends StatelessWidget {
  const DailyChecklist({
    required this.quests,
    required this.onComplete,
    super.key,
  });

  final List<Quest> quests;
  final ValueChanged<String> onComplete;

  @override
  Widget build(BuildContext context) {
    if (quests.isEmpty) {
      return Center(
        child: Text(
          'No quests for today!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: KidsColors.primary,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < quests.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          TaskCard(
            quest: quests[i],
            isActive:
                !quests[i].isCompleted &&
                (i == 0 || quests.sublist(0, i).every((q) => q.isCompleted)),
            onTap: () {
              if (!quests[i].isCompleted) {
                onComplete(quests[i].id);
              }
            },
          ),
        ],
      ],
    );
  }
}
