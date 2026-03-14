// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  snoozeDurationMinutes: (json['snoozeDurationMinutes'] as num?)?.toInt() ?? 5,
  silentTimeoutMinutes: (json['silentTimeoutMinutes'] as num?)?.toInt() ?? 2,
  audibleTimeoutMinutes: (json['audibleTimeoutMinutes'] as num?)?.toInt() ?? 3,
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  soundEnabled: json['soundEnabled'] as bool? ?? true,
  vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
  largeText: json['largeText'] as bool? ?? false,
  highContrast: json['highContrast'] as bool? ?? false,
  caregiverPhone: json['caregiverPhone'] as String? ?? '',
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'snoozeDurationMinutes': instance.snoozeDurationMinutes,
      'silentTimeoutMinutes': instance.silentTimeoutMinutes,
      'audibleTimeoutMinutes': instance.audibleTimeoutMinutes,
      'notificationsEnabled': instance.notificationsEnabled,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'largeText': instance.largeText,
      'highContrast': instance.highContrast,
      'caregiverPhone': instance.caregiverPhone,
    };
