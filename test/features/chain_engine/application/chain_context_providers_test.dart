import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_context.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';

/// Creates a test reminder with minimal required fields.
Reminder _reminder(int id, {int chainId = 1}) => Reminder(
  id: id,
  chainId: chainId,
  medicineName: 'Med $id',
  medicineType: MedicineType.fixedTime,
);

void main() {
  group('ChainContext', () {
    test('root node has empty upstream', () {
      // A → B, querying A: no upstream, B downstream.
      final ctx = ChainContext(
        currentReminder: _reminder(1),
        upstreamReminders: [],
        downstreamReminders: [_reminder(2)],
        chainName: 'Test Chain',
      );

      expect(ctx.upstreamReminders, isEmpty);
      expect(ctx.downstreamReminders, hasLength(1));
      expect(
        ctx.downstreamReminders.first.id,
        equals(2),
      );
      expect(ctx.chainName, 'Test Chain');
    });

    test('leaf node has empty downstream', () {
      // A → B, querying B: A upstream, no downstream.
      final ctx = ChainContext(
        currentReminder: _reminder(2),
        upstreamReminders: [_reminder(1)],
        downstreamReminders: [],
        chainName: 'Test Chain',
      );

      expect(ctx.upstreamReminders, hasLength(1));
      expect(
        ctx.upstreamReminders.first.id,
        equals(1),
      );
      expect(ctx.downstreamReminders, isEmpty);
    });

    test(
      'middle node has both upstream and downstream',
      () {
        // A → B → C, querying B.
        final ctx = ChainContext(
          currentReminder: _reminder(2),
          upstreamReminders: [_reminder(1)],
          downstreamReminders: [_reminder(3)],
          chainName: 'Diabetic Pack',
        );

        expect(ctx.upstreamReminders, hasLength(1));
        expect(ctx.downstreamReminders, hasLength(1));
        expect(
          ctx.currentReminder.medicineName,
          'Med 2',
        );
      },
    );

    test(
      'diamond DAG resolves multiple upstream parents',
      () {
        // A → C, B → C: querying C has [A, B] upstream.
        final ctx = ChainContext(
          currentReminder: _reminder(3),
          upstreamReminders: [
            _reminder(1),
            _reminder(2),
          ],
          downstreamReminders: [],
          chainName: 'Diamond Chain',
        );

        expect(ctx.upstreamReminders, hasLength(2));
        expect(ctx.downstreamReminders, isEmpty);
      },
    );

    test(
      'diamond DAG resolves multiple downstream '
      'children',
      () {
        // A → B, A → C: querying A has [B, C] downstream.
        final ctx = ChainContext(
          currentReminder: _reminder(1),
          upstreamReminders: [],
          downstreamReminders: [
            _reminder(2),
            _reminder(3),
          ],
          chainName: 'Fan-out Chain',
        );

        expect(ctx.upstreamReminders, isEmpty);
        expect(ctx.downstreamReminders, hasLength(2));
      },
    );

    test('standalone reminder has empty relationships', () {
      // Single-node chain with no edges.
      final ctx = ChainContext(
        currentReminder: _reminder(1),
        upstreamReminders: [],
        downstreamReminders: [],
        chainName: 'Solo Chain',
      );

      expect(ctx.upstreamReminders, isEmpty);
      expect(ctx.downstreamReminders, isEmpty);
    });
  });
}
