import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/providers/alarm_providers.dart';
import 'package:memo_care/features/chain_engine/application/providers.dart';
import 'package:memo_care/features/fasting/application/fasting_notifier.dart';
import 'package:memo_care/features/reminders/application/add_reminder_state.dart';
import 'package:memo_care/features/reminders/application/providers.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/presentation/widgets/reminder_type_grid.dart';

/// Manages the Add Reminder form state and persistence.
class AddReminderNotifier extends Notifier<AddReminderState> {
  @override
  AddReminderState build() => const AddReminderState();

  void setType(ReminderType type) => state = state.copyWith(reminderType: type);

  void setName(String name) => state = state.copyWith(name: name);

  void setDose(String dose) => state = state.copyWith(dose: dose);

  void setUnit(String unit) => state = state.copyWith(unit: unit);

  void setTimeMode(TimeMode mode) => state = state.copyWith(timeMode: mode);

  void setFixedTime(TimeOfDay time) => state = state.copyWith(fixedTime: time);

  void setLinkedEvent(String event) =>
      state = state.copyWith(linkedEvent: event);

  void setOffsetMinutes(int minutes) =>
      state = state.copyWith(offsetMinutes: minutes);

  void toggleDay(int dayIndex) {
    final days = Set<int>.from(state.selectedDays);
    if (days.contains(dayIndex)) {
      days.remove(dayIndex);
    } else {
      days.add(dayIndex);
    }
    state = state.copyWith(selectedDays: days);
  }

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  void toggleChainLink() => state = state.copyWith(chainLink: !state.chainLink);

  /// Persist the reminder. Returns `true` on success.
  Future<bool> save() async {
    if (!state.isValid) {
      state = state.copyWith(
        errorMessage: 'Please fill in all required fields.',
      );
      return false;
    }

    state = state.copyWith(isSaving: true);

    try {
      final repo = ref.read(reminderRepositoryProvider);
      final fastingState = ref.read(fastingNotifierProvider);
      final fastingNotifier = ref.read(fastingNotifierProvider.notifier);

      // Compute scheduled time from form state.
      var suppressedDueToFasting = false;
      DateTime? scheduledAt;
      if (state.timeMode == TimeMode.fixed && state.fixedTime != null) {
        final now = DateTime.now();
        scheduledAt = DateTime(
          now.year,
          now.month,
          now.day,
          state.fixedTime!.hour,
          state.fixedTime!.minute,
        );
      }

      if (scheduledAt != null) {
        final shouldSuppress = fastingNotifier.isSuppressedDuringFast(
          scheduledAt: scheduledAt,
          isMealLinked: _isMealLinked(state.medicineType),
        );
        if (fastingState.isActive && shouldSuppress) {
          // Keep the reminder but do not arm a daytime fasting alarm.
          scheduledAt = null;
          suppressedDueToFasting = true;
        }
      }

      // Create a chain record for this reminder.
      final chainRepo = ref.read(chainRepositoryProvider);
      final chainId = await chainRepo.createChain(
        name: state.name.trim(),
      );

      // Create the reminder linked to the new chain.
      final reminderId = await repo.createReminder(
        chainId: chainId,
        medicineName: state.name.trim(),
        medicineType: state.medicineType,
        dosage: state.dose.isNotEmpty ? '${state.dose} ${state.unit}' : null,
        scheduledAt: scheduledAt,
        isActive: true,
      );

      // Schedule the alarm so it actually fires at the right time.
      if (scheduledAt != null) {
        final scheduler = ref.read(alarmSchedulerProvider);
        await scheduler.schedule(
          reminderId: reminderId,
          fireAt: scheduledAt,
          callbackHandle: alarmFiredCallback,
        );
      }

      state = state.copyWith(
        isSaving: false,
        errorMessage: suppressedDueToFasting
            ? 'Saved without a daytime alarm due to fasting mode.'
            : null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save: $e',
      );
      return false;
    }
  }

  /// Reset form to initial state.
  void reset() => state = const AddReminderState();

  bool _isMealLinked(MedicineType type) {
    return type == MedicineType.beforeMeal ||
        type == MedicineType.afterMeal ||
        type == MedicineType.emptyStomach;
  }
}

/// Provider for the Add Reminder form notifier.
final NotifierProvider<AddReminderNotifier, AddReminderState>
addReminderNotifierProvider =
    NotifierProvider.autoDispose<AddReminderNotifier, AddReminderState>(
      AddReminderNotifier.new,
    );
