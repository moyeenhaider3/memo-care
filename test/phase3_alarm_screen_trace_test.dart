// Phase 3 (trace plan): full-screen alarm `ui::AlarmScreen.*` traces.
// Covers startEscalation plus Done / Snooze / Skip (with nested acknowledge +
// ConfirmationNotifier). Uses no-op notifications, fake alarm scheduler + audio,
// silent TTS, wakelock platform shim, tall viewport, nested GoRoute (so pop
// works), and reminder/chain provider overrides (avoids Drift watch timers).
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/debug/bootstrap_trace.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/core/platform/audio_service.dart';
import 'package:memo_care/core/platform/notification_service.dart';
import 'package:memo_care/core/platform/tts_service.dart';
import 'package:memo_care/core/providers/alarm_providers.dart'
    show alarmSchedulerProvider, audioServiceProvider;
import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/core/providers/notification_providers.dart';
import 'package:memo_care/core/providers/tts_providers.dart';
import 'package:memo_care/features/chain_engine/application/chain_context_providers.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_context.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';
import 'package:memo_care/features/escalation/presentation/alarm_screen_loader.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';

/// Avoids plugin + channel work; [NotificationService.show] asserts init.
class _NoopNotificationService extends NotificationService {
  _NoopNotificationService() : super(plugin: FlutterLocalNotificationsPlugin());

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required EscalationLevel level,
    bool fullScreenIntent = false,
    List<AndroidNotificationAction>? actions,
    String? payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}

class _NoopAlarmScheduler extends AlarmScheduler {
  @override
  Future<bool> schedule({
    required int reminderId,
    required DateTime fireAt,
    required Function callbackHandle,
  }) async => true;

  @override
  Future<bool> cancel(int reminderId) async => true;

  @override
  Future<int> cancelAll(List<int> reminderIds) async => reminderIds.length;
}

class _SilentTts extends TTSService {
  @override
  Future<void> stop() async {}
}

/// Avoids just_audio / platform work during escalation + acknowledge.
class _NoopAudioService extends AudioService {
  @override
  Future<void> startLoop({String? assetPath}) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

void _expectPairedUiStep(List<String> logs, String step) {
  final enter = '$kTracePrefix ▸ enter ui::$step';
  final exit = '$kTracePrefix ▸ exit  ui::$step';
  expect(logs, contains(enter));
  expect(logs, contains(exit));
  expect(
    logs.where((l) => l.contains('ui::$step')),
    everyElement(isNot(contains('error='))),
  );
}

Future<void> _waitForStartEscalationExit(
  WidgetTester tester,
  List<String> logs,
) async {
  for (var i = 0; i < 80; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    final done = logs.any(
      (l) =>
          l.contains(
            '$kTracePrefix ▸ exit  ui::AlarmScreen.startEscalation',
          ) &&
          !l.contains('error='),
    );
    if (done) return;
  }
  fail('Timed out waiting for AlarmScreen.startEscalation exit');
}

typedef _HarnessData = ({
  SharedPreferences prefs,
  AppDatabase db,
  Reminder reminder,
});

Future<_HarnessData> _seedDb() async {
  SharedPreferences.setMockInitialValues({
    'onboarding_complete': true,
    'settings_silent_timeout_minutes': 0,
    'settings_audible_timeout_minutes': 0,
    'settings_snooze_duration_minutes': 5,
  });
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase.forTesting(NativeDatabase.memory());

  await db
      .into(db.reminderChains)
      .insert(
        ReminderChainsCompanion.insert(
          name: 'Test chain',
          createdAt: DateTime.now(),
        ),
      );

  final now = DateTime.now();
  await db
      .into(db.reminders)
      .insert(
        RemindersCompanion.insert(
          chainId: 1,
          medicineName: 'Insulin',
          medicineType: MedicineType.beforeMeal.dbValue,
          dosage: const Value('10 units'),
          scheduledAt: Value(now.add(const Duration(minutes: 1))),
          isActive: const Value(true),
        ),
      );

  final reminder = Reminder(
    id: 1,
    chainId: 1,
    medicineName: 'Insulin',
    medicineType: MedicineType.beforeMeal,
    dosage: '10 units',
    scheduledAt: now.add(const Duration(minutes: 1)),
    isActive: true,
  );

  return (prefs: prefs, db: db, reminder: reminder);
}

void _useTallViewport(WidgetTester tester) {
  final view = tester.view
    ..physicalSize = const Size(800, 2000)
    ..devicePixelRatio = 1;
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);
}

class _FakeWakelockPlatform extends WakelockPlusPlatformInterface {
  _FakeWakelockPlatform() : super();

  @override
  Future<void> toggle({required bool enable}) async {}

  @override
  Future<bool> get enabled async => false;
}

Future<void> _pumpAlarmRoute(WidgetTester tester, _HarnessData data) {
  // Nested route so `context.pop()` has a parent (GoRouter single-route has
  // nothing to pop).
  final router = GoRouter(
    initialLocation: '/home/alarm',
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(
          body: Center(child: Text('home')),
        ),
        routes: [
          GoRoute(
            path: 'alarm',
            builder: (_, _) => const AlarmScreenLoader(reminderId: 1),
          ),
        ],
      ),
    ],
  );
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(data.prefs),
        appDatabaseProvider.overrideWithValue(data.db),
        notificationServiceProvider.overrideWithValue(
          _NoopNotificationService(),
        ),
        ttsServiceProvider.overrideWithValue(_SilentTts()),
        audioServiceProvider.overrideWithValue(_NoopAudioService()),
        alarmSchedulerProvider.overrideWithValue(_NoopAlarmScheduler()),
        reminderByIdStreamProvider(1).overrideWith(
          (ref) => Stream.value(data.reminder),
        ),
        chainContextProvider(1).overrideWith(
          (ref) => Future.value(
            ChainContext(
              currentReminder: data.reminder,
              upstreamReminders: const [],
              downstreamReminders: const [],
              chainName: 'Test chain',
            ),
          ),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

Future<List<String>> _runCapturingLogs(
  Future<void> Function(List<String> logs) body,
) async {
  final logs = <String>[];
  final previousPrint = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    if (message != null) logs.add(message);
    previousPrint(message, wrapWidth: wrapWidth);
  };
  try {
    await body(logs);
  } finally {
    debugPrint = previousPrint;
  }
  return logs;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WakelockPlusPlatformInterface originalWakelock;
  setUpAll(() {
    originalWakelock = wakelockPlusPlatformInstance;
    wakelockPlusPlatformInstance = _FakeWakelockPlatform();
  });
  tearDownAll(() {
    wakelockPlusPlatformInstance = originalWakelock;
  });

  group('AlarmScreenLoader MemoCareTrace', () {
    testWidgets('ui::AlarmScreen.startEscalation', (tester) async {
      _useTallViewport(tester);
      await _runCapturingLogs((logs) async {
        final data = await _seedDb();
        addTearDown(data.db.close);
        await _pumpAlarmRoute(tester, data);
        await _waitForStartEscalationExit(tester, logs);
        _expectPairedUiStep(logs, 'AlarmScreen.startEscalation');
      });
    });

    testWidgets('Done + acknowledge + ConfirmationNotifier', (tester) async {
      _useTallViewport(tester);
      await _runCapturingLogs((logs) async {
        final data = await _seedDb();
        addTearDown(data.db.close);
        await _pumpAlarmRoute(tester, data);
        await _waitForStartEscalationExit(tester, logs);

        await tester.tap(find.text("I've Done It"));
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          final ok = logs.any(
            (l) =>
                l.contains(
                  '$kTracePrefix ▸ exit  ui::AlarmScreen.done',
                ) &&
                !l.contains('error='),
          );
          if (ok) break;
        }

        _expectPairedUiStep(logs, 'AlarmScreen.acknowledge');
        _expectPairedUiStep(logs, 'AlarmScreen.done');
        _expectPairedUiStep(logs, 'ConfirmationNotifier.confirm');
      });
    });

    testWidgets('Snooze + acknowledge + ConfirmationNotifier', (tester) async {
      _useTallViewport(tester);
      await _runCapturingLogs((logs) async {
        final data = await _seedDb();
        addTearDown(data.db.close);
        await _pumpAlarmRoute(tester, data);
        await _waitForStartEscalationExit(tester, logs);

        await tester.tap(find.text('Remind me in 5 min'));
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          final ok = logs.any(
            (l) =>
                l.contains(
                  '$kTracePrefix ▸ exit  ui::AlarmScreen.snooze',
                ) &&
                !l.contains('error='),
          );
          if (ok) break;
        }

        _expectPairedUiStep(logs, 'AlarmScreen.acknowledge');
        _expectPairedUiStep(logs, 'AlarmScreen.snooze');
        _expectPairedUiStep(logs, 'ConfirmationNotifier.confirm');
      });
    });

    testWidgets('Skip + acknowledge + ConfirmationNotifier', (tester) async {
      _useTallViewport(tester);
      await _runCapturingLogs((logs) async {
        final data = await _seedDb();
        addTearDown(data.db.close);
        await _pumpAlarmRoute(tester, data);
        await _waitForStartEscalationExit(tester, logs);

        await tester.tap(find.text('Skip this reminder'));
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          final ok = logs.any(
            (l) =>
                l.contains(
                  '$kTracePrefix ▸ exit  ui::AlarmScreen.skip',
                ) &&
                !l.contains('error='),
          );
          if (ok) break;
        }

        _expectPairedUiStep(logs, 'AlarmScreen.acknowledge');
        _expectPairedUiStep(logs, 'AlarmScreen.skip');
        _expectPairedUiStep(logs, 'ConfirmationNotifier.confirm');
      });
    });
  });
}
