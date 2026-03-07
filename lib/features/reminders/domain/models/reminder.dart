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
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
