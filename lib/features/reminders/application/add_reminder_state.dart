import 'package:flutter/material.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/presentation/widgets/reminder_type_grid.dart';

/// Immutable state for the Add Reminder form.
@immutable
class AddReminderState {
  const AddReminderState({
    this.reminderType = ReminderType.medicine,
    this.name = '',
    this.dose = '',
    this.unit = 'mg',
    this.timeMode = TimeMode.fixed,
    this.fixedTime,
    this.linkedEvent = 'After Breakfast',
    this.offsetMinutes = 30,
    this.selectedDays = const {0, 1, 2, 3, 4, 5, 6},
    this.notes = '',
    this.chainLink = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final ReminderType reminderType;
  final String name;
  final String dose;
  final String unit;
  final TimeMode timeMode;
  final TimeOfDay? fixedTime;
  final String linkedEvent;
  final int offsetMinutes;

  /// Selected day indices (0=Mon .. 6=Sun).
  final Set<int> selectedDays;
  final String notes;
  final bool chainLink;
  final bool isSaving;
  final String? errorMessage;

  /// Whether the form has enough data to save.
  bool get isValid =>
      name.trim().isNotEmpty &&
      selectedDays.isNotEmpty &&
      (reminderType != ReminderType.medicine || dose.trim().isNotEmpty) &&
      (timeMode == TimeMode.linked || fixedTime != null) &&
      (timeMode != TimeMode.linked || linkedEvent.trim().isNotEmpty);

  /// Map the UI ReminderType + TimeMode to a domain MedicineType.
  MedicineType get medicineType {
    if (timeMode == TimeMode.linked) {
      final event = linkedEvent.toLowerCase();
      if (event.contains('before')) return MedicineType.beforeMeal;
      if (event.contains('after')) return MedicineType.afterMeal;
      if (event.contains('empty')) return MedicineType.emptyStomach;
      return MedicineType.afterMeal;
    }
    return MedicineType.fixedTime;
  }

  AddReminderState copyWith({
    ReminderType? reminderType,
    String? name,
    String? dose,
    String? unit,
    TimeMode? timeMode,
    TimeOfDay? fixedTime,
    String? linkedEvent,
    int? offsetMinutes,
    Set<int>? selectedDays,
    String? notes,
    bool? chainLink,
    bool? isSaving,
    String? errorMessage,
  }) {
    return AddReminderState(
      reminderType: reminderType ?? this.reminderType,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
      timeMode: timeMode ?? this.timeMode,
      fixedTime: fixedTime ?? this.fixedTime,
      linkedEvent: linkedEvent ?? this.linkedEvent,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      selectedDays: selectedDays ?? this.selectedDays,
      notes: notes ?? this.notes,
      chainLink: chainLink ?? this.chainLink,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

/// Whether the time is set by absolute clock or linked to an event.
enum TimeMode { fixed, linked }
