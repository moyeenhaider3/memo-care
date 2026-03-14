import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';

/// Meal row config.
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

const _meals = [
  _MealRow(key: 'breakfast', label: 'Breakfast', icon: Icons.free_breakfast),
  _MealRow(key: 'lunch', label: 'Lunch', icon: Icons.lunch_dining),
  _MealRow(key: 'dinner', label: 'Dinner', icon: Icons.dinner_dining),
];

const _defaults = {
  'breakfast': 480, // 08:00
  'lunch': 780,     // 13:00
  'dinner': 1140,   // 19:00
};

/// Page 4 — Meal anchor time configuration.
class AnchorsPage extends ConsumerStatefulWidget {
  /// Creates an [AnchorsPage].
  const AnchorsPage({
    required this.stepLabel,
    required this.onNext,
    super.key,
  });

  /// E.g. 'Step 4 of 7'.
  final String stepLabel;

  /// Called when "Continue" is pressed.
  final VoidCallback onNext;

  @override
  ConsumerState<AnchorsPage> createState() => _AnchorsPageState();
}

class _AnchorsPageState extends ConsumerState<AnchorsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingNotifierProvider);
      final notifier = ref.read(onboardingNotifierProvider.notifier);
      for (final entry in _defaults.entries) {
        if (!state.mealAnchorDefaults.containsKey(entry.key)) {
          notifier.setMealAnchor(entry.key, entry.value);
        }
      }
    });
  }

  String _fmt(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${dh.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(String key, int current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      helpText: 'Set ${key[0].toUpperCase()}${key.substring(1)} time',
    );
    if (picked != null && mounted) {
      ref.read(onboardingNotifierProvider.notifier).setMealAnchor(
            key,
            picked.hour * 60 + picked.minute,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final anchors = ref.watch(onboardingNotifierProvider).mealAnchorDefaults;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.stepLabel),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      'Set your meal times',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These times help us schedule your medication '
                    'reminders around meals.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  for (final meal in _meals) ...[
                    Semantics(
                      button: true,
                      label:
                          '${meal.label} time: '
                          '${_fmt(anchors[meal.key] ?? _defaults[meal.key]!)}. '
                          'Tap to change.',
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _pickTime(
                            meal.key,
                            anchors[meal.key] ?? _defaults[meal.key]!,
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
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        theme.colorScheme.primaryContainer,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _fmt(
                                      anchors[meal.key] ??
                                          _defaults[meal.key]!,
                                    ),
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                      color: theme
                                          .colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: Semantics(
                button: true,
                label: 'Continue to medicines',
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
