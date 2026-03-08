import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';

/// Internal config for a meal row.
class _MealRow {
  const _MealRow({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

/// Step 3: Meal anchor time configuration.
///
/// User sets their typical breakfast, lunch, and dinner times.
/// These anchor times drive the scheduling of meal-linked
/// medicines.
class AnchorStep extends ConsumerStatefulWidget {
  /// Creates an [AnchorStep].
  const AnchorStep({super.key});

  @override
  ConsumerState<AnchorStep> createState() => _AnchorStepState();
}

class _AnchorStepState extends ConsumerState<AnchorStep> {
  static const Map<String, int> _defaultAnchors = {
    'breakfast': 480, // 08:00
    'lunch': 780, // 13:00
    'dinner': 1140, // 19:00
  };

  static const List<_MealRow> _mealConfig = [
    _MealRow(
      key: 'breakfast',
      label: 'Breakfast',
      icon: Icons.free_breakfast,
    ),
    _MealRow(
      key: 'lunch',
      label: 'Lunch',
      icon: Icons.lunch_dining,
    ),
    _MealRow(
      key: 'dinner',
      label: 'Dinner',
      icon: Icons.dinner_dining,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingNotifierProvider);
      final notifier =
          ref.read(onboardingNotifierProvider.notifier);
      for (final entry in _defaultAnchors.entries) {
        if (!state.mealAnchorDefaults
            .containsKey(entry.key)) {
          notifier.setMealAnchor(entry.key, entry.value);
        }
      }
    });
  }

  String _formatTime(int minutesFromMidnight) {
    final hours = minutesFromMidnight ~/ 60;
    final minutes = minutesFromMidnight % 60;
    final period = hours >= 12 ? 'PM' : 'AM';
    final displayHours = hours == 0
        ? 12
        : (hours > 12 ? hours - 12 : hours);
    return '${displayHours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(
    String mealKey,
    int currentMinutes,
  ) async {
    final initialTime = TimeOfDay(
      hour: currentMinutes ~/ 60,
      minute: currentMinutes % 60,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Set '
          '${mealKey[0].toUpperCase()}'
          '${mealKey.substring(1)} time',
    );
    if (picked != null && mounted) {
      final minutes = picked.hour * 60 + picked.minute;
      ref
          .read(onboardingNotifierProvider.notifier)
          .setMealAnchor(mealKey, minutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingNotifierProvider);
    final anchors = state.mealAnchorDefaults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            'Set your meal times',
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'These times help us schedule your medication '
          'reminders around meals.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        for (final meal in _mealConfig) ...[
          Semantics(
            button: true,
            label: '${meal.label} time: '
                '${_formatTime(
                  anchors[meal.key] ??
                      _defaultAnchors[meal.key]!,
                )}'
                '. Tap to change.',
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _pickTime(
                  meal.key,
                  anchors[meal.key] ??
                      _defaultAnchors[meal.key]!,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        meal.icon,
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          meal.label,
                          style:
                              theme.textTheme.titleSmall,
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme
                              .colorScheme
                              .primaryContainer,
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatTime(
                            anchors[meal.key] ??
                                _defaultAnchors[
                                    meal.key]!,
                          ),
                          style: theme
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                            color: theme
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label: 'Continue to medicines',
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(onboardingNotifierProvider.notifier)
                    .goToStep(OnboardingStep.medicines);
                context.go(
                  '${AppRoutes.onboarding}/'
                  '${AppRoutes.medicines}',
                );
              },
              child: const Text('Continue'),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
