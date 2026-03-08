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
    );
  }

  void _notify() => _controller.add(_load());

  /// Disposes the stream controller.
  void dispose() => _controller.close();
}
