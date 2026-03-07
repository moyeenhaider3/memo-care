// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_anchor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MealAnchor _$MealAnchorFromJson(Map<String, dynamic> json) => _MealAnchor(
  id: (json['id'] as num).toInt(),
  mealType: json['mealType'] as String,
  defaultTimeMinutes: (json['defaultTimeMinutes'] as num).toInt(),
  confirmedAt: json['confirmedAt'] == null
      ? null
      : DateTime.parse(json['confirmedAt'] as String),
);

Map<String, dynamic> _$MealAnchorToJson(_MealAnchor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mealType': instance.mealType,
      'defaultTimeMinutes': instance.defaultTimeMinutes,
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
    };
