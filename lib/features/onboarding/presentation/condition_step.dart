import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';

/// Data class for condition options displayed on this screen.
class _ConditionOption {
  const _ConditionOption({
    required this.key,
    required this.name,
    required this.description,
    required this.icon,
    this.isManual = false,
  });

  final String key;
  final String name;
  final String description;
  final IconData icon;
  final bool isManual;
}

/// The available condition options.
const List<_ConditionOption> _conditions = [
  _ConditionOption(
    key: 'diabetes',
    name: 'Diabetes',
    description: 'Insulin and oral medication linked to meals',
    icon: Icons.bloodtype,
  ),
  _ConditionOption(
    key: 'blood_pressure',
    name: 'Blood Pressure',
    description:
        'Morning and evening blood pressure medication',
    icon: Icons.monitor_heart,
  ),
  _ConditionOption(
    key: 'school_morning',
    name: 'School Morning',
    description:
        "Child's morning routine with medication",
    icon: Icons.school,
  ),
  _ConditionOption(
    key: 'other',
    name: 'Other / Manual Setup',
    description: 'Add your own medicines manually',
    icon: Icons.edit_note,
    isManual: true,
  ),
];

/// Step 1: Condition selection.
///
/// User picks a health condition to get template suggestions,
/// or selects "Other" for manual setup (ONBD-02).
class ConditionStep extends ConsumerWidget {
  /// Creates a [ConditionStep].
  const ConditionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier =
        ref.read(onboardingNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            'What do you need help with?',
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We'll suggest a medication schedule for you.",
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _conditions.length,
            itemBuilder: (context, index) {
              final condition = _conditions[index];
              return Semantics(
                button: true,
                label:
                    'Select ${condition.name} — '
                    '${condition.description}',
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _onTap(
                      context,
                      notifier,
                      condition,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            condition.icon,
                            size: 40,
                            color:
                                theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  condition.name,
                                  style: theme
                                      .textTheme
                                      .titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  condition.description,
                                  style: theme
                                      .textTheme
                                      .bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 28,
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onTap(
    BuildContext context,
    OnboardingNotifier notifier,
    _ConditionOption condition,
  ) {
    if (condition.isManual) {
      notifier
        ..skipTemplate()
        ..goToStep(OnboardingStep.anchors);
      context.go(
        '${AppRoutes.onboarding}/${AppRoutes.anchors}',
      );
    } else {
      notifier
        ..selectCondition(condition.key)
        ..goToStep(OnboardingStep.template);
      context.go(
        '${AppRoutes.onboarding}/${AppRoutes.template}',
      );
    }
  }
}
