import 'dart:convert';
import 'dart:ui' show IsolateNameServer;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/core/platform/caregiver_service.dart';
import 'package:memo_care/core/platform/notification_service.dart';
import 'package:memo_care/core/platform/phone_call_service.dart';
import 'package:memo_care/core/platform/tts_service.dart';
import 'package:memo_care/features/chain_engine/domain/chain_engine.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_edge.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Action ID constants ──────────────────────────────────────────

/// Action ID for the DONE button on notification.
const String kActionDone = 'action_done';

/// Action ID for the SNOOZE button on notification.
const String kActionSnooze = 'action_snooze';

/// Action ID for the SKIP button on notification.
const String kActionSkip = 'action_skip';

/// Action ID for the CALL NOW button on notification.
const String kActionCallNow = 'action_call_now';

/// Notification action buttons shown on every medication reminder.
const List<AndroidNotificationAction> kReminderActions = [
  // Actions work from the notification tray without opening the app
  // (showsUserInterface defaults to false).
  AndroidNotificationAction(
    kActionDone,
    'DONE \u2713',
  ),
  AndroidNotificationAction(
    kActionSnooze,
    'SNOOZE',
  ),
  AndroidNotificationAction(
    kActionSkip,
    'SKIP \u2717',
  ),
];

/// Action set for call reminders.
///
/// CALL NOW is first so Android can prioritize it on compact layouts.
const List<AndroidNotificationAction> kCallReminderActions = [
  AndroidNotificationAction(
    kActionCallNow,
    'CALL NOW',
    showsUserInterface: true,
  ),
  ...kReminderActions,
];

/// Returns the action list to show for a reminder notification.
List<AndroidNotificationAction> reminderActionsFor({
  required String medicineName,
  required String caregiverPhone,
}) {
  if (_isCallReminderName(medicineName) &&
      CaregiverService.isValidE164(caregiverPhone)) {
    return kCallReminderActions;
  }
  return kReminderActions;
}

bool _isCallReminderName(String medicineName) {
  return medicineName.trim().toLowerCase().startsWith('call ');
}

/// Port name used to signal main isolate navigation on alarm trigger.
const String kAlarmNavigationPortName = 'memo_care_alarm_navigation_port';

/// Top-level callback fired by AndroidAlarmManager in a background
/// isolate.
///
/// 2. Loads the reminder by [reminderId]
/// 3. Shows a notification with DONE/SNOOZE/SKIP action buttons
///
/// **MUST be a TOP-LEVEL function** — required by
/// android_alarm_manager_plus because it runs in a separate isolate.
@pragma('vm:entry-point')
Future<void> alarmFiredCallback(int reminderId) async {
  // Background isolate — must create fresh instances.
  final db = AppDatabase();

  try {
    // Load reminder from DB.
    final reminder = await db.reminderDao.getReminderById(reminderId);
    if (reminder == null) return;

    // If UI isolate is alive (foreground app), request immediate alarm
    // screen navigation instead of waiting for user tap.
    _notifyUiAlarmTriggered(reminderId);

    // Initialize notification service in this isolate.
    final notificationService = NotificationService();
    await notificationService.initialize(
      onBackgroundResponse: onNotificationAction,
    );

    // Start TTS init in parallel — don't block
    // notification display (PITFALLS.md §4).
    final tts = TTSService();
    final ttsInitFuture = tts.initialize();

    // Build payload with reminder ID for action handling.
    final payload = jsonEncode({'reminderId': reminderId});

    final settings = await SharedPreferences.getInstance();
    final caregiverPhone = settings.getString('settings_caregiver_phone') ?? '';
    final actions = reminderActionsFor(
      medicineName: reminder.medicineName,
      caregiverPhone: caregiverPhone,
    );

    // Post AUDIBLE notification with fullScreenIntent=true.
    // This fires immediately at IMPORTANCE_HIGH with sound + vibration
    // and launches the alarm screen over the lock screen.
    // Background isolate cannot use Riverpod / EscalationFSM —
    // the in-app EscalationController picks up once the screen launches.
    final body = reminder.dosage != null
        ? '${reminder.dosage} — Time to take your medication'
        : 'Time to take your medication';

    await notificationService.show(
      id: reminderId,
      title: '💊 ${reminder.medicineName}',
      body: body,
      level: EscalationLevel.fullscreen,
      fullScreenIntent: true,
      actions: actions,
      payload: payload,
    );

    // Speak reminder aloud (A11Y-06).
    try {
      await ttsInitFuture;
      final ttsText = buildReminderTtsText(
        medicineName: reminder.medicineName,
        dosage: reminder.dosage,
        contextPhrase: MedicineType.fromDbString(
          reminder.medicineType,
        ).ttsContext,
      );
      await tts.speak(ttsText);
    } on Exception catch (e) {
      // TTS failure is non-fatal — notification already
      // displayed.
      debugPrint(
        'TTS speak failed in alarm callback: '
        '$e',
      );
    }
  } on Object catch (e, st) {
    debugPrint('MemoCare alarmFiredCallback failed: $e');
    debugPrint('MemoCare alarmFiredCallback stack: $st');
  } finally {
    await db.close();
  }
}

void _notifyUiAlarmTriggered(int reminderId) {
  final port = IsolateNameServer.lookupPortByName(kAlarmNavigationPortName);
  port?.send(reminderId);
}

/// Background handler for notification action button taps.
///
/// Called when the user taps DONE/SNOOZE/SKIP from the notification
/// tray WITHOUT opening the app.
///
/// **MUST be a top-level function** for flutter_local_notifications
/// background handling.
@pragma('vm:entry-point')
Future<void> onNotificationAction(NotificationResponse response) async {
  final actionId = response.actionId;
  final payload = response.payload;

  if (actionId == null || payload == null) return;

  final data = jsonDecode(payload) as Map<String, dynamic>;
  final reminderId = data['reminderId'] as int?;
  if (reminderId == null) return;

  try {
    await _stopTtsBestEffort();

    switch (actionId) {
      case kActionDone:
        await _handleDone(reminderId);
      case kActionSnooze:
        await _handleSnooze(reminderId);
      case kActionSkip:
        await _handleSkip(reminderId);
      case kActionCallNow:
        await _handleCallNow();
    }
  } on Object catch (e, st) {
    debugPrint('MemoCare onNotificationAction failed: $e');
    debugPrint('MemoCare onNotificationAction stack: $st');
  }
}

Future<void> _stopTtsBestEffort() async {
  final tts = TTSService();
  try {
    await tts.stop();
  } on Object catch (e) {
    debugPrint('MemoCare TTS stop failed: $e');
  }
}

Future<void> _runDbWriteWithRetry(Future<void> Function() operation) async {
  var attempt = 0;
  while (true) {
    try {
      await operation();
      return;
    } on Object catch (e) {
      attempt += 1;
      final err = e.toString().toLowerCase();
      final isLocked =
          err.contains('database is locked') || err.contains('code 5');
      if (!isLocked || attempt >= 3) rethrow;

      // Transient lock from concurrent isolates; retry shortly.
      await Future<void>.delayed(Duration(milliseconds: 120 * attempt));
    }
  }
}

Future<void> _handleCallNow() async {
  final settings = await SharedPreferences.getInstance();
  final caregiverPhone = settings.getString('settings_caregiver_phone') ?? '';
  if (!CaregiverService.isValidE164(caregiverPhone)) {
    debugPrint('MemoCare call action ignored: caregiver number is not set');
    return;
  }

  final launched = await PhoneCallService.openDialer(
    phoneNumber: caregiverPhone,
  );
  if (!launched) {
    debugPrint('MemoCare call action failed: no dialer available');
  }
}

Future<void> _handleDone(int reminderId) async {
  final notifService = NotificationService();
  await notifService.initialize();
  await notifService.cancel(reminderId);

  final db = AppDatabase();
  try {
    await _runDbWriteWithRetry(() {
      return db.confirmationDao.insertConfirmation(
        ConfirmationsCompanion.insert(
          reminderId: reminderId,
          state: 'done',
          confirmedAt: DateTime.now().toUtc(),
        ),
      );
    });

    // Evaluate chain engine to activate downstream reminders.
    await _evaluateChainOnDone(db, reminderId);
  } finally {
    await db.close();
  }
}

Future<void> _handleSnooze(int reminderId) async {
  final notifService = NotificationService();
  await notifService.initialize();
  await notifService.cancel(reminderId);

  // Read snooze duration from user settings.
  final prefs = await SharedPreferences.getInstance();
  final snoozeMins = prefs.getInt('settings_snooze_duration_minutes') ?? 5;
  final snoozeUntil = DateTime.now().toUtc().add(Duration(minutes: snoozeMins));

  final db = AppDatabase();
  try {
    await _runDbWriteWithRetry(() {
      return db.confirmationDao.insertConfirmation(
        ConfirmationsCompanion.insert(
          reminderId: reminderId,
          state: 'snoozed',
          confirmedAt: DateTime.now().toUtc(),
          snoozeUntil: Value(snoozeUntil),
        ),
      );
    });
  } finally {
    await db.close();
  }

  // Reschedule alarm to fire after snooze duration.
  final scheduler = AlarmScheduler();
  await scheduler.schedule(
    reminderId: reminderId,
    fireAt: snoozeUntil,
    callbackHandle: alarmFiredCallback,
  );
}

Future<void> _handleSkip(int reminderId) async {
  final notifService = NotificationService();
  await notifService.initialize();
  await notifService.cancel(reminderId);

  final db = AppDatabase();
  try {
    await _runDbWriteWithRetry(() {
      return db.confirmationDao.insertConfirmation(
        ConfirmationsCompanion.insert(
          reminderId: reminderId,
          state: 'skipped',
          confirmedAt: DateTime.now().toUtc(),
        ),
      );
    });

    // Evaluate chain engine to suspend downstream reminders.
    await _evaluateChainOnSkip(db, reminderId);
  } finally {
    await db.close();
  }
}

// ── Chain engine helpers for background isolate ────────────────

/// Loads chain data for [reminderId] and returns domain models
/// needed by [ChainEngine].
Future<_ChainData?> _loadChainData(
  AppDatabase db,
  int reminderId,
) async {
  final row = await db.reminderDao.getReminderById(reminderId);
  if (row == null) return null;

  final chainId = row.chainId;
  final reminderRows = await db.chainDao.getRemindersForChain(chainId);
  final edgeRows = await db.chainDao.getEdgesForChain(chainId);

  final reminders = reminderRows
      .map(
        (r) => Reminder(
          id: r.id,
          chainId: r.chainId,
          medicineName: r.medicineName,
          medicineType: MedicineType.fromDbString(r.medicineType),
          dosage: r.dosage,
          scheduledAt: r.scheduledAt,
          isActive: r.isActive,
          gapHours: r.gapHours,
        ),
      )
      .toList();

  final edges = edgeRows
      .map(
        (e) => ChainEdge(
          id: e.id,
          chainId: e.chainId,
          sourceId: e.sourceId,
          targetId: e.targetId,
        ),
      )
      .toList();

  return _ChainData(reminders: reminders, edges: edges);
}

/// On DONE: activate immediate downstream reminders and
/// schedule their alarms (LAZY strategy).
Future<void> _evaluateChainOnDone(
  AppDatabase db,
  int reminderId,
) async {
  final data = await _loadChainData(db, reminderId);
  if (data == null || data.edges.isEmpty) return;

  const engine = ChainEngine();
  final result = engine.evaluate(
    reminders: data.reminders,
    edges: data.edges,
    confirmedId: reminderId,
    state: ConfirmationState.done,
  );

  // Use getOrElse to extract the list; fold doesn't await async.
  if (result.isLeft()) return;
  final downstream = result.getOrElse((_) => []);

  final scheduler = AlarmScheduler();
  for (final reminder in downstream) {
    // Activate the downstream reminder.
    await _runDbWriteWithRetry(() {
      return db.reminderDao.updateReminder(
        RemindersCompanion(
          id: Value(reminder.id),
          chainId: Value(reminder.chainId),
          medicineName: Value(reminder.medicineName),
          medicineType: Value(reminder.medicineType.dbValue),
          dosage: Value(reminder.dosage),
          scheduledAt: Value(reminder.scheduledAt),
          isActive: const Value(true),
          gapHours: Value(reminder.gapHours),
        ),
      );
    });

    // Schedule alarm if the reminder has a scheduled time.
    if (reminder.scheduledAt != null) {
      await scheduler.schedule(
        reminderId: reminder.id,
        fireAt: reminder.scheduledAt!,
        callbackHandle: alarmFiredCallback,
      );
    }
  }
}

/// On SKIP: suspend all transitive downstream reminders and
/// cancel their alarms (EAGER strategy).
Future<void> _evaluateChainOnSkip(
  AppDatabase db,
  int reminderId,
) async {
  final data = await _loadChainData(db, reminderId);
  if (data == null || data.edges.isEmpty) return;

  const engine = ChainEngine();
  final result = engine.evaluate(
    reminders: data.reminders,
    edges: data.edges,
    confirmedId: reminderId,
    state: ConfirmationState.skipped,
  );

  if (result.isLeft()) return;
  final suspended = result.getOrElse((_) => []);

  final scheduler = AlarmScheduler();
  for (final reminder in suspended) {
    // Deactivate the downstream reminder.
    await _runDbWriteWithRetry(() {
      return db.reminderDao.updateReminder(
        RemindersCompanion(
          id: Value(reminder.id),
          chainId: Value(reminder.chainId),
          medicineName: Value(reminder.medicineName),
          medicineType: Value(reminder.medicineType.dbValue),
          dosage: Value(reminder.dosage),
          scheduledAt: Value(reminder.scheduledAt),
          isActive: const Value(false),
          gapHours: Value(reminder.gapHours),
        ),
      );
    });

    // Cancel the alarm.
    await scheduler.cancel(reminder.id);
  }
}

class _ChainData {
  const _ChainData({required this.reminders, required this.edges});
  final List<Reminder> reminders;
  final List<ChainEdge> edges;
}
