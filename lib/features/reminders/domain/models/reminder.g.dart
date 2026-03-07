// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reminder _$ReminderFromJson(Map<String, dynamic> json) => _Reminder(
  id: (json['id'] as num).toInt(),
  chainId: (json['chainId'] as num).toInt(),
  medicineName: json['medicineName'] as String,
  medicineType: $enumDecode(_$MedicineTypeEnumMap, json['medicineType']),
  dosage: json['dosage'] as String?,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  isActive: json['isActive'] as bool? ?? false,
  gapHours: (json['gapHours'] as num?)?.toInt(),
);

Map<String, dynamic> _$ReminderToJson(_Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'chainId': instance.chainId,
  'medicineName': instance.medicineName,
  'medicineType': _$MedicineTypeEnumMap[instance.medicineType]!,
  'dosage': instance.dosage,
  'scheduledAt': instance.scheduledAt?.toIso8601String(),
  'isActive': instance.isActive,
  'gapHours': instance.gapHours,
};

const _$MedicineTypeEnumMap = {
  MedicineType.beforeMeal: 'before_meal',
  MedicineType.afterMeal: 'after_meal',
  MedicineType.emptyStomach: 'empty_stomach',
  MedicineType.fixedTime: 'fixed_time',
  MedicineType.doseGap: 'dose_gap',
};
