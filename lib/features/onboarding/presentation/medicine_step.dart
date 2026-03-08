import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/templates/application/template_providers.dart';

/// Step 4: Medicine entry / template customisation.
///
/// Template path: pre-fills from selected template, all fields
/// editable (TMPL-04).
/// Manual path: empty list with "Add Medicine" button (ONBD-02).
class MedicineStep extends ConsumerStatefulWidget {
  /// Creates a [MedicineStep].
  const MedicineStep({super.key});

  @override
  ConsumerState<MedicineStep> createState() => _MedicineStepState();
}

class _MedicineStepState extends ConsumerState<MedicineStep> {
  bool _templatePrePopulated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePrePopulateFromTemplate();
    });
  }

  void _maybePrePopulateFromTemplate() {
    if (_templatePrePopulated) return;

    final state = ref.read(onboardingNotifierProvider);
    if (!state.useTemplate || state.selectedTemplateId == null) {
      return;
    }
    if (state.customMedicines.isNotEmpty) {
      _templatePrePopulated = true;
      return;
    }

    final templateRepo = ref.read(templateRepositoryProvider);
    final pack = templateRepo.getById(state.selectedTemplateId!);
    if (pack == null) return;

    final notifier = ref.read(onboardingNotifierProvider.notifier);
    for (final med in pack.medicines) {
      notifier.addCustomMedicine(
        CustomMedicineEntry(
          name: med.name,
          medicineType: med.medicineType,
          dosage: med.defaultDosage,
          timeMinutes: med.defaultTimeMinutes,
          anchorMeal: med.anchorMeal?.name,
        ),
      );
    }
    _templatePrePopulated = true;
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

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    var selectedType = MedicineType.fixedTime;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final theme = Theme.of(context);
              return AlertDialog(
                title: Text(
                  'Add Medicine',
                  style: theme.textTheme.titleMedium,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Medicine Name',
                          hintText: 'e.g., Metformin',
                        ),
                        style: theme.textTheme.bodyMedium,
                        autofocus: true,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: dosageController,
                        decoration: const InputDecoration(
                          labelText: 'Dosage',
                          hintText: 'e.g., 500mg',
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<MedicineType>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                        ),
                        items: MedicineType.values.map(
                          (type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(
                                _medicineTypeLabel(type),
                                style: theme.textTheme.bodyMedium,
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(
                              () => selectedType = value,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        final dosage = dosageController.text.trim();
                        ref
                            .read(
                              onboardingNotifierProvider.notifier,
                            )
                            .addCustomMedicine(
                              CustomMedicineEntry(
                                name: name,
                                medicineType: selectedType,
                                dosage: dosage.isEmpty ? null : dosage,
                              ),
                            );
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showEditMedicineDialog(
    int index,
    CustomMedicineEntry medicine,
  ) {
    final nameController = TextEditingController(text: medicine.name);
    final dosageController = TextEditingController(text: medicine.dosage ?? '');
    var selectedType = medicine.medicineType;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final theme = Theme.of(context);
              return AlertDialog(
                title: Text(
                  'Edit Medicine',
                  style: theme.textTheme.titleMedium,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Medicine Name',
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: dosageController,
                        decoration: const InputDecoration(
                          labelText: 'Dosage',
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<MedicineType>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                        ),
                        items: MedicineType.values.map(
                          (type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(
                                _medicineTypeLabel(type),
                                style: theme.textTheme.bodyMedium,
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(
                              () => selectedType = value,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        final dosage = dosageController.text.trim();
                        ref
                            .read(
                              onboardingNotifierProvider.notifier,
                            )
                            .updateCustomMedicine(
                              index,
                              medicine.copyWith(
                                name: name,
                                medicineType: selectedType,
                                dosage: dosage.isEmpty ? null : dosage,
                              ),
                            );
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final medicines = state.customMedicines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            state.useTemplate ? 'Your Medicines' : 'Add Your Medicines',
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.useTemplate
              ? 'These were set up from your template. '
                    'Tap to edit any field.'
              : 'Add the medicines you need reminders for.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: medicines.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No medicines added yet.\n'
                        'Tap the button below to add one.',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    final med = medicines[index];
                    return _MedicineCard(
                      index: index,
                      medicine: med,
                      typeLabel: _medicineTypeLabel(
                        med.medicineType,
                      ),
                      onEdit: () => _showEditMedicineDialog(
                        index,
                        med,
                      ),
                      onDismissed: () => notifier.removeCustomMedicine(
                        index,
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label: 'Add a medicine',
            child: OutlinedButton.icon(
              onPressed: _showAddMedicineDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Medicine'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label: 'Continue to review',
            child: ElevatedButton(
              onPressed: medicines.isEmpty
                  ? null
                  : () {
                      notifier.goToStep(
                        OnboardingStep.review,
                      );
                      context.go(
                        '${AppRoutes.onboarding}/'
                        '${AppRoutes.review}',
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

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.index,
    required this.medicine,
    required this.typeLabel,
    required this.onEdit,
    required this.onDismissed,
  });

  final int index;
  final CustomMedicineEntry medicine;
  final String typeLabel;
  final VoidCallback onEdit;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label:
          '${medicine.name}, '
          '${medicine.dosage ?? "no dosage"}, '
          '$typeLabel. Swipe to remove.',
      child: Dismissible(
        key: ValueKey('med_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: theme.colorScheme.error,
          child: Icon(
            Icons.delete,
            color: theme.colorScheme.onError,
            size: 28,
          ),
        ),
        onDismissed: (_) => onDismissed(),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.medication,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (medicine.dosage != null) medicine.dosage!,
                          typeLabel,
                          if (medicine.anchorMeal != null)
                            '(${medicine.anchorMeal})',
                        ].join(' · '),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 24),
                  tooltip: 'Edit ${medicine.name}',
                  constraints: const BoxConstraints(
                    minWidth: 56,
                    minHeight: 56,
                  ),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
