import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';

/// Condition option data.
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

const _conditions = [
  _ConditionOption(
    key: 'diabetes',
    name: 'Diabetes',
    description: 'Insulin and oral medication linked to meals',
    icon: Icons.bloodtype,
  ),
  _ConditionOption(
    key: 'blood_pressure',
    name: 'Blood Pressure',
    description: 'Morning and evening blood pressure medication',
    icon: Icons.monitor_heart,
  ),
  _ConditionOption(
    key: 'school_morning',
    name: 'School Morning',
    description: "Child's morning routine with medication",
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

/// Page 2 — Condition selection.
///
/// Selecting a condition (non-manual) advances to the Template
/// page. Selecting "Other" jumps past the Template page to the
/// Anchors page directly.
class ConditionPage extends ConsumerWidget {
  /// Creates a [ConditionPage].
  const ConditionPage({
    required this.stepLabel,
    required this.onNext,
    required this.onSkipTemplate,
    super.key,
  });

  /// E.g. 'Step 2 of 7'.
  final String stepLabel;

  /// Called when a condition is selected → go to Template page.
  final VoidCallback onNext;

  /// Called when "Other/Manual" is selected → skip to Anchors page.
  final VoidCallback onSkipTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(stepLabel),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    'What do you need help with?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We'll suggest a medication schedule for you.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                for (final cond in _conditions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Semantics(
                      button: true,
                      label: '${cond.name} — ${cond.description}',
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _onTap(context, ref, cond),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(
                                  cond.icon,
                                  size: 40,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cond.name,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cond.description,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 28,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(
    BuildContext context,
    WidgetRef ref,
    _ConditionOption cond,
  ) {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    if (cond.isManual) {
      notifier.skipTemplate();
      onSkipTemplate();
    } else {
      notifier.selectCondition(cond.key);
      onNext();
    }
  }
}
