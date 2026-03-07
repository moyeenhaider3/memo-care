// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_chain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReminderChain _$ReminderChainFromJson(Map<String, dynamic> json) =>
    _ReminderChain(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ReminderChainToJson(_ReminderChain instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
    };
