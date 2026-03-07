// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirmation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Confirmation _$ConfirmationFromJson(Map<String, dynamic> json) =>
    _Confirmation(
      id: (json['id'] as num).toInt(),
      reminderId: (json['reminderId'] as num).toInt(),
      state: $enumDecode(_$ConfirmationStateEnumMap, json['state']),
      confirmedAt: DateTime.parse(json['confirmedAt'] as String),
      snoozeUntil: json['snoozeUntil'] == null
          ? null
          : DateTime.parse(json['snoozeUntil'] as String),
    );

Map<String, dynamic> _$ConfirmationToJson(_Confirmation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reminderId': instance.reminderId,
      'state': _$ConfirmationStateEnumMap[instance.state]!,
      'confirmedAt': instance.confirmedAt.toIso8601String(),
      'snoozeUntil': instance.snoozeUntil?.toIso8601String(),
    };

const _$ConfirmationStateEnumMap = {
  ConfirmationState.done: 'done',
  ConfirmationState.snoozed: 'snoozed',
  ConfirmationState.skipped: 'skipped',
};
