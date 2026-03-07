import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';
import 'package:memo_care/features/confirmation/data/confirmation_repository.dart';
import 'package:memo_care/features/confirmation/domain/confirmation_service.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/confirmation/domain/models/undoable_confirmation.dart';
import 'package:memo_care/features/confirmation/domain/undo_confirmation_service.dart';
import 'package:memo_care/features/reminders/data/reminder_repository.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';
import 'package:mocktail/mocktail.dart';

class _MockConfirmationRepository extends Mock
    implements ConfirmationRepository {}

class _MockReminderRepository extends Mock implements ReminderRepository {}

class _MockAlarmScheduler extends Mock implements AlarmScheduler {}

class _FakeReminder extends Fake implements Reminder {}

Reminder _reminder(int id, {int chainId = 1, DateTime? scheduledAt}) =>
    Reminder(
      id: id,
      chainId: chainId,
      medicineName: 'Med $id',
      medicineType: MedicineType.fixedTime,
      scheduledAt: scheduledAt,
    );

UndoableConfirmation _undoable({
  required ConfirmationOutcome outcome,
  int confirmationId = 100,
  int reminderId = 1,
  int chainId = 1,
  String medicineName = 'Aspirin',
  ConfirmationState confirmState = ConfirmationState.done,
}) => UndoableConfirmation(
  confirmationId: confirmationId,
  reminderId: reminderId,
  chainId: chainId,
  medicineName: medicineName,
  confirmState: confirmState,
  outcome: outcome,
);

void main() {
  late UndoConfirmationService service;
  late _MockConfirmationRepository mockConfirmationRepo;
  late _MockReminderRepository mockReminderRepo;
  late _MockAlarmScheduler mockScheduler;

  setUpAll(() {
    registerFallbackValue(_FakeReminder());
  });

  setUp(() {
    mockConfirmationRepo = _MockConfirmationRepository();
    mockReminderRepo = _MockReminderRepository();
    mockScheduler = _MockAlarmScheduler();

    service = UndoConfirmationService(
      confirmationRepository: mockConfirmationRepo,
      reminderRepository: mockReminderRepo,
      alarmScheduler: mockScheduler,
    );

    // Default stubs.
    when(
      () => mockConfirmationRepo.deleteConfirmation(any()),
    ).thenAnswer((_) async => 1);
    when(
      () => mockReminderRepo.updateReminder(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockScheduler.cancel(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockScheduler.schedule(
        reminderId: any(named: 'reminderId'),
        fireAt: any(named: 'fireAt'),
        callbackHandle: any(named: 'callbackHandle'),
      ),
    ).thenAnswer((_) async => true);
  });

  group('undo ActivateDownstream (DONE)', () {
    test('deletes confirmation, cancels alarms, deactivates', () async {
      final downstream = [_reminder(2), _reminder(3)];
      final undoable = _undoable(
        outcome: ActivateDownstream(reminders: downstream),
      );

      final result = await service.undo(undoable);

      expect(result, isA<UndoSucceeded>());
      verify(
        () => mockConfirmationRepo.deleteConfirmation(100),
      ).called(1);
      verify(() => mockScheduler.cancel(2)).called(1);
      verify(() => mockScheduler.cancel(3)).called(1);
      verify(
        () => mockReminderRepo.updateReminder(any()),
      ).called(2);
    });

    test('empty downstream list still succeeds', () async {
      final undoable = _undoable(
        outcome: const ActivateDownstream(reminders: []),
      );

      final result = await service.undo(undoable);

      expect(result, isA<UndoSucceeded>());
      verify(
        () => mockConfirmationRepo.deleteConfirmation(100),
      ).called(1);
      verifyNever(() => mockScheduler.cancel(any()));
    });
  });

  group('undo SuspendDownstream (SKIP)', () {
    test('deletes confirmation, reactivates reminders, '
        'reschedules alarms', () async {
      final now = DateTime.now().add(const Duration(hours: 1));
      final downstream = [
        _reminder(2, scheduledAt: now),
        _reminder(3, scheduledAt: now),
      ];
      final undoable = _undoable(
        confirmState: ConfirmationState.skipped,
        outcome: SuspendDownstream(reminders: downstream),
      );

      final result = await service.undo(undoable);

      expect(result, isA<UndoSucceeded>());
      verify(
        () => mockConfirmationRepo.deleteConfirmation(100),
      ).called(1);
      // Reactivated.
      verify(
        () => mockReminderRepo.updateReminder(any()),
      ).called(2);
      // Rescheduled.
      verify(
        () => mockScheduler.schedule(
          reminderId: 2,
          fireAt: any(named: 'fireAt'),
          callbackHandle: any(named: 'callbackHandle'),
        ),
      ).called(1);
      verify(
        () => mockScheduler.schedule(
          reminderId: 3,
          fireAt: any(named: 'fireAt'),
          callbackHandle: any(named: 'callbackHandle'),
        ),
      ).called(1);
    });
  });

  group('undo RescheduleSnooze (SNOOZE)', () {
    test('deletes confirmation and cancels snooze alarm', () async {
      final undoable = _undoable(
        confirmState: ConfirmationState.snoozed,
        outcome: RescheduleSnooze(
          reminder: _reminder(1),
          remainingSnoozes: 2,
        ),
      );

      final result = await service.undo(undoable);

      expect(result, isA<UndoSucceeded>());
      verify(
        () => mockConfirmationRepo.deleteConfirmation(100),
      ).called(1);
      verify(() => mockScheduler.cancel(1)).called(1);
    });
  });

  group('undo AutoSkipped', () {
    test('reactivates suspended reminders', () async {
      final now = DateTime.now().add(const Duration(hours: 2));
      final suspended = [_reminder(4, scheduledAt: now)];
      final undoable = _undoable(
        outcome: AutoSkipped(
          reason: 'Exceeded 3 snooze attempts',
          suspendedReminders: suspended,
        ),
      );

      final result = await service.undo(undoable);

      expect(result, isA<UndoSucceeded>());
      verify(
        () => mockReminderRepo.updateReminder(any()),
      ).called(1);
      verify(
        () => mockScheduler.schedule(
          reminderId: 4,
          fireAt: any(named: 'fireAt'),
          callbackHandle: any(named: 'callbackHandle'),
        ),
      ).called(1);
    });
  });

  group('failure cases', () {
    test('returns UndoFailed when confirmation not found', () async {
      when(
        () => mockConfirmationRepo.deleteConfirmation(any()),
      ).thenAnswer((_) async => 0);

      final undoable = _undoable(
        outcome: const ActivateDownstream(reminders: []),
      );

      final result = await service.undo(undoable);

      expect(result, isA<UndoFailed>());
      final failed = result as UndoFailed;
      expect(
        failed.reason,
        contains('not found'),
      );
    });

    test('returns UndoFailed on exception', () async {
      when(
        () => mockConfirmationRepo.deleteConfirmation(any()),
      ).thenThrow(Exception('DB error'));

      final undoable = _undoable(
        outcome: const ActivateDownstream(reminders: []),
      );

      final result = await service.undo(undoable);

      expect(result, isA<UndoFailed>());
    });
  });

  group('ConfirmationFailed outcome', () {
    test('only deletes confirmation, no side effects', () async {
      final undoable = _undoable(
        outcome: const ConfirmationFailed(
          error: NodeNotFound(nodeId: 99),
        ),
      );

      final result = await service.undo(undoable);

      expect(result, isA<UndoSucceeded>());
      verify(
        () => mockConfirmationRepo.deleteConfirmation(100),
      ).called(1);
      verifyNever(() => mockScheduler.cancel(any()));
      verifyNever(
        () => mockReminderRepo.updateReminder(any()),
      );
    });
  });
}
