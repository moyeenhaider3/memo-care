import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/confirmation/domain/snooze_limiter.dart';

void main() {
  group('SnoozeLimiter', () {
    late SnoozeLimiter limiter;

    setUp(() {
      limiter = const SnoozeLimiter();
    });

    test(
      'first snooze (count=0) is allowed with 2 remaining',
      () {
        final result = limiter.evaluate(0);
        expect(result, isA<SnoozeAllowed>());
        expect(
          (result as SnoozeAllowed).remainingSnoozes,
          2,
        );
      },
    );

    test(
      'second snooze (count=1) is allowed with 1 remaining',
      () {
        final result = limiter.evaluate(1);
        expect(result, isA<SnoozeAllowed>());
        expect(
          (result as SnoozeAllowed).remainingSnoozes,
          1,
        );
      },
    );

    test(
      'third snooze (count=2) is allowed with 0 remaining',
      () {
        final result = limiter.evaluate(2);
        expect(result, isA<SnoozeAllowed>());
        expect(
          (result as SnoozeAllowed).remainingSnoozes,
          0,
        );
      },
    );

    test(
      '4th snooze attempt (count=3) is exhausted',
      () {
        final result = limiter.evaluate(3);
        expect(result, isA<SnoozeExhausted>());
        expect(
          (result as SnoozeExhausted).reason,
          contains('3 snooze attempts'),
        );
      },
    );

    test('count above max is still exhausted', () {
      final result = limiter.evaluate(10);
      expect(result, isA<SnoozeExhausted>());
    });

    test('custom max snoozes is respected', () {
      const custom = SnoozeLimiter(maxSnoozes: 1);

      expect(custom.evaluate(0), isA<SnoozeAllowed>());
      expect(custom.evaluate(1), isA<SnoozeExhausted>());
    });

    test(
      'zero max snoozes means every snooze is exhausted',
      () {
        const noSnooze = SnoozeLimiter(maxSnoozes: 0);
        expect(noSnooze.evaluate(0), isA<SnoozeExhausted>());
      },
    );
  });
}
