import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/templates/application/template_providers.dart';

/// Page 5 — Medicine entry / template customisation.
class MedicinesPage extends ConsumerStatefulWidget {
  /// Creates a [MedicinesPage].
  const MedicinesPage({
    required this.stepLabel,
    required this.onNext,
    super.key,
  });

  /// E.g. 'Step 5 of 7'.
  final String stepLabel;

  /// Called when "Continue" is pressed.
  final VoidCallback onNext;

  @override
  ConsumerState<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends ConsumerState<MedicinesPage> {
  bool _templatePrePopulated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePrePopulate();
    });
  }

  void _maybePrePopulate() {
    if (_templatePrePopulated) return;
    final state = ref.read(onboardingNotifierProvider);
    if (!state.useTemplate || state.selectedTemplateId == null) return;
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

  String _typeLabel(MedicineType type) => switch (type) {
    MedicineType.beforeMeal => 'Before Meal',
    MedicineType.afterMeal => 'After Meal',
    MedicineType.fixedTime => 'Fixed Time',
    MedicineType.doseGap => 'Dose Gap',
    MedicineType.emptyStomach => 'Empty Stomach',
  };

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    var selType = MedicineType.fixedTime;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) {
            final theme = Theme.of(ctx);
            return AlertDialog(
              title: Text('Add Medicine', style: theme.textTheme.titleMedium),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                        hintText: 'e.g., Metformin',
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: doseCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Dosage',
                        hintText: 'e.g., 500mg',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MedicineType>(
                      initialValue: selType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: MedicineType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_typeLabel(t)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => selType = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      final dose = doseCtrl.text.trim();
                      ref
                          .read(onboardingNotifierProvider.notifier)
                          .addCustomMedicine(
                            CustomMedicineEntry(
                              name: name,
                              medicineType: selType,
                              dosage: dose.isEmpty ? null : dose,
                            ),
                          );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(int index, CustomMedicineEntry med) {
    final nameCtrl = TextEditingController(text: med.name);
    final doseCtrl = TextEditingController(text: med.dosage ?? '');
    var selType = med.medicineType;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) {
            final theme = Theme.of(ctx);
            return AlertDialog(
              title: Text('Edit Medicine', style: theme.textTheme.titleMedium),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: doseCtrl,
                      decoration: const InputDecoration(labelText: 'Dosage'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MedicineType>(
                      initialValue: selType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: MedicineType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_typeLabel(t)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => selType = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      final dose = doseCtrl.text.trim();
                      ref
                          .read(onboardingNotifierProvider.notifier)
                          .updateCustomMedicine(
                            index,
                            med.copyWith(
                              name: name,
                              medicineType: selType,
                              dosage: dose.isEmpty ? null : dose,
                            ),
                          );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final medicines = state.customMedicines;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.stepLabel),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          state.useTemplate
                              ? 'Your Medicines'
                              : 'Add Your Medicines',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.useTemplate
                            ? 'These were set up from your template. '
                                  'Tap to edit any field.'
                            : 'Add the medicines you need reminders for.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
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
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: medicines.length,
                          itemBuilder: (context, i) {
                            final med = medicines[i];
                            return Semantics(
                              label:
                                  '${med.name}, '
                                  '${med.dosage ?? 'no dosage'}, '
                                  '${_typeLabel(med.medicineType)}. '
                                  'Swipe to remove.',
                              child: Dismissible(
                                key: ValueKey('med_$i'),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) =>
                                    notifier.removeCustomMedicine(i),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Card(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    leading: const Icon(
                                      Icons.medication_outlined,
                                    ),
                                    title: Text(med.name),
                                    subtitle: Text(
                                      '${med.dosage ?? '–'} · '
                                      '${_typeLabel(med.medicineType)}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Edit',
                                      onPressed: () => _showEditDialog(i, med),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Semantics(
                button: true,
                label: 'Add a medicine',
                child: OutlinedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medicine'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
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
                label: 'Continue to accessibility settings',
                child: ElevatedButton(
                  onPressed: medicines.isEmpty ? null : widget.onNext,
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
