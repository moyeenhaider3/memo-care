import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/anchors/domain/models/meal_anchor.dart';
import 'package:memo_care/features/chain_engine/domain/models/chain_edge.dart';
import 'package:memo_care/features/chain_engine/domain/models/reminder_chain.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

void main() {
  final testTime = DateTime.utc(2026, 3, 7, 14, 30);

  group('ReminderChain', () {
    test('fromJson/toJson roundtrip', () {
      final chain = ReminderChain(
        id: 1,
        name: 'Morning Routine',
        isActive: true,
        createdAt: testTime,
      );
      final json = chain.toJson();
      final restored = ReminderChain.fromJson(json);
      expect(restored, equals(chain));
    });

    test('copyWith produces new instance with changed field', () {
      final chain = ReminderChain(
        id: 1,
        name: 'Morning',
        createdAt: testTime,
      );
      final renamed = chain.copyWith(name: 'Evening');
      expect(renamed.name, 'Evening');
      expect(renamed.id, 1);
      expect(renamed.createdAt, testTime);
    });

    test('isActive defaults to true', () {
      final chain = ReminderChain(
        id: 1,
        name: 'Test',
        createdAt: testTime,
      );
      expect(chain.isActive, isTrue);
    });

    test('value equality', () {
      final a = ReminderChain(id: 1, name: 'A', createdAt: testTime);
      final b = ReminderChain(id: 1, name: 'A', createdAt: testTime);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ChainEdge', () {
    test('fromJson/toJson roundtrip', () {
      const edge = ChainEdge(
        id: 1,
        chainId: 10,
        sourceId: 100,
        targetId: 200,
      );
      final json = edge.toJson();
      final restored = ChainEdge.fromJson(json);
      expect(restored, equals(edge));
    });
  });

  group('Reminder', () {
    test('fromJson/toJson roundtrip with all fields', () {
      final reminder = Reminder(
        id: 1,
        chainId: 10,
        medicineName: 'Metformin',
        medicineType: MedicineType.afterMeal,
        dosage: '500mg',
        scheduledAt: testTime,
        isActive: true,
        gapHours: 8,
      );
      final json = reminder.toJson();
      final restored = Reminder.fromJson(json);
      expect(restored, equals(reminder));
    });

    test('fromJson/toJson roundtrip with null optional fields', () {
      final reminder = Reminder(
        id: 2,
        chainId: 10,
        medicineName: 'Insulin',
        medicineType: MedicineType.beforeMeal,
      );
      final json = reminder.toJson();
      final restored = Reminder.fromJson(json);
      expect(restored, equals(reminder));
      expect(restored.dosage, isNull);
      expect(restored.scheduledAt, isNull);
      expect(restored.gapHours, isNull);
    });

    test('isActive defaults to false', () {
      final reminder = Reminder(
        id: 1,
        chainId: 10,
        medicineName: 'Test',
        medicineType: MedicineType.fixedTime,
      );
      expect(reminder.isActive, isFalse);
    });

    test('medicineType serializes as snake_case in JSON', () {
      final reminder = Reminder(
        id: 1,
        chainId: 10,
        medicineName: 'Test',
        medicineType: MedicineType.emptyStomach,
      );
      final json = reminder.toJson();
      expect(json['medicineType'], 'empty_stomach');
    });
  });

  group('Confirmation', () {
    test('fromJson/toJson roundtrip', () {
      final confirmation = Confirmation(
        id: 1,
        reminderId: 100,
        state: ConfirmationState.done,
        confirmedAt: testTime,
      );
      final json = confirmation.toJson();
      final restored = Confirmation.fromJson(json);
      expect(restored, equals(confirmation));
    });

    test('snoozeUntil is null for non-snoozed states', () {
      final confirmation = Confirmation(
        id: 1,
        reminderId: 100,
        state: ConfirmationState.skipped,
        confirmedAt: testTime,
      );
      expect(confirmation.snoozeUntil, isNull);
    });

    test('snoozeUntil is set for snoozed state', () {
      final snoozeTime = testTime.add(const Duration(minutes: 10));
      final confirmation = Confirmation(
        id: 1,
        reminderId: 100,
        state: ConfirmationState.snoozed,
        confirmedAt: testTime,
        snoozeUntil: snoozeTime,
      );
      expect(confirmation.snoozeUntil, snoozeTime);
    });
  });

  group('MealAnchor', () {
    test('fromJson/toJson roundtrip', () {
      final anchor = MealAnchor(
        id: 1,
        mealType: 'breakfast',
        defaultTimeMinutes: 480, // 08:00
      );
      final json = anchor.toJson();
      final restored = MealAnchor.fromJson(json);
      expect(restored, equals(anchor));
    });

    test('defaultTimeMinutes represents minutes from midnight', () {
      final anchor = MealAnchor(
        id: 1,
        mealType: 'lunch',
        defaultTimeMinutes: 780, // 13:00
      );
      expect(anchor.defaultTimeMinutes, 780);
      // 780 minutes = 13 hours = 1:00 PM
      expect(anchor.defaultTimeMinutes ~/ 60, 13);
      expect(anchor.defaultTimeMinutes % 60, 0);
    });

    test('confirmedAt is nullable', () {
      final anchor = MealAnchor(
        id: 1,
        mealType: 'dinner',
        defaultTimeMinutes: 1140, // 19:00
      );
      expect(anchor.confirmedAt, isNull);
    });
  });
}
