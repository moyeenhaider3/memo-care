import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/app.dart';
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/platform/alarm_rescheduler.dart' as boot_rescheduler;
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/core/platform/notification_service.dart';
import 'package:memo_care/core/platform/tts_service.dart';
import 'package:memo_care/core/providers/notification_providers.dart';
import 'package:memo_care/core/providers/tts_providers.dart';
import 'package:memo_care/core/router/app_router.dart';
import 'package:memo_care/dev/master_test_runner.dart';
import 'package:memo_care/dev/test_data_seeder.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Developer entry: seeds DB/prefs, launches app, runs harness on delay.
///
/// ```bash
/// flutter run -t lib/dev/dev_main.dart
/// ```
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kDebugMode) {
    debugPrint('dev_main.dart must be run in debug mode.');
    return;
  }

  if (!kIsWeb && Platform.isAndroid) {
    await AlarmScheduler.initialize();
  }

  final prefs = await SharedPreferences.getInstance();

  final notifService = NotificationService();
  await notifService.initialize(
    onResponse: _onNotificationTap,
    onBackgroundResponse: onNotificationAction,
  );

  final ttsService = TTSService();
  try {
    await ttsService.initialize();
  } on Exception catch (e) {
    debugPrint('dev_main: TTS init failed (non-fatal): $e');
  }

  final container = ProviderContainer(
    overrides: [
      ttsServiceProvider.overrideWithValue(ttsService),
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationServiceProvider.overrideWithValue(notifService),
    ],
  );

  await TestDataSeeder.seedAll(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const _DevHarnessShell(),
    ),
  );
}

class _DevHarnessShell extends ConsumerStatefulWidget {
  const _DevHarnessShell();

  @override
  ConsumerState<_DevHarnessShell> createState() => _DevHarnessShellState();
}

class _DevHarnessShellState extends ConsumerState<_DevHarnessShell> {
  var _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_started) return;
      _started = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      await MasterTestRunner.runAll(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MemoCareApp();
  }
}

void _onNotificationTap(NotificationResponse response) {
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
    final context = appNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go('${AppRoutes.alarm}/$reminderId');
    }
  } on Exception catch (e) {
    debugPrint('dev_main: notification tap failed: $e');
  }
}

@pragma('vm:entry-point')
Future<void> rescheduleAlarmsOnBoot() {
  return boot_rescheduler.rescheduleAlarmsOnBoot();
}
