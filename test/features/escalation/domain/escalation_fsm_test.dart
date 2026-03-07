import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/escalation/domain/escalation_fsm.dart';
import 'package:memo_care/features/escalation/domain/escalation_level.dart';

void main() {
  group('EscalationFSM', () {
    late EscalationFSM fsm;

    setUp(() {
      fsm = EscalationFSM();
    });

    tearDown(() {
      fsm.dispose();
    });

    test('initial level is silent', () {
      expect(fsm.current, EscalationLevel.silent);
    });

    test('escalates from silent to audible after default timeout', () {
      FakeAsync().run((fake) {
        final escalations = <EscalationLevel>[];
        fsm.start(escalations.add);

        fake.elapse(const Duration(minutes: 2));

        expect(escalations, [EscalationLevel.audible]);
        expect(fsm.current, EscalationLevel.audible);
      });
    });

    test('escalates from audible to fullscreen after second timeout', () {
      FakeAsync().run((fake) {
        final escalations = <EscalationLevel>[];
        fsm.start(escalations.add);

        // silent → audible (2 min) then audible → fullscreen (3 min)
        fake
          ..elapse(const Duration(minutes: 2))
          ..elapse(const Duration(minutes: 3));

        expect(escalations, [
          EscalationLevel.audible,
          EscalationLevel.fullscreen,
        ]);
        expect(fsm.current, EscalationLevel.fullscreen);
      });
    });

    test('does not escalate beyond fullscreen', () {
      FakeAsync().run((fake) {
        final escalations = <EscalationLevel>[];
        fsm.start(escalations.add);

        // Exhaust all tiers
        fake.elapse(const Duration(minutes: 10));

        expect(escalations, [
          EscalationLevel.audible,
          EscalationLevel.fullscreen,
        ]);
        expect(fsm.current, EscalationLevel.fullscreen);
      });
    });

    test('acknowledge cancels pending timer and resets to silent', () {
      FakeAsync().run((fake) {
        final escalations = <EscalationLevel>[];
        fsm.start(escalations.add);

        // Partially elapsed — not yet at 2 min
        fake.elapse(const Duration(minutes: 1));
        fsm.acknowledge();

        // Even after more time, no escalation should fire
        fake.elapse(const Duration(minutes: 5));

        expect(escalations, isEmpty);
        expect(fsm.current, EscalationLevel.silent);
      });
    });

    test('acknowledge during audible tier resets to silent', () {
      FakeAsync().run((fake) {
        final escalations = <EscalationLevel>[];
        fsm.start(escalations.add);

        // silent → audible
        fake.elapse(const Duration(minutes: 2));
        expect(fsm.current, EscalationLevel.audible);

        fsm.acknowledge();
        expect(fsm.current, EscalationLevel.silent);

        // No further escalation
        fake.elapse(const Duration(minutes: 5));
        // only the one before ack
        expect(escalations, [EscalationLevel.audible]);
      });
    });

    test('dispose cancels timer without reset', () {
      FakeAsync().run((fake) {
        final escalations = <EscalationLevel>[];
        fsm
          ..start(escalations.add)
          ..dispose();
        fake.elapse(const Duration(minutes: 10));

        expect(escalations, isEmpty);
      });
    });

    test('custom timeouts are respected', () {
      FakeAsync().run((fake) {
        final customFsm = EscalationFSM(
          timeouts: const {
            EscalationLevel.silent: Duration(seconds: 30),
            EscalationLevel.audible: Duration(seconds: 45),
          },
        );
        final escalations = <EscalationLevel>[];
        customFsm.start(escalations.add);

        fake.elapse(const Duration(seconds: 30));
        expect(escalations, [EscalationLevel.audible]);

        fake.elapse(const Duration(seconds: 45));
        expect(escalations, [
          EscalationLevel.audible,
          EscalationLevel.fullscreen,
        ]);

        customFsm.dispose();
      });
    });

    test('isActive returns true after start, false after acknowledge', () {
      FakeAsync().run((fake) {
        expect(fsm.isActive, isFalse);

        fsm.start((_) {});
        expect(fsm.isActive, isTrue);

        fsm.acknowledge();
        expect(fsm.isActive, isFalse);
      });
    });

    test('calling start when already active restarts from silent', () {
      FakeAsync().run((fake) {
        final escalations = <EscalationLevel>[];
        fsm.start(escalations.add);

        fake.elapse(const Duration(minutes: 1));

        // Restart — should cancel old timer, start fresh
        final escalations2 = <EscalationLevel>[];
        fsm.start(escalations2.add);

        // Original would have fired at 2 min mark, but was cancelled
        fake.elapse(const Duration(minutes: 1, seconds: 30));
        expect(escalations, isEmpty);
        expect(escalations2, isEmpty); // not yet 2 min from restart

        fake.elapse(const Duration(seconds: 30));
        expect(escalations2, [EscalationLevel.audible]);
      });
    });
  });
}
