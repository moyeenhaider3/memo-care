import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

/// A single medication reminder within a chain.
@freezed
abstract class Reminder with _$Reminder {
  const factory Reminder({
    required int id,
    required int chainId,
    required String medicineName,
    required MedicineType medicineType,
    String? dosage,
    DateTime? scheduledAt,
    @Default(false) bool isActive,
    int? gapHours,
    /// CSV of UI weekday indices `0..6` (Mon..Sun), e.g. `"0,2,4"`.
    String? recurrenceDays,
    DateTime? lastAlarmCycleStartUtc,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
