import 'dart:async';

import 'package:memo_care/features/settings/domain/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [AppSettings] to SharedPreferences.
///
/// Uses `settings_`-prefixed keys to avoid collisions with other
/// SharedPreferences usage (e.g., onboarding state).
///
/// Provides a reactive [watch] stream that emits whenever settings
/// change.
class SettingsRepository {
  /// Creates a [SettingsRepository] backed by `prefs`.
  SettingsRepository(this._prefs) {
    // Emit initial value.
    _controller.add(_load());
  }

  final SharedPreferences _prefs;
  final _controller = StreamController<AppSettings>.broadcast();

  // -- SharedPreferences keys --
  static const _kSnoozeDuration = 'settings_snooze_duration_minutes';
  static const _kSilentTimeout = 'settings_silent_timeout_minutes';
  static const _kAudibleTimeout = 'settings_audible_timeout_minutes';
  static const _kNotificationsEnabled = 'settings_notifications_enabled';
  static const _kSoundEnabled = 'settings_sound_enabled';
  static const _kVibrationEnabled = 'settings_vibration_enabled';
  static const _kLargeText = 'settings_large_text';
  static const _kHighContrast = 'settings_high_contrast';
  static const _kDarkMode = 'settings_dark_mode';
  static const _kCaregiverPhone = 'settings_caregiver_phone';
  static const _kCaregiverAlertedMissedIds =
      'settings_caregiver_alerted_missed_ids';

  /// Returns the current settings snapshot.
  AppSettings get current => _load();

  /// Reactive stream of settings changes.
  ///
  /// Emits the current value immediately on listen, then
  /// subsequent updates. Uses `startWith` semantics via
  /// `async*` to avoid broadcast-stream initial-event loss.
  Stream<AppSettings> watch() async* {
    yield _load();
    yield* _controller.stream;
  }

  /// Updates snooze duration.
  Future<void> setSnoozeDuration(int minutes) async {
    await _prefs.setInt(_kSnoozeDuration, minutes);
    _notify();
  }

  /// Updates silent tier timeout.
  Future<void> setSilentTimeout(int minutes) async {
    await _prefs.setInt(_kSilentTimeout, minutes);
    _notify();
  }

  /// Updates audible tier timeout.
  Future<void> setAudibleTimeout(int minutes) async {
    await _prefs.setInt(_kAudibleTimeout, minutes);
    _notify();
  }

  /// Updates notification enabled state.
  Future<void> setNotificationsEnabled({
    required bool enabled,
  }) async {
    await _prefs.setBool(_kNotificationsEnabled, enabled);
    _notify();
  }

  /// Updates sound enabled state.
  Future<void> setSoundEnabled({required bool enabled}) async {
    await _prefs.setBool(_kSoundEnabled, enabled);
    _notify();
  }

  /// Updates vibration enabled state.
  Future<void> setVibrationEnabled({
    required bool enabled,
  }) async {
    await _prefs.setBool(_kVibrationEnabled, enabled);
    _notify();
  }

  /// Updates large text mode.
  // ignore: avoid_positional_boolean_parameters // workaround
  Future<void> setLargeText(bool enabled) async {
    await _prefs.setBool(_kLargeText, enabled);
    _notify();
  }

  /// Updates high contrast mode.
  // ignore: avoid_positional_boolean_parameters // workaround
  Future<void> setHighContrast(bool enabled) async {
    await _prefs.setBool(_kHighContrast, enabled);
    _notify();
  }

  /// Updates dark mode.
  // ignore: avoid_positional_boolean_parameters // workaround
  Future<void> setDarkMode(bool enabled) async {
    await _prefs.setBool(_kDarkMode, enabled);
    _notify();
  }

  /// Sets the caregiver phone number.
  Future<void> setCaregiverPhone(String phone) async {
    await _prefs.setString(_kCaregiverPhone, phone);
    _notify();
  }

  /// Returns the current caregiver phone number (empty if none).
  String getCaregiverPhone() => _prefs.getString(_kCaregiverPhone) ?? '';

  /// Returns reminder IDs that already triggered a caregiver alert.
  Set<int> getAlertedMissedReminderIds() {
    final raw = _prefs.getStringList(_kCaregiverAlertedMissedIds) ??
        const <String>[];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  /// Marks a reminder as already alerted to avoid duplicate WhatsApp opens.
  Future<void> markMissedReminderAlerted(int reminderId) async {
    final ids = getAlertedMissedReminderIds()..add(reminderId);
    await _prefs.setStringList(
      _kCaregiverAlertedMissedIds,
      ids.map((id) => id.toString()).toList(),
    );
  }

  /// Retains only alert IDs that are still currently missed.
  ///
  /// Prevents stale IDs from growing forever and allows future reminders
  /// with different IDs to alert normally.
  Future<void> retainAlertedMissedReminderIds(Set<int> activeMissedIds) async {
    final retained = getAlertedMissedReminderIds()
        .where(activeMissedIds.contains)
        .toSet();
    await _prefs.setStringList(
      _kCaregiverAlertedMissedIds,
      retained.map((id) => id.toString()).toList(),
    );
  }

  /// Bulk update all settings at once.
  Future<void> update(AppSettings settings) async {
    await _prefs.setInt(
      _kSnoozeDuration,
      settings.snoozeDurationMinutes,
    );
    await _prefs.setInt(
      _kSilentTimeout,
      settings.silentTimeoutMinutes,
    );
    await _prefs.setInt(
      _kAudibleTimeout,
      settings.audibleTimeoutMinutes,
    );
    await _prefs.setBool(
      _kNotificationsEnabled,
      settings.notificationsEnabled,
    );
    await _prefs.setBool(
      _kSoundEnabled,
      settings.soundEnabled,
    );
    await _prefs.setBool(
      _kVibrationEnabled,
      settings.vibrationEnabled,
    );
    await _prefs.setBool(_kLargeText, settings.largeText);
    await _prefs.setBool(_kHighContrast, settings.highContrast);
    await _prefs.setBool(_kDarkMode, settings.darkMode);
    await _prefs.setString(_kCaregiverPhone, settings.caregiverPhone);
    _notify();
  }

  AppSettings _load() {
    return AppSettings(
      snoozeDurationMinutes: _prefs.getInt(_kSnoozeDuration) ?? 5,
      silentTimeoutMinutes: _prefs.getInt(_kSilentTimeout) ?? 2,
      audibleTimeoutMinutes: _prefs.getInt(_kAudibleTimeout) ?? 3,
      notificationsEnabled: _prefs.getBool(_kNotificationsEnabled) ?? true,
      soundEnabled: _prefs.getBool(_kSoundEnabled) ?? true,
      vibrationEnabled: _prefs.getBool(_kVibrationEnabled) ?? true,
      largeText: _prefs.getBool(_kLargeText) ?? false,
      highContrast: _prefs.getBool(_kHighContrast) ?? false,
      darkMode: _prefs.getBool(_kDarkMode) ?? false,
      caregiverPhone: _prefs.getString(_kCaregiverPhone) ?? '',
    );
  }

  void _notify() => _controller.add(_load());

  /// Disposes the stream controller.
  void dispose() => _controller.close();
}
