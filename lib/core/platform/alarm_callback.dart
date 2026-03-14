import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/core/platform/notification_service.dart';
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

/// Top-level callback fired by AndroidAlarmManager in a background
/// isolate.
///
/// This function:
/// 1. Opens a fresh Drift database (isolate cannot share main DB)
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

    // Show initial notification at SILENT tier.
    // Escalation controller (Plan 08) progresses through tiers.
    await notificationService.show(
      id: reminderId,
      title: reminder.medicineName,
      body: 'Time to take your medication',
      level: EscalationLevel.silent,
      actions: kReminderActions,
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
  } finally {
    await db.close();
  }
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

  switch (actionId) {
    case kActionDone:
      await _handleDone(reminderId);
    case kActionSnooze:
      await _handleSnooze(reminderId);
    case kActionSkip:
      await _handleSkip(reminderId);
  }
}

Future<void> _handleDone(int reminderId) async {
  final notifService = NotificationService();
  await notifService.initialize();
  await notifService.cancel(reminderId);

  final db = AppDatabase();
  try {
    await db.confirmationDao.insertConfirmation(
      ConfirmationsCompanion.insert(
        reminderId: reminderId,
        state: 'done',
        confirmedAt: DateTime.now().toUtc(),
      ),
    );

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
    await db.confirmationDao.insertConfirmation(
      ConfirmationsCompanion.insert(
        reminderId: reminderId,
        state: 'snoozed',
        confirmedAt: DateTime.now().toUtc(),
        snoozeUntil: Value(snoozeUntil),
      ),
    );
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
    await db.confirmationDao.insertConfirmation(
      ConfirmationsCompanion.insert(
        reminderId: reminderId,
        state: 'skipped',
        confirmedAt: DateTime.now().toUtc(),
      ),
    );

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
    await db.reminderDao.updateReminder(
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
    await db.reminderDao.updateReminder(
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

    // Cancel the alarm.
    await scheduler.cancel(reminder.id);
  }
}

class _ChainData {
  const _ChainData({required this.reminders, required this.edges});
  final List<Reminder> reminders;
  final List<ChainEdge> edges;
}
