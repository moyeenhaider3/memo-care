// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryEntry _$HistoryEntryFromJson(Map<String, dynamic> json) =>
    _HistoryEntry(
      reminderId: (json['reminderId'] as num).toInt(),
      medicineName: json['medicineName'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      dosage: json['dosage'] as String?,
      status: $enumDecodeNullable(_$ConfirmationStateEnumMap, json['status']),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
    );

Map<String, dynamic> _$HistoryEntryToJson(_HistoryEntry instance) =>
    <String, dynamic>{
      'reminderId': instance.reminderId,
      'medicineName': instance.medicineName,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'dosage': instance.dosage,
      'status': _$ConfirmationStateEnumMap[instance.status],
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
    };

const _$ConfirmationStateEnumMap = {
  ConfirmationState.done: 'done',
  ConfirmationState.snoozed: 'snoozed',
  ConfirmationState.skipped: 'skipped',
};
