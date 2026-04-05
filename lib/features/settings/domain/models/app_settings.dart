import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// User-configurable application settings.
///
/// Stored in SharedPreferences. Consumed by:
/// - EscalationController (snooze/timeout values)
/// - NotificationService (sound/vibration preferences)
/// - SettingsScreen (UI display + editing)
@freezed
abstract class AppSettings with _$AppSettings {
  /// Creates an [AppSettings] with the given values.
  const factory AppSettings({
    /// Snooze duration in minutes (VIEW-05, ESCL-02).
    @Default(5) int snoozeDurationMinutes,

    /// Silent tier timeout in minutes before escalating
    /// to audible (ESCL-02).
    @Default(2) int silentTimeoutMinutes,

    /// Audible tier timeout in minutes before escalating
    /// to full-screen (ESCL-02).
    @Default(3) int audibleTimeoutMinutes,

    /// Whether notifications are enabled globally.
    @Default(true) bool notificationsEnabled,

    /// Whether alarm sound is enabled.
    @Default(true) bool soundEnabled,

    /// Whether vibration is enabled.
    @Default(true) bool vibrationEnabled,

    /// Whether large text mode is enabled.
    @Default(false) bool largeText,

    /// Whether high contrast mode is enabled.
    @Default(false) bool highContrast,

    /// Whether dark mode is enabled.
    @Default(false) bool darkMode,

    /// Linked caregiver phone number (empty if none).
    @Default('') String caregiverPhone,
  }) = _AppSettings;

  /// Deserialises from JSON.
  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
