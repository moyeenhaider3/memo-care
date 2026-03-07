import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/chain_engine/domain/chain_engine.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_edge.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_error.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Creates a test reminder with minimal required fields.
Reminder _reminder(int id, {int chainId = 1}) => Reminder(
  id: id,
  chainId: chainId,
  medicineName: 'Med $id',
  medicineType: MedicineType.fixedTime,
);

/// Creates a test edge.
ChainEdge _edge(
  int source,
  int target, {
  int id = 0,
  int chainId = 1,
}) => ChainEdge(
  id: id,
  chainId: chainId,
  sourceId: source,
  targetId: target,
);

void main() {
  late ChainEngine engine;

  setUp(() {
    engine = const ChainEngine();
  });

  group('ChainEngine.evaluate — DONE state', () {
    test(
      'DONE on leaf node (no outgoing edges) returns empty',
      () {
        final result = engine.evaluate(
          reminders: [_reminder(1)],
          edges: [],
          confirmedId: 1,
          state: ConfirmationState.done,
        );
        expect(result.isRight(), isTrue);
        result.fold(
          (_) {},
          (reminders) => expect(reminders, isEmpty),
        );
      },
    );

    test(
      'DONE activates only IMMEDIATE downstream (lazy)',
      () {
        // Chain: 1→2→3
        // DONE on 1 should return [2] only, NOT [2, 3]
        final result = engine.evaluate(
          reminders: [
            _reminder(1),
            _reminder(2),
            _reminder(3),
          ],
          edges: [_edge(1, 2), _edge(2, 3)],
          confirmedId: 1,
          state: ConfirmationState.done,
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (reminders) {
          expect(reminders.length, 1);
          expect(reminders.first.id, 2);
        });
      },
    );

    test(
      'DONE with fan-out returns all immediate children',
      () {
        // Chain: 1→2, 1→3, 1→4
        final result = engine.evaluate(
          reminders: [
            _reminder(1),
            _reminder(2),
            _reminder(3),
            _reminder(4),
          ],
          edges: [
            _edge(1, 2),
            _edge(1, 3),
            _edge(1, 4),
          ],
          confirmedId: 1,
          state: ConfirmationState.done,
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (reminders) {
          expect(reminders.length, 3);
          final ids = reminders.map((r) => r.id).toSet();
          expect(ids, {2, 3, 4});
        });
      },
    );

    test(
      'DONE on middle node activates only its direct children',
      () {
        // Chain: 1→2→3→4
        // DONE on 2 should return [3] only
        final result = engine.evaluate(
          reminders: [
            _reminder(1),
            _reminder(2),
            _reminder(3),
            _reminder(4),
          ],
          edges: [
            _edge(1, 2),
            _edge(2, 3),
            _edge(3, 4),
          ],
          confirmedId: 2,
          state: ConfirmationState.done,
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (reminders) {
          expect(reminders.length, 1);
          expect(reminders.first.id, 3);
        });
      },
    );

    test(
      'DONE in diamond DAG returns only immediate next',
      () {
        // Diamond: 1→2, 1→3, 2→4, 3→4
        // DONE on 1 returns [2, 3] (not 4)
        final result = engine.evaluate(
          reminders: [
            _reminder(1),
            _reminder(2),
            _reminder(3),
            _reminder(4),
          ],
          edges: [
            _edge(1, 2),
            _edge(1, 3),
            _edge(2, 4),
            _edge(3, 4),
          ],
          confirmedId: 1,
          state: ConfirmationState.done,
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (reminders) {
          expect(reminders.length, 2);
          final ids = reminders.map((r) => r.id).toSet();
          expect(ids, {2, 3});
        });
      },
    );
  });

  group('ChainEngine.evaluate — SKIPPED state', () {
    test('SKIPPED on leaf node returns empty list', () {
      final result = engine.evaluate(
        reminders: [_reminder(1)],
        edges: [],
        confirmedId: 1,
        state: ConfirmationState.skipped,
      );
      expect(result.isRight(), isTrue);
      result.fold(
        (_) {},
        (reminders) => expect(reminders, isEmpty),
      );
    });

    test(
      'SKIPPED suspends ALL transitive downstream (eager)',
      () {
        // Chain: 1→2→3→4
        // SKIP on 1 → [2, 3, 4]
        final result = engine.evaluate(
          reminders: [
            _reminder(1),
            _reminder(2),
            _reminder(3),
            _reminder(4),
          ],
          edges: [
            _edge(1, 2),
            _edge(2, 3),
            _edge(3, 4),
          ],
          confirmedId: 1,
          state: ConfirmationState.skipped,
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (reminders) {
          expect(reminders.length, 3);
          final ids = reminders.map((r) => r.id).toSet();
          expect(ids, {2, 3, 4});
        });
      },
    );

    test(
      'SKIPPED in diamond DAG returns all transitive '
      'descendants',
      () {
        // Diamond: 1→2, 1→3, 2→4, 3→4
        // SKIP on 1 → [2, 3, 4] — 4 only once
        final result = engine.evaluate(
          reminders: [
            _reminder(1),
            _reminder(2),
            _reminder(3),
            _reminder(4),
          ],
          edges: [
            _edge(1, 2),
            _edge(1, 3),
            _edge(2, 4),
            _edge(3, 4),
          ],
          confirmedId: 1,
          state: ConfirmationState.skipped,
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (reminders) {
          expect(reminders.length, 3);
          final ids = reminders.map((r) => r.id).toSet();
          expect(ids, {2, 3, 4});
        });
      },
    );

    test(
      'SKIPPED on middle node suspends only downstream '
      'subtree',
      () {
        // Chain: 1→2→3→4, 1→5
        // SKIP on 2 → [3, 4] — NOT 5
        final result = engine.evaluate(
          reminders: [
            _reminder(1),
            _reminder(2),
            _reminder(3),
            _reminder(4),
            _reminder(5),
          ],
          edges: [
            _edge(1, 2),
            _edge(2, 3),
            _edge(3, 4),
            _edge(1, 5),
          ],
          confirmedId: 2,
          state: ConfirmationState.skipped,
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (reminders) {
          expect(reminders.length, 2);
          final ids = reminders.map((r) => r.id).toSet();
          expect(ids, {3, 4});
        });
      },
    );
  });

  group('ChainEngine.evaluate — SNOOZED state', () {
    test(
      'SNOOZED returns the confirmed reminder itself',
      () {
        final target = _reminder(2);
        final result = engine.evaluate(
          reminders: [_reminder(1), target, _reminder(3)],
          edges: [_edge(1, 2), _edge(2, 3)],
          confirmedId: 2,
          state: ConfirmationState.snoozed,
        );
        expect(result.isRight(), isTrue);
        result.fold((_) {}, (reminders) {
          expect(reminders.length, 1);
          expect(reminders.first.id, 2);
        });
      },
    );
  });

  group('ChainEngine.evaluate — error cases', () {
    test(
      'returns NodeNotFound when confirmedId is not in '
      'reminders',
      () {
        final result = engine.evaluate(
          reminders: [_reminder(1), _reminder(2)],
          edges: [_edge(1, 2)],
          confirmedId: 99,
          state: ConfirmationState.done,
        );
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<NodeNotFound>());
            expect((error as NodeNotFound).nodeId, 99);
          },
          (_) => fail('Should have returned NodeNotFound'),
        );
      },
    );

    test('NodeNotFound for snoozed state too', () {
      final result = engine.evaluate(
        reminders: [_reminder(1)],
        edges: [],
        confirmedId: 42,
        state: ConfirmationState.snoozed,
      );
      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error, isA<NodeNotFound>()),
        (_) => fail('Should have returned NodeNotFound'),
      );
    });
  });

  group('ChainEngine — performance', () {
    test('evaluates 10-node chain in under 50ms', () {
      // Linear chain: 1→2→...→10
      final reminders = List.generate(10, (i) => _reminder(i + 1));
      final edgeList = [
        for (var i = 1; i < 10; i++) _edge(i, i + 1, id: i),
      ];

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        engine.evaluate(
          reminders: reminders,
          edges: edgeList,
          confirmedId: 1,
          state: ConfirmationState.done,
        );
      }
      stopwatch.stop();

      // 1000 evaluations well under 50 seconds (50ms each).
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50000),
      );
    });
  });
}
