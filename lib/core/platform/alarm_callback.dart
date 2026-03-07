import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/platform/notification_service.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';

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
  // TODO(memo-care): Record DONE confirmation in DB (Phase 04)
  // TODO(memo-care): Trigger chain engine propagation (Phase 04)
}

Future<void> _handleSnooze(int reminderId) async {
  final notifService = NotificationService();
  await notifService.initialize();
  await notifService.cancel(reminderId);
  // TODO(memo-care): Record SNOOZED confirmation in DB (Phase 04)
  // TODO(memo-care): Reschedule alarm with snooze duration (Phase 04)
}

Future<void> _handleSkip(int reminderId) async {
  final notifService = NotificationService();
  await notifService.initialize();
  await notifService.cancel(reminderId);
  // TODO(memo-care): Record SKIPPED confirmation in DB (Phase 04)
  // TODO(memo-care): Suspend downstream chain nodes (Phase 04)
}
