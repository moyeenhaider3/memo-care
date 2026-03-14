import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/fasting/application/fasting_state.dart';
import 'package:memo_care/features/fasting/application/prayer_time_service.dart';
import 'package:memo_care/features/fasting/domain/fasting_models.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages Ramadan/Fasting mode state — toggle, times, progress, medicines.
class FastingNotifier extends Notifier<FastingState> {
  static const _kFastingModeEnabled = 'settings_fasting_mode_enabled';

  Timer? _progressTimer;

  @override
  FastingState build() {
    ref.onDispose(() => _progressTimer?.cancel());
    final prefs = _readPrefsOrNull();

    final now = DateTime.now();
    final prayerTimes = ref
        .read(prayerTimeServiceProvider)
        .calculateForDate(date: now);
    final sehri = prayerTimes.fajr.subtract(const Duration(minutes: 10));
    final iftar = prayerTimes.maghrib;
    final isActive = prefs?.getBool(_kFastingModeEnabled) ?? false;

    if (isActive) {
      _startProgressTimer();
    }

    return FastingState(
      isActive: isActive,
      sehriTime: sehri,
      iftarTime: iftar,
      sehriMedicines: _defaultSehriMedicines(),
      iftarMedicines: _defaultIftarMedicines(),
      locationName: 'Select Location',
      progressPercent: isActive ? _calcProgressWith(sehri, iftar) : 0,
    );
  }

  /// Activate/deactivate fasting mode and start progress timer.
  void setActive({required bool active}) {
    final prefs = _readPrefsOrNull();
    if (prefs != null) {
      unawaited(prefs.setBool(_kFastingModeEnabled, active));
    }

    if (active) {
      _startProgressTimer();
    } else {
      _progressTimer?.cancel();
    }
    state = state.copyWith(
      isActive: active,
      progressPercent: active ? _calcProgress() : 0.0,
    );
  }

  void toggleFastingMode() {
    setActive(active: !state.isActive);
  }

  bool isSuppressedDuringFast({
    required DateTime scheduledAt,
    required bool isMealLinked,
  }) {
    if (!state.isActive || !isMealLinked) return false;
    final sehri = state.sehriTime;
    final iftar = state.iftarTime;
    if (sehri == null || iftar == null) return false;
    return scheduledAt.isAfter(sehri) && scheduledAt.isBefore(iftar);
  }

  /// Update sehri time.
  void setSehriTime(DateTime time) {
    state = state.copyWith(
      sehriTime: time,
      progressPercent: _calcProgress(),
    );
  }

  /// Update iftar time.
  void setIftarTime(DateTime time) {
    state = state.copyWith(
      iftarTime: time,
      progressPercent: _calcProgress(),
    );
  }

  /// Set location display name.
  void setLocation(String name) {
    state = state.copyWith(locationName: name);
  }

  /// Mark a sehri medicine as taken.
  void markSehriMedicineTaken(String id) {
    state = state.copyWith(
      sehriMedicines: state.sehriMedicines.map((m) {
        return m.id == id ? m.copyWith(isTaken: true) : m;
      }).toList(),
    );
  }

  /// Mark an iftar medicine as taken.
  void markIftarMedicineTaken(String id) {
    state = state.copyWith(
      iftarMedicines: state.iftarMedicines.map((m) {
        return m.id == id ? m.copyWith(isTaken: true) : m;
      }).toList(),
    );
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (state.isActive) {
        state = state.copyWith(progressPercent: _calcProgress());
      }
    });
  }

  double _calcProgress() {
    return _calcProgressWith(state.sehriTime, state.iftarTime);
  }

  double _calcProgressWith(DateTime? sehri, DateTime? iftar) {
    if (sehri == null || iftar == null) return 0;
    final now = DateTime.now();
    if (now.isBefore(sehri)) return 0;
    if (now.isAfter(iftar)) return 1;
    final total = iftar.difference(sehri).inMinutes;
    if (total <= 0) return 0;
    final elapsed = now.difference(sehri).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  SharedPreferences? _readPrefsOrNull() {
    try {
      return ref.read(sharedPreferencesProvider);
    } catch (_) {
      return null;
    }
  }

  List<FastingMedicine> _defaultSehriMedicines() => [
    const FastingMedicine(
      id: 'sm1',
      name: 'Metformin 500mg',
      dosage: '1 tablet',
      notes: 'With food before fast',
      section: FastingSection.sehri,
      scheduledTime: '4:00 AM',
    ),
    const FastingMedicine(
      id: 'sm2',
      name: 'Omega-3 Supplement',
      dosage: '1 capsule',
      notes: 'General health',
      section: FastingSection.sehri,
      scheduledTime: '3:45 AM',
    ),
  ];

  List<FastingMedicine> _defaultIftarMedicines() => [
    const FastingMedicine(
      id: 'im1',
      name: 'Atorvastatin 20mg',
      dosage: '1 tablet',
      notes: 'Take with first date/water',
      section: FastingSection.iftar,
      scheduledTime: '-1 min',
    ),
    const FastingMedicine(
      id: 'im2',
      name: 'Vitamin D3',
      dosage: '1 capsule',
      notes: 'After meal',
      section: FastingSection.iftar,
      scheduledTime: '+30 min',
    ),
  ];
}

/// Provider — keep-alive so fasting state survives navigation.
final fastingNotifierProvider = NotifierProvider<FastingNotifier, FastingState>(
  FastingNotifier.new,
);
