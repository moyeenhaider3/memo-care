import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';

void main() {
  group('MedicineType', () {
    test('has exactly 5 values', () {
      expect(MedicineType.values.length, 5);
    });

    test('dbValue matches expected snake_case strings', () {
      expect(MedicineType.beforeMeal.dbValue, 'before_meal');
      expect(MedicineType.afterMeal.dbValue, 'after_meal');
      expect(MedicineType.emptyStomach.dbValue, 'empty_stomach');
      expect(MedicineType.fixedTime.dbValue, 'fixed_time');
      expect(MedicineType.doseGap.dbValue, 'dose_gap');
    });

    test('fromDbString roundtrips all values', () {
      for (final type in MedicineType.values) {
        expect(MedicineType.fromDbString(type.dbValue), equals(type));
      }
    });

    test('fromDbString throws ArgumentError on unknown value', () {
      expect(
        () => MedicineType.fromDbString('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fromDbString throws on empty string', () {
      expect(
        () => MedicineType.fromDbString(''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('ConfirmationState', () {
    test('has exactly 3 values', () {
      expect(ConfirmationState.values.length, 3);
    });

    test('dbValue matches expected lowercase strings', () {
      expect(ConfirmationState.done.dbValue, 'done');
      expect(ConfirmationState.snoozed.dbValue, 'snoozed');
      expect(ConfirmationState.skipped.dbValue, 'skipped');
    });

    test('fromDbString roundtrips all values', () {
      for (final state in ConfirmationState.values) {
        expect(
          ConfirmationState.fromDbString(state.dbValue),
          equals(state),
        );
      }
    });

    test('fromDbString throws ArgumentError on unknown value', () {
      expect(
        () => ConfirmationState.fromDbString('cancelled'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
