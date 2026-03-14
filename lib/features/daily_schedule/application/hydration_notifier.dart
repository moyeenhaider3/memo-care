import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HydrationState {
  const HydrationState({
    required this.lastUpdated,
    this.glasses = 0,
    this.target = 8,
  });

  final int glasses;
  final int target;
  final DateTime lastUpdated;

  HydrationState copyWith({
    int? glasses,
    int? target,
    DateTime? lastUpdated,
  }) {
    return HydrationState(
      glasses: glasses ?? this.glasses,
      target: target ?? this.target,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class HydrationNotifier extends Notifier<HydrationState> {
  static const _kHydrationCount = 'hydration_glasses_count';
  static const _kHydrationTarget = 'hydration_glasses_target';
  static const _kHydrationDate = 'hydration_last_date';

  @override
  HydrationState build() {
    final prefs = _readPrefsOrNull();
    final today = DateTime.now();
    final dateToken = '${today.year}-${today.month}-${today.day}';
    final lastToken = prefs?.getString(_kHydrationDate);

    final needsReset = lastToken != dateToken;
    final count = needsReset ? 0 : (prefs?.getInt(_kHydrationCount) ?? 0);
    final target = prefs?.getInt(_kHydrationTarget) ?? 8;

    if (needsReset && prefs != null) {
      unawaited(prefs.setInt(_kHydrationCount, 0));
      unawaited(prefs.setString(_kHydrationDate, dateToken));
    }

    return HydrationState(
      glasses: count,
      target: target,
      lastUpdated: today,
    );
  }

  Future<void> addGlass() async {
    final prefs = _readPrefsOrNull();
    final updated = (state.glasses + 1).clamp(0, 99);
    state = state.copyWith(
      glasses: updated,
      lastUpdated: DateTime.now(),
    );
    if (prefs != null) {
      await prefs.setInt(_kHydrationCount, state.glasses);
    }
  }

  Future<void> setTarget(int target) async {
    final prefs = _readPrefsOrNull();
    final normalized = target.clamp(1, 20);
    state = state.copyWith(target: normalized);
    if (prefs != null) {
      await prefs.setInt(_kHydrationTarget, normalized);
    }
  }

  SharedPreferences? _readPrefsOrNull() {
    try {
      return ref.read(sharedPreferencesProvider);
    } catch (_) {
      return null;
    }
  }
}

final hydrationNotifierProvider =
    NotifierProvider<HydrationNotifier, HydrationState>(
      HydrationNotifier.new,
    );
