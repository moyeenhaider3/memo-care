import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/chain_engine/data/chain_repository.dart';
import 'package:memo_care/features/chain_engine/domain/chain_engine.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_edge.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';
import 'package:memo_care/features/confirmation/data/confirmation_repository.dart';
import 'package:memo_care/features/confirmation/domain/confirmation_service.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/confirmation/domain/snooze_limiter.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockConfirmationRepository extends Mock
    implements ConfirmationRepository {}

class MockChainRepository extends Mock implements ChainRepository {}

// Test helpers
Reminder _reminder(int id, {int chainId = 1}) => Reminder(
  id: id,
  chainId: chainId,
  medicineName: 'Med $id',
  medicineType: MedicineType.fixedTime,
);

ChainEdge _edge(int source, int target, {int chainId = 1}) => ChainEdge(
  id: 0,
  chainId: chainId,
  sourceId: source,
  targetId: target,
);

void main() {
  late ConfirmationService service;
  late MockConfirmationRepository mockConfirmationRepo;
  late MockChainRepository mockChainRepo;

  setUpAll(() {
    registerFallbackValue(ConfirmationState.done);
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockConfirmationRepo = MockConfirmationRepository();
    mockChainRepo = MockChainRepository();

    service = ConfirmationService(
      chainEngine: const ChainEngine(),
      snoozeLimiter: const SnoozeLimiter(),
      confirmationRepository: mockConfirmationRepo,
      chainRepository: mockChainRepo,
    );

    // Default stub for createConfirmation.
    when(
      () => mockConfirmationRepo.createConfirmation(
        reminderId: any(named: 'reminderId'),
        state: any(named: 'state'),
        confirmedAt: any(named: 'confirmedAt'),
        snoozeUntil: any(named: 'snoozeUntil'),
      ),
    ).thenAnswer((_) async => 1);
  });

  group('DONE confirmation', () {
    test(
      'records confirmation and returns ActivateDownstream',
      () async {
        when(() => mockChainRepo.getReminders(1)).thenAnswer(
          (_) async => [_reminder(1), _reminder(2)],
        );
        when(() => mockChainRepo.getEdges(1)).thenAnswer(
          (_) async => [_edge(1, 2)],
        );

        final result = await service.confirm(
          reminderId: 1,
          chainId: 1,
          state: ConfirmationState.done,
        );

        expect(result.outcome, isA<ActivateDownstream>());
        verify(
          () => mockConfirmationRepo.createConfirmation(
            reminderId: 1,
            state: ConfirmationState.done,
            confirmedAt: any(named: 'confirmedAt'),
            snoozeUntil: any(named: 'snoozeUntil'),
          ),
        ).called(1);
      },
    );

    test(
      'DONE on leaf returns ActivateDownstream with empty',
      () async {
        when(
          () => mockChainRepo.getReminders(1),
        ).thenAnswer((_) async => [_reminder(1)]);
        when(() => mockChainRepo.getEdges(1)).thenAnswer((_) async => []);

        final result = await service.confirm(
          reminderId: 1,
          chainId: 1,
          state: ConfirmationState.done,
        );

        expect(result.outcome, isA<ActivateDownstream>());
        final outcome = result.outcome as ActivateDownstream;
        expect(outcome.reminders, isEmpty);
      },
    );
  });

  group('SKIPPED confirmation', () {
    test(
      'records and returns SuspendDownstream',
      () async {
        when(() => mockChainRepo.getReminders(1)).thenAnswer(
          (_) async => [
            _reminder(1),
            _reminder(2),
            _reminder(3),
          ],
        );
        when(() => mockChainRepo.getEdges(1)).thenAnswer(
          (_) async => [_edge(1, 2), _edge(2, 3)],
        );

        final result = await service.confirm(
          reminderId: 1,
          chainId: 1,
          state: ConfirmationState.skipped,
        );

        expect(result.outcome, isA<SuspendDownstream>());
        final outcome = result.outcome as SuspendDownstream;
        expect(outcome.reminders.length, 2);
      },
    );
  });

  group('SNOOZED confirmation', () {
    test(
      'allowed snooze returns RescheduleSnooze',
      () async {
        when(
          () => mockConfirmationRepo.countSnoozes(1),
        ).thenAnswer((_) async => 0);
        when(() => mockChainRepo.getReminders(1)).thenAnswer(
          (_) async => [_reminder(1), _reminder(2)],
        );
        when(() => mockChainRepo.getEdges(1)).thenAnswer(
          (_) async => [_edge(1, 2)],
        );

        final snoozeTime = DateTime.now().add(
          const Duration(minutes: 10),
        );
        final result = await service.confirm(
          reminderId: 1,
          chainId: 1,
          state: ConfirmationState.snoozed,
          snoozeUntil: snoozeTime,
        );

        expect(result.outcome, isA<RescheduleSnooze>());
      },
    );

    test(
      '4th snooze attempt auto-transitions to SKIPPED',
      () async {
        when(
          () => mockConfirmationRepo.countSnoozes(1),
        ).thenAnswer((_) async => 3);
        when(() => mockChainRepo.getReminders(1)).thenAnswer(
          (_) async => [
            _reminder(1),
            _reminder(2),
            _reminder(3),
          ],
        );
        when(() => mockChainRepo.getEdges(1)).thenAnswer(
          (_) async => [_edge(1, 2), _edge(2, 3)],
        );

        final result = await service.confirm(
          reminderId: 1,
          chainId: 1,
          state: ConfirmationState.snoozed,
        );

        expect(result.outcome, isA<AutoSkipped>());
        final outcome = result.outcome as AutoSkipped;
        expect(
          outcome.reason,
          contains('3 snooze attempts'),
        );
        expect(outcome.suspendedReminders.length, 2);

        // Verify recorded as SKIPPED, not SNOOZED.
        verify(
          () => mockConfirmationRepo.createConfirmation(
            reminderId: 1,
            state: ConfirmationState.skipped,
            confirmedAt: any(named: 'confirmedAt'),
            snoozeUntil: any(named: 'snoozeUntil'),
          ),
        ).called(1);
      },
    );
  });

  group('error handling', () {
    test(
      'returns ConfirmationFailed when node not found',
      () async {
        when(
          () => mockChainRepo.getReminders(1),
        ).thenAnswer((_) async => [_reminder(1)]);
        when(() => mockChainRepo.getEdges(1)).thenAnswer((_) async => []);

        final result = await service.confirm(
          reminderId: 99,
          chainId: 1,
          state: ConfirmationState.done,
        );

        expect(result.outcome, isA<ConfirmationFailed>());
        final outcome = result.outcome as ConfirmationFailed;
        expect(outcome.error, isA<NodeNotFound>());
      },
    );
  });
}
