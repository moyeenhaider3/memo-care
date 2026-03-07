import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/features/anchors/domain/anchor_resolver.dart';
import 'package:memo_care/features/anchors/domain/models/anchor_config.dart';
import 'package:memo_care/features/anchors/domain/models/meal_anchor.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Helper to create a test [MealAnchor].
MealAnchor _anchor({
  int id = 1,
  String mealType = 'lunch',
  int defaultTimeMinutes = 720,
  DateTime? confirmedAt,
}) => MealAnchor(
  id: id,
  mealType: mealType,
  defaultTimeMinutes: defaultTimeMinutes,
  confirmedAt: confirmedAt,
);

/// Helper to create a test [Reminder] with required fields.
Reminder _reminder(
  int id, {
  MedicineType medicineType = MedicineType.afterMeal,
  int? gapHours,
  int chainId = 1,
}) => Reminder(
  id: id,
  chainId: chainId,
  medicineName: 'Med $id',
  medicineType: medicineType,
  gapHours: gapHours,
);

void main() {
  late AnchorResolver resolver;
  final lunchTime = DateTime.utc(2026, 3, 7, 13, 15);

  setUp(() {
    resolver = const AnchorResolver();
  });

  group('AnchorResolver.resolve — afterMeal', () {
    test('afterMeal reminder fires 30 minutes after confirmed time', () {
      final result = resolver.resolve(
        anchor: _anchor(confirmedAt: lunchTime),
        confirmedAt: lunchTime,
        dependents: [_reminder(1)],
      );

      expect(result, hasLength(1));
      expect(result.first.reminderId, 1);
      expect(
        result.first.scheduledAt,
        lunchTime.add(const Duration(minutes: 30)),
      );
    });

    test('afterMeal uses custom offset from config', () {
      const customResolver = AnchorResolver(
        config: AnchorConfig(afterMealOffset: Duration(minutes: 45)),
      );
      final result = customResolver.resolve(
        anchor: _anchor(confirmedAt: lunchTime),
        confirmedAt: lunchTime,
        dependents: [_reminder(1)],
      );

      expect(
        result.first.scheduledAt,
        lunchTime.add(const Duration(minutes: 45)),
      );
    });
  });

  group('AnchorResolver.resolve — beforeMeal', () {
    test('beforeMeal reminder fires 30 minutes before confirmed time', () {
      final result = resolver.resolve(
        anchor: _anchor(confirmedAt: lunchTime),
        confirmedAt: lunchTime,
        dependents: [_reminder(2, medicineType: MedicineType.beforeMeal)],
      );

      expect(result, hasLength(1));
      expect(result.first.reminderId, 2);
      expect(
        result.first.scheduledAt,
        lunchTime.add(const Duration(minutes: -30)),
      );
    });

    test('beforeMeal uses custom offset from config', () {
      const customResolver = AnchorResolver(
        config: AnchorConfig(beforeMealOffset: Duration(minutes: -15)),
      );
      final result = customResolver.resolve(
        anchor: _anchor(confirmedAt: lunchTime),
        confirmedAt: lunchTime,
        dependents: [_reminder(2, medicineType: MedicineType.beforeMeal)],
      );

      expect(
        result.first.scheduledAt,
        lunchTime.add(const Duration(minutes: -15)),
      );
    });
  });

  group('AnchorResolver.resolve — doseGap', () {
    test('doseGap fires reminder.gapHours after confirmed time', () {
      final result = resolver.resolve(
        anchor: _anchor(confirmedAt: lunchTime),
        confirmedAt: lunchTime,
        dependents: [
          _reminder(3, medicineType: MedicineType.doseGap, gapHours: 6),
        ],
      );

      expect(result, hasLength(1));
      expect(result.first.reminderId, 3);
      expect(
        result.first.scheduledAt,
        lunchTime.add(const Duration(hours: 6)),
      );
    });

    test(
      'doseGap falls back to config.defaultGapHours when gapHours is null',
      () {
        final result = resolver.resolve(
          anchor: _anchor(confirmedAt: lunchTime),
          confirmedAt: lunchTime,
          dependents: [
            _reminder(4, medicineType: MedicineType.doseGap),
          ],
        );

        expect(
          result.first.scheduledAt,
          lunchTime.add(const Duration(hours: 4)),
        );
      },
    );

    test('doseGap with custom defaultGapHours from config', () {
      const customResolver = AnchorResolver(
        config: AnchorConfig(defaultGapHours: 8),
      );
      final result = customResolver.resolve(
        anchor: _anchor(confirmedAt: lunchTime),
        confirmedAt: lunchTime,
        dependents: [
          _reminder(5, medicineType: MedicineType.doseGap),
        ],
      );

      expect(
        result.first.scheduledAt,
        lunchTime.add(const Duration(hours: 8)),
      );
    });
  });

  group('AnchorResolver.resolve — emptyStomach', () {
    test(
      'emptyStomach fires at confirmed time when no recent meal '
      '(pre-condition passes)',
      () {
        // Anchor confirmed 3 hours ago — exceeds 2-hour fast window.
        final longAgoConfirm = lunchTime.subtract(const Duration(hours: 3));
        final result = resolver.resolve(
          anchor: _anchor(confirmedAt: longAgoConfirm),
          confirmedAt: lunchTime,
          dependents: [
            _reminder(6, medicineType: MedicineType.emptyStomach),
          ],
        );

        expect(result, hasLength(1));
        expect(result.first.reminderId, 6);
        expect(result.first.scheduledAt, lunchTime);
      },
    );

    test(
      'emptyStomach excluded when meal confirmed recently '
      '(pre-condition fails)',
      () {
        // Anchor confirmed 1 hour ago — within 2-hour fast window.
        final recentConfirm = lunchTime.subtract(const Duration(hours: 1));
        final result = resolver.resolve(
          anchor: _anchor(confirmedAt: recentConfirm),
          confirmedAt: lunchTime,
          dependents: [
            _reminder(7, medicineType: MedicineType.emptyStomach),
          ],
        );

        expect(result, isEmpty);
      },
    );

    test(
      'emptyStomach included when anchor has no confirmedAt '
      '(never confirmed today)',
      () {
        final result = resolver.resolve(
          anchor: _anchor(),
          confirmedAt: lunchTime,
          dependents: [
            _reminder(8, medicineType: MedicineType.emptyStomach),
          ],
        );

        expect(result, hasLength(1));
        expect(result.first.scheduledAt, lunchTime);
      },
    );

    test('emptyStomach respects custom emptyStomachFastHours', () {
      const customResolver = AnchorResolver(
        config: AnchorConfig(emptyStomachFastHours: 4),
      );
      // Anchor confirmed 3 hours ago — within 4-hour custom window.
      final threeHoursAgo = lunchTime.subtract(const Duration(hours: 3));
      final result = customResolver.resolve(
        anchor: _anchor(confirmedAt: threeHoursAgo),
        confirmedAt: lunchTime,
        dependents: [
          _reminder(9, medicineType: MedicineType.emptyStomach),
        ],
      );

      expect(result, isEmpty);
    });
  });

  group('AnchorResolver.resolve — fixedTime', () {
    test(
      'fixedTime reminders are excluded from results '
      '(no anchor dependency)',
      () {
        final result = resolver.resolve(
          anchor: _anchor(confirmedAt: lunchTime),
          confirmedAt: lunchTime,
          dependents: [
            _reminder(10, medicineType: MedicineType.fixedTime),
          ],
        );

        expect(result, isEmpty);
      },
    );
  });

  group('AnchorResolver.resolve — mixed types', () {
    test('resolves multiple dependent reminders of different types', () {
      final result = resolver.resolve(
        anchor: _anchor(),
        confirmedAt: lunchTime,
        dependents: [
          _reminder(1, medicineType: MedicineType.beforeMeal),
          _reminder(2),
          _reminder(3, medicineType: MedicineType.doseGap, gapHours: 2),
          _reminder(4, medicineType: MedicineType.emptyStomach),
          _reminder(5, medicineType: MedicineType.fixedTime),
        ],
      );

      // fixedTime excluded → 4 results.
      expect(result, hasLength(4));

      final byId = {
        for (final u in result) u.reminderId: u.scheduledAt,
      };
      expect(byId[1], lunchTime.add(const Duration(minutes: -30)));
      expect(byId[2], lunchTime.add(const Duration(minutes: 30)));
      expect(byId[3], lunchTime.add(const Duration(hours: 2)));
      expect(byId[4], lunchTime);
    });
  });

  group('AnchorResolver.resolve — edge cases', () {
    test('empty dependents list returns empty list', () {
      final result = resolver.resolve(
        anchor: _anchor(confirmedAt: lunchTime),
        confirmedAt: lunchTime,
        dependents: [],
      );

      expect(result, isEmpty);
    });

    test('all fixedTime dependents returns empty list', () {
      final result = resolver.resolve(
        anchor: _anchor(confirmedAt: lunchTime),
        confirmedAt: lunchTime,
        dependents: [
          _reminder(1, medicineType: MedicineType.fixedTime),
          _reminder(2, medicineType: MedicineType.fixedTime),
        ],
      );

      expect(result, isEmpty);
    });

    test('uses UTC DateTime for all calculations (P-10)', () {
      final utcTime = DateTime.utc(2026, 3, 7, 13);
      final result = resolver.resolve(
        anchor: _anchor(),
        confirmedAt: utcTime,
        dependents: [
          _reminder(1),
        ],
      );

      expect(result.first.scheduledAt.isUtc, isTrue);
    });
  });
}
