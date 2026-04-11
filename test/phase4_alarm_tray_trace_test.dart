// Phase 4 (trace plan): notification tray handlers `alarm::*` (background-style
// paths; invoked synchronously in VM tests via [onNotificationAction]).
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/debug/bootstrap_trace.dart' show kTracePrefix;
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/core/platform/notification_service.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoopTrayNotificationService extends NotificationService {
  _NoopTrayNotificationService()
    : super(plugin: FlutterLocalNotificationsPlugin());

  @override
  Future<void> initialize({
    NotificationResponseCallback? onResponse,
    NotificationResponseCallback? onBackgroundResponse,
  }) async {}

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

NotificationResponse _actionResponse(String actionId, int reminderId) {
  return NotificationResponse(
    notificationResponseType:
        NotificationResponseType.selectedNotificationAction,
    actionId: actionId,
    payload: jsonEncode({'reminderId': reminderId}),
  );
}

Future<List<String>> _captureLogs(Future<void> Function() body) async {
  final logs = <String>[];
  final previousPrint = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    if (message != null) logs.add(message);
    previousPrint(message, wrapWidth: wrapWidth);
  };
  try {
    await body();
  } finally {
    debugPrint = previousPrint;
  }
  return logs;
}

void _expectPairedAlarmStep(List<String> logs, String step) {
  final enter = '$kTracePrefix ▸ enter alarm::$step';
  final exit = '$kTracePrefix ▸ exit  alarm::$step';
  expect(logs, contains(enter));
  expect(logs, contains(exit));
  expect(
    logs.where((l) => l.contains('alarm::$step')),
    everyElement(isNot(contains('error='))),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    AlarmCallbackOverrides.createDatabase = null;
    AlarmCallbackOverrides.createNotificationService = null;
    AlarmCallbackOverrides.createScheduler = null;
    AlarmCallbackOverrides.closeTrayDatabase = true;
  });

  group('onNotificationAction (tray) MemoCareTrace', () {
    test(
      'DONE: onNotificationAction + handleDone + evaluateChainOnDone',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        await db
            .into(db.reminderChains)
            .insert(
              ReminderChainsCompanion.insert(
                name: 'Solo',
                createdAt: DateTime.now(),
              ),
            );
        final t = DateTime.now().toUtc().add(const Duration(hours: 1));
        await db
            .into(db.reminders)
            .insert(
              RemindersCompanion.insert(
                chainId: 1,
                medicineName: 'Aspirin',
                medicineType: MedicineType.beforeMeal.dbValue,
                dosage: const Value('81 mg'),
                scheduledAt: Value(t),
                isActive: const Value(true),
              ),
            );

        AlarmCallbackOverrides.createDatabase = () => db;
        AlarmCallbackOverrides.createNotificationService =
            _NoopTrayNotificationService.new;
        AlarmCallbackOverrides.createScheduler = _NoopAlarmScheduler.new;

        final logs = await _captureLogs(
          () => onNotificationAction(_actionResponse(kActionDone, 1)),
        );

        _expectPairedAlarmStep(logs, 'onNotificationAction');
        _expectPairedAlarmStep(logs, 'handleDone');
        _expectPairedAlarmStep(logs, 'evaluateChainOnDone');
      },
    );

    test('DONE with edge: evaluateChainOnDone activates downstream', () async {
      AlarmCallbackOverrides.closeTrayDatabase = false;
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db
          .into(db.reminderChains)
          .insert(
            ReminderChainsCompanion.insert(
              name: 'Pair',
              createdAt: DateTime.now(),
            ),
          );
      final t2 = DateTime.now().toUtc().add(const Duration(hours: 2));
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              chainId: 1,
              medicineName: 'First',
              medicineType: MedicineType.beforeMeal.dbValue,
              dosage: const Value('1'),
              scheduledAt: Value(DateTime.now().toUtc()),
              isActive: const Value(true),
            ),
          );
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              chainId: 1,
              medicineName: 'Second',
              medicineType: MedicineType.afterMeal.dbValue,
              dosage: const Value('2'),
              scheduledAt: Value(t2),
              isActive: const Value(false),
            ),
          );
      await db
          .into(db.chainEdges)
          .insert(
            ChainEdgesCompanion.insert(
              chainId: 1,
              sourceId: 1,
              targetId: 2,
            ),
          );

      AlarmCallbackOverrides.createDatabase = () => db;
      AlarmCallbackOverrides.createNotificationService =
          _NoopTrayNotificationService.new;
      AlarmCallbackOverrides.createScheduler = _NoopAlarmScheduler.new;

      await onNotificationAction(_actionResponse(kActionDone, 1));

      final row2 = await db.reminderDao.getReminderById(2);
      expect(row2?.isActive, isTrue);
    });

    test(
      'SKIP with edge: onNotificationAction + handleSkip + evaluateChainOnSkip',
      () async {
        AlarmCallbackOverrides.closeTrayDatabase = false;
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        await db
            .into(db.reminderChains)
            .insert(
              ReminderChainsCompanion.insert(
                name: 'Pair',
                createdAt: DateTime.now(),
              ),
            );
        await db
            .into(db.reminders)
            .insert(
              RemindersCompanion.insert(
                chainId: 1,
                medicineName: 'First',
                medicineType: MedicineType.beforeMeal.dbValue,
                dosage: const Value('1'),
                scheduledAt: Value(DateTime.now().toUtc()),
                isActive: const Value(true),
              ),
            );
        await db
            .into(db.reminders)
            .insert(
              RemindersCompanion.insert(
                chainId: 1,
                medicineName: 'Second',
                medicineType: MedicineType.afterMeal.dbValue,
                dosage: const Value('2'),
                scheduledAt: Value(
                  DateTime.now().toUtc().add(const Duration(hours: 1)),
                ),
                isActive: const Value(true),
              ),
            );
        await db
            .into(db.chainEdges)
            .insert(
              ChainEdgesCompanion.insert(
                chainId: 1,
                sourceId: 1,
                targetId: 2,
              ),
            );

        AlarmCallbackOverrides.createDatabase = () => db;
        AlarmCallbackOverrides.createNotificationService =
            _NoopTrayNotificationService.new;
        AlarmCallbackOverrides.createScheduler = _NoopAlarmScheduler.new;

        final logs = await _captureLogs(
          () => onNotificationAction(_actionResponse(kActionSkip, 1)),
        );

        _expectPairedAlarmStep(logs, 'onNotificationAction');
        _expectPairedAlarmStep(logs, 'handleSkip');
        _expectPairedAlarmStep(logs, 'evaluateChainOnSkip');

        final row2 = await db.reminderDao.getReminderById(2);
        expect(row2?.isActive, isFalse);
      },
    );

    test('SNOOZE: onNotificationAction + handleSnooze', () async {
      SharedPreferences.setMockInitialValues({
        'settings_snooze_duration_minutes': 10,
      });
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db
          .into(db.reminderChains)
          .insert(
            ReminderChainsCompanion.insert(
              name: 'S',
              createdAt: DateTime.now(),
            ),
          );
      await db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              chainId: 1,
              medicineName: 'Med',
              medicineType: MedicineType.beforeMeal.dbValue,
              dosage: const Value('5'),
              scheduledAt: Value(DateTime.now().toUtc()),
              isActive: const Value(true),
            ),
          );

      AlarmCallbackOverrides.createDatabase = () => db;
      AlarmCallbackOverrides.createNotificationService =
          _NoopTrayNotificationService.new;
      AlarmCallbackOverrides.createScheduler = _NoopAlarmScheduler.new;

      final logs = await _captureLogs(
        () => onNotificationAction(_actionResponse(kActionSnooze, 1)),
      );

      _expectPairedAlarmStep(logs, 'onNotificationAction');
      _expectPairedAlarmStep(logs, 'handleSnooze');
    });
  });
}
