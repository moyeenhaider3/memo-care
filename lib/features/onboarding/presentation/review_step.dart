import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/fasting/application/fasting_notifier.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/templates/application/template_providers.dart';
import 'package:memo_care/features/templates/domain/models/template_pack.dart';

/// Step 5: Review and confirm the medication schedule.
///
/// Shows a summary of all onboarding selections and triggers
/// chain creation via `TemplateService` (template path) or a
/// synthetic pack (manual path).
class ReviewStep extends ConsumerStatefulWidget {
  /// Creates a [ReviewStep].
  const ReviewStep({super.key});

  @override
  ConsumerState<ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends ConsumerState<ReviewStep> {
  bool _isCreating = false;

  String _formatTime(int minutesFromMidnight) {
    final hours = minutesFromMidnight ~/ 60;
    final minutes = minutesFromMidnight % 60;
    final period = hours >= 12 ? 'PM' : 'AM';
    final displayHours = hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours);
    return '${displayHours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')} $period';
  }

  String _medicineTypeLabel(MedicineType type) {
    return switch (type) {
      MedicineType.beforeMeal => 'Before Meal',
      MedicineType.afterMeal => 'After Meal',
      MedicineType.fixedTime => 'Fixed Time',
      MedicineType.doseGap => 'Dose Gap',
      MedicineType.emptyStomach => 'Empty Stomach',
    };
  }

  String _conditionLabel(String? condition) {
    return switch (condition) {
      'diabetes' => 'Diabetes',
      'blood_pressure' => 'Blood Pressure',
      'school_morning' => 'School Morning',
      _ => 'Manual Setup',
    };
  }

  Future<void> _createSchedule() async {
    setState(() => _isCreating = true);

    final state = ref.read(onboardingNotifierProvider);

    try {
      if (state.useTemplate && state.selectedTemplateId != null) {
        await _createFromTemplate(state);
      } else {
        await _createManualChain(state);
      }
    } on Exception catch (e) {
      _showError('Something went wrong: $e');
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _createFromTemplate(
    OnboardingState state,
  ) async {
    final templateService = ref.read(templateServiceProvider);
    final templateRepo = ref.read(templateRepositoryProvider);
    final fasting = ref.read(fastingNotifierProvider);
    final pack = templateRepo.getById(state.selectedTemplateId!);

    if (pack == null) {
      _showError(
        'Template not found. Please go back and try '
        'again.',
      );
      return;
    }

    final overrides = <int, CustomMedicineEntry>{};
    for (var i = 0; i < state.customMedicines.length; i++) {
      overrides[i] = state.customMedicines[i];
    }

    final result = await templateService.apply(
      pack: pack,
      userOverrides: overrides,
      mealAnchorTimes: state.mealAnchorDefaults,
      fastingModeActive: fasting.isActive,
      sehriTime: fasting.sehriTime,
      iftarTime: fasting.iftarTime,
    );

    result.match(
      (error) => _showError(
        'Could not create your schedule. '
        'Please try again.\n(${error.message})',
      ),
      (_) => _navigateToPermissions(),
    );
  }

  Future<void> _createManualChain(
    OnboardingState state,
  ) async {
    final templateService = ref.read(templateServiceProvider);
    final fasting = ref.read(fastingNotifierProvider);
    final syntheticPack = _buildSyntheticPack(state);
    final result = await templateService.apply(
      pack: syntheticPack,
      mealAnchorTimes: state.mealAnchorDefaults,
      fastingModeActive: fasting.isActive,
      sehriTime: fasting.sehriTime,
      iftarTime: fasting.iftarTime,
    );
    result.match(
      (error) => _showError(
        'Could not create your schedule: '
        '${error.message}',
      ),
      (_) => _navigateToPermissions(),
    );
  }

  TemplatePack _buildSyntheticPack(
    OnboardingState state,
  ) {
    final medicines = state.customMedicines
        .asMap()
        .entries
        .map(
          (entry) => TemplateMedicine(
            name: entry.value.name,
            medicineType: entry.value.medicineType,
            chainPosition: entry.key,
            defaultDosage: entry.value.dosage,
            defaultTimeMinutes: entry.value.timeMinutes,
            anchorMeal: entry.value.anchorMeal != null
                ? TemplateMealType.values.firstWhere(
                    (t) => t.name == entry.value.anchorMeal,
                    orElse: () => TemplateMealType.breakfast,
                  )
                : null,
          ),
        )
        .toList();

    return TemplatePack(
      id:
          'manual_'
          '${DateTime.now().millisecondsSinceEpoch}',
      name: 'My Medications',
      description: 'Manually configured medications',
      condition: 'manual',
      medicines: medicines,
      edges: const [],
    );
  }

  void _navigateToPermissions() {
    ref
        .read(onboardingNotifierProvider.notifier)
        .goToStep(OnboardingStep.permissions);
    if (mounted) {
      context.go(
        '${AppRoutes.onboarding}/'
        '${AppRoutes.permissions}',
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 18),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            'Review Your Schedule',
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              _SectionCard(
                icon: Icons.medical_information,
                title: 'Condition',
                content: _conditionLabel(
                  state.selectedCondition,
                ),
              ),
              if (state.useTemplate && state.selectedTemplateId != null)
                _SectionCard(
                  icon: Icons.playlist_add_check,
                  title: 'Template',
                  content: state.selectedTemplateId!
                      .replaceAll('_', ' ')
                      .split(' ')
                      .map(
                        (w) => w[0].toUpperCase() + w.substring(1),
                      )
                      .join(' '),
                ),
              _SectionCard(
                icon: Icons.schedule,
                title: 'Meal Times',
                content: state.mealAnchorDefaults.entries
                    .map(
                      (e) =>
                          '${e.key[0].toUpperCase()}'
                          '${e.key.substring(1)}: '
                          '${_formatTime(e.value)}',
                    )
                    .join('\n'),
              ),
              _MedicinesCard(
                medicines: state.customMedicines,
                typeLabel: _medicineTypeLabel,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label:
                'Confirm and create your '
                'medication schedule',
            child: ElevatedButton(
              onPressed: _isCreating ? null : _createSchedule,
              child: _isCreating
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Looks Good — Set It Up!'),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$title: $content',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      icon,
                      size: 28,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  content,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicinesCard extends StatelessWidget {
  const _MedicinesCard({
    required this.medicines,
    required this.typeLabel,
  });

  final List<CustomMedicineEntry> medicines;
  final String Function(MedicineType) typeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.medication,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  header: true,
                  child: Text(
                    'Medicines',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (medicines.isEmpty)
              Text(
                'No medicines configured.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...medicines.map(
                (med) => Semantics(
                  label:
                      '${med.name}'
                      '${med.dosage != null ? ', ${med.dosage}' : ''}'
                      ', ${typeLabel(med.medicineType)}',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 40),
                        const ExcludeSemantics(
                          child: Icon(
                            Icons.circle,
                            size: 8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${med.name}'
                            '${med.dosage != null ? ' — ${med.dosage}' : ''}'
                            ' (${typeLabel(med.medicineType)})',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
