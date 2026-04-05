import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memo_care/features/fasting/application/fasting_state.dart';
import 'package:memo_care/features/fasting/application/prayer_time_service.dart';
import 'package:memo_care/features/fasting/domain/fasting_models.dart';
import 'package:memo_care/features/reminders/application/providers.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages Ramadan/Fasting mode state — toggle, times, progress, medicines.
class FastingNotifier extends Notifier<FastingState> {
  static const _kFastingModeEnabled = 'settings_fasting_mode_enabled';

  Timer? _progressTimer;
  StreamSubscription<List<Reminder>>? _reminderSub;

  @override
  FastingState build() {
    ref.onDispose(() => _progressTimer?.cancel());
    // ignore: cascade_invocations // workaround
    ref.onDispose(() => _reminderSub?.cancel());
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

    // Subscribe to the user's real reminders from the database.
    // ignore: discarded_futures // workaround
    _reminderSub?.cancel();
    final repo = ref.read(reminderRepositoryProvider);
    _reminderSub = repo.watchActive().listen((reminders) {
      state = state.copyWith(
        sehriMedicines: _sehriMedicinesFrom(reminders),
        iftarMedicines: _iftarMedicinesFrom(reminders),
      );
    });

    return FastingState(
      isActive: isActive,
      sehriTime: sehri,
      iftarTime: iftar,
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
    // ignore: avoid_catches_without_on_clauses // workaround
    } catch (_) {
      return null;
    }
  }

  /// Build [FastingMedicine] list for sehri from the user's active reminders.
  /// Includes medicines taken before meals or on an empty stomach.
  List<FastingMedicine> _sehriMedicinesFrom(List<Reminder> reminders) {
    return reminders
        .where(
          (r) =>
              r.medicineType == MedicineType.beforeMeal ||
              r.medicineType == MedicineType.emptyStomach,
        )
        .map(
          (r) => FastingMedicine(
            id: 'r_${r.id}',
            name: r.medicineName,
            dosage: r.dosage ?? '',
            notes: r.medicineType.ttsContext,
            section: FastingSection.sehri,
            scheduledTime: _formatScheduledTime(r.scheduledAt),
          ),
        )
        .toList();
  }

  /// Build [FastingMedicine] list for iftar from the user's active reminders.
  /// Includes medicines taken after meals.
  List<FastingMedicine> _iftarMedicinesFrom(List<Reminder> reminders) {
    return reminders
        .where((r) => r.medicineType == MedicineType.afterMeal)
        .map(
          (r) => FastingMedicine(
            id: 'r_${r.id}',
            name: r.medicineName,
            dosage: r.dosage ?? '',
            notes: r.medicineType.ttsContext,
            section: FastingSection.iftar,
            scheduledTime: _formatScheduledTime(r.scheduledAt),
          ),
        )
        .toList();
  }

  static String? _formatScheduledTime(DateTime? dt) {
    if (dt == null) return null;
    return DateFormat.jm().format(dt);
  }
}

/// Provider — keep-alive so fasting state survives navigation.
final fastingNotifierProvider = NotifierProvider<FastingNotifier, FastingState>(
  FastingNotifier.new,
);
