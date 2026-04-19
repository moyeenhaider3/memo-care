import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/debug/bootstrap_trace.dart';
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

  Timer? _midnightCheck;

  @override
  HydrationState build() {
    ref.onDispose(() {
      _midnightCheck?.cancel();
      _midnightCheck = null;
    });
    if (_midnightCheck == null) {
      _midnightCheck = Timer.periodic(const Duration(minutes: 5), (_) {
        unawaited(_rolloverIfDateChanged());
      });
    }

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
    await traceAsync('ui', 'HydrationNotifier.addGlass', () async {
      await _rolloverIfDateChanged();
      final prefs = _readPrefsOrNull();
      final updated = (state.glasses + 1).clamp(0, 99);
      state = state.copyWith(
        glasses: updated,
        lastUpdated: DateTime.now(),
      );
      if (prefs != null) {
        await prefs.setInt(_kHydrationCount, state.glasses);
      }
    });
  }

  Future<void> setTarget(int target) async {
    await traceAsync('ui', 'HydrationNotifier.setTarget', () async {
      final prefs = _readPrefsOrNull();
      final normalized = target.clamp(1, 20);
      state = state.copyWith(target: normalized);
      if (prefs != null) {
        await prefs.setInt(_kHydrationTarget, normalized);
      }
    });
  }

  Future<void> _rolloverIfDateChanged() async {
    final prefs = _readPrefsOrNull();
    if (prefs == null) return;
    final today = DateTime.now();
    final dateToken = '${today.year}-${today.month}-${today.day}';
    final lastToken = prefs.getString(_kHydrationDate);
    if (lastToken == dateToken) return;

    await prefs.setInt(_kHydrationCount, 0);
    await prefs.setString(_kHydrationDate, dateToken);
    state = HydrationState(
      glasses: 0,
      target: state.target,
      lastUpdated: today,
    );
  }

  SharedPreferences? _readPrefsOrNull() {
    try {
      return ref.read(sharedPreferencesProvider);
    // ignore: avoid_catches_without_on_clauses // workaround
    } catch (_) {
      return null;
    }
  }
}

final hydrationNotifierProvider =
    NotifierProvider<HydrationNotifier, HydrationState>(
      HydrationNotifier.new,
    );
