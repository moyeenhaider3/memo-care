import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:isolate';
import 'dart:ui' show IsolateNameServer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/app.dart';
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/platform/alarm_rescheduler.dart'
    as boot_rescheduler;
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/core/platform/notification_service.dart';
import 'package:memo_care/core/platform/tts_service.dart';
import 'package:memo_care/core/providers/notification_providers.dart';
import 'package:memo_care/core/providers/tts_providers.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Called when the user taps a notification while the app is in
/// the foreground or background (but NOT killed).
///
/// Navigates to the fullscreen alarm screen using [appNavigatorKey].
void _onNotificationTap(NotificationResponse response) {
  // Action buttons (DONE/SNOOZE/SKIP) should execute action logic,
  // not navigate to the alarm route.
  if (response.actionId?.isNotEmpty ?? false) {
    unawaited(onNotificationAction(response));
    return;
  }

  final payload = response.payload;
  if (payload == null) return;

  try {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final reminderId = data['reminderId'] as int?;
    if (reminderId == null) return;

    // Use the global navigator key context to drive GoRouter navigation
    // regardless of which screen is currently shown.
    final context = appNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go('${AppRoutes.alarm}/$reminderId');
    }
  } on Exception catch (e) {
    debugPrint('MemoCare: notification tap handler failed: $e');
  }
}

ReceivePort? _alarmNavigationPort;

void _navigateToAlarmRoute(int reminderId, {int attempt = 0}) {
  final context = appNavigatorKey.currentContext;
  if (context != null) {
    GoRouter.of(context).go('${AppRoutes.alarm}/$reminderId');
    return;
  }

  // Wait briefly for app/router to be ready during startup transitions.
  if (attempt >= 20) return;
  Future<void>.delayed(
    const Duration(milliseconds: 150),
    () => _navigateToAlarmRoute(reminderId, attempt: attempt + 1),
  );
}

void _registerAlarmNavigationBridge() {
  _alarmNavigationPort?.close();
  _alarmNavigationPort = ReceivePort();

  IsolateNameServer.removePortNameMapping(kAlarmNavigationPortName);
  IsolateNameServer.registerPortWithName(
    _alarmNavigationPort!.sendPort,
    kAlarmNavigationPortName,
  );

  _alarmNavigationPort!.listen((message) {
    if (message is int) {
      _navigateToAlarmRoute(message);
    }
  });
}

int? _extractReminderIdFromPayload(String? payload) {
  if (payload == null) return null;
  try {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    return data['reminderId'] as int?;
  } on Exception {
    return null;
  }
}

@pragma('vm:entry-point')
Future<void> rescheduleAlarmsOnBoot() {
  return boot_rescheduler.rescheduleAlarmsOnBoot();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AndroidAlarmManager before any scheduling.
  // Only available on Android — skip on iOS/other platforms.
  if (!kIsWeb && Platform.isAndroid) {
    await AlarmScheduler.initialize();
  }

  // Initialize SharedPreferences before any provider reads it.
  final prefs = await SharedPreferences.getInstance();

  // Initialize NotificationService in the FOREGROUND app so:
  // 1. Notification taps navigate to the alarm screen.
  // 2. Notification action buttons (DONE/SNOOZE/SKIP) work from the tray.
  // 3. The escalation controller can post/update notifications.
  final notifService = NotificationService();
  await notifService.initialize(
    onResponse: _onNotificationTap,
    onBackgroundResponse: onNotificationAction,
  );

  // Listen for alarm callback events from background isolate so the
  // foreground app opens the reminder screen immediately.
  _registerAlarmNavigationBridge();

  // Handle app cold-start from notification tap/full-screen intent.
  // onDidReceiveNotificationResponse is not called for a terminated app.
  int? launchReminderId;
  final launchDetails = await notifService.plugin
      .getNotificationAppLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final launchResponse = launchDetails?.notificationResponse;
    if (launchResponse != null) {
      if (launchResponse.actionId?.isNotEmpty ?? false) {
        // Action button launched the app — execute action first.
        await onNotificationAction(launchResponse);
      } else {
        launchReminderId = _extractReminderIdFromPayload(
          launchResponse.payload,
        );
      }
    }
  }

  // Pre-initialize TTS to avoid 300-800ms cold-start
  // delay on first speech request (PITFALLS.md §4).
  final ttsService = TTSService();
  try {
    await ttsService.initialize();
  } on Exception catch (e) {
    debugPrint(
      'TTS pre-initialization failed (non-fatal): $e',
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        ttsServiceProvider.overrideWithValue(ttsService),
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Provide the already-initialized NotificationService so
        // providers don't create a second uninitialized instance.
        notificationServiceProvider.overrideWithValue(notifService),
      ],
      child: MemoCareApp(initialAlarmReminderId: launchReminderId),
    ),
  );
}
