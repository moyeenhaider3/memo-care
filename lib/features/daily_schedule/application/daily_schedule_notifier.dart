import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/caregiver_service.dart';
import 'package:memo_care/features/reminders/application/providers.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';

/// State for today's schedule view (VIEW-01, VIEW-02, VIEW-04).
class DailyScheduleState {
  /// Creates a [DailyScheduleState].
  const DailyScheduleState({
    required this.todayReminders,
    required this.missedReminders,
    this.nextPending,
    this.confirmedIds = const {},
  });

  /// All of today's reminders in chronological order.
  final List<Reminder> todayReminders;

  /// The next pending reminder (scheduled in the future,
  /// still pending). Shown as the hero card (VIEW-02).
  final Reminder? nextPending;

  /// Reminders scheduled in the past with no terminal
  /// confirmation (VIEW-04).
  final List<Reminder> missedReminders;

  /// IDs of reminders confirmed today (DONE or SKIPPED).
  final Set<int> confirmedIds;
}

/// Manages the daily schedule state by watching today's
/// reminders from Drift.
///
/// Automatically recomputes [DailyScheduleState.nextPending]
/// and [DailyScheduleState.missedReminders] whenever the
/// reminders table changes (e.g., a confirmation is recorded).
class DailyScheduleNotifier extends AsyncNotifier<DailyScheduleState> {
  StreamSubscription<List<Reminder>>? _todaySub;
  StreamSubscription<List<Reminder>>? _missedSub;
  StreamSubscription<Set<int>>? _confirmedSub;

  List<Reminder> _today = [];
  List<Reminder> _missed = [];
  Set<int> _confirmedIds = {};

  @override
  Future<DailyScheduleState> build() async {
    final repo = ref.watch(reminderRepositoryProvider);

    final todayStream = repo.watchToday();
    final missedStream = repo.watchMissed();
    final confirmedStream = repo.watchConfirmedIds();

    // Get initial data.
    _today = await todayStream.first;
    _missed = await missedStream.first;
    _confirmedIds = await confirmedStream.first;

    // If reminders became missed while the app process was dead,
    // dispatch caregiver alerts once on next launch.
    _notifyCaregiverForMissed(_missed);

    // Set up reactive subscriptions.
    unawaited(_todaySub?.cancel());
    _todaySub = todayStream.listen((reminders) {
      _today = reminders;
      _emitState();
    });

    unawaited(_missedSub?.cancel());
    _missedSub = missedStream.listen((missed) {
      _notifyCaregiverForMissed(missed);
      _missed = missed;
      _emitState();
    });

    unawaited(_confirmedSub?.cancel());
    _confirmedSub = confirmedStream.listen((ids) {
      _confirmedIds = ids;
      _emitState();
    });

    ref.onDispose(() {
      unawaited(_todaySub?.cancel());
      unawaited(_missedSub?.cancel());
      unawaited(_confirmedSub?.cancel());
    });

    return _computeState();
  }

  void _emitState() {
    state = AsyncData(_computeState());
  }

  DailyScheduleState _computeState() {
    final now = DateTime.now().toUtc();

    // Next pending = first reminder scheduled in the future
    // that is still pending (not yet confirmed as DONE or
    // SKIPPED).
    final pendingFuture = _today.where((r) {
      final scheduledAt = r.scheduledAt;
      return scheduledAt != null &&
          scheduledAt.isAfter(now) &&
          !_confirmedIds.contains(r.id);
    }).toList();

    return DailyScheduleState(
      todayReminders: _today,
      nextPending: pendingFuture.isNotEmpty ? pendingFuture.first : null,
      missedReminders: _missed,
      confirmedIds: _confirmedIds,
    );
  }

  /// Sends WhatsApp caregiver alerts for missed reminders that have not been
  /// alerted yet, including reminders discovered at cold-start.
  void _notifyCaregiverForMissed(List<Reminder> missed) {
    unawaited(_notifyCaregiverForMissedAsync(missed));
  }

  Future<void> _notifyCaregiverForMissedAsync(List<Reminder> missed) async {
    if (missed.isEmpty) return;

    final settingsRepo = ref.read(settingsRepositoryProvider);
    final phone = settingsRepo.getCaregiverPhone();
    if (phone.isEmpty) return;

    final hasNetwork = await CaregiverService.hasNetworkConnection();
    if (!hasNetwork) {
      debugPrint('MemoCare: caregiver alerts deferred (offline)');
      await settingsRepo.retainAlertedMissedReminderIds(
        missed.map((r) => r.id).toSet(),
      );
      return;
    }

    final alertedIds = settingsRepo.getAlertedMissedReminderIds();
    final pendingAlerts = missed.where((r) => !alertedIds.contains(r.id));

    for (final reminder in pendingAlerts) {
      try {
        final launched = await CaregiverService.sendMissedReminderAlert(
          phoneNumber: phone,
          medicineName: reminder.medicineName,
          dosage: reminder.dosage,
          scheduledAt: reminder.scheduledAt ?? DateTime.now(),
        );
        if (launched) {
          await settingsRepo.markMissedReminderAlerted(reminder.id);
        }
      } on Exception catch (e) {
        debugPrint('MemoCare: Caregiver alert failed: $e');
      }
    }

    await settingsRepo.retainAlertedMissedReminderIds(
      missed.map((r) => r.id).toSet(),
    );
  }
}

/// Provider for [DailyScheduleNotifier].
final dailyScheduleNotifierProvider =
    AsyncNotifierProvider<DailyScheduleNotifier, DailyScheduleState>(
      DailyScheduleNotifier.new,
    );
