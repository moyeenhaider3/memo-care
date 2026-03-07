import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/core/providers/alarm_providers.dart';
import 'package:memo_care/features/anchors/application/providers.dart';
import 'package:memo_care/features/anchors/data/anchor_repository.dart';
import 'package:memo_care/features/anchors/domain/anchor_resolver.dart';
import 'package:memo_care/features/anchors/domain/models/meal_anchor.dart';
import 'package:memo_care/features/reminders/application/providers.dart'
    as reminder_providers;
import 'package:memo_care/features/reminders/data/reminder_repository.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnchorRepository extends Mock implements AnchorRepository {}

class _MockReminderRepository extends Mock implements ReminderRepository {}

class _MockAlarmScheduler extends Mock implements AlarmScheduler {}

class _FakeMealAnchor extends Fake implements MealAnchor {}

class _FakeReminder extends Fake implements Reminder {}

void main() {
  late _MockAnchorRepository mockAnchorRepo;
  late _MockReminderRepository mockReminderRepo;
  late _MockAlarmScheduler mockAlarmScheduler;

  const lunchAnchor = MealAnchor(
    id: 1,
    mealType: 'lunch',
    defaultTimeMinutes: 720,
  );

  const afterMealReminder = Reminder(
    id: 10,
    chainId: 1,
    medicineName: 'Metformin',
    medicineType: MedicineType.afterMeal,
  );

  final fixedTimeReminder = Reminder(
    id: 20,
    chainId: 1,
    medicineName: 'Aspirin',
    medicineType: MedicineType.fixedTime,
    scheduledAt: DateTime.utc(2026, 3, 7, 8),
  );

  final lunchTime = DateTime.utc(2026, 3, 7, 13, 15);

  setUpAll(() {
    registerFallbackValue(_FakeMealAnchor());
    registerFallbackValue(_FakeReminder());
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockAnchorRepo = _MockAnchorRepository();
    mockReminderRepo = _MockReminderRepository();
    mockAlarmScheduler = _MockAlarmScheduler();

    when(
      () => mockAnchorRepo.watchAll(),
    ).thenAnswer((_) => Stream.value([lunchAnchor]));
    when(
      () => mockAnchorRepo.updateAnchor(any()),
    ).thenAnswer((_) async => true);
    when(() => mockReminderRepo.watchActive()).thenAnswer(
      (_) => Stream.value([afterMealReminder, fixedTimeReminder]),
    );
    when(
      () => mockReminderRepo.updateReminder(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockAlarmScheduler.schedule(
        reminderId: any(named: 'reminderId'),
        fireAt: any(named: 'fireAt'),
        callbackHandle: any(named: 'callbackHandle'),
      ),
    ).thenAnswer((_) async => true);
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        anchorRepositoryProvider.overrideWithValue(mockAnchorRepo),
        reminder_providers.reminderRepositoryProvider.overrideWithValue(
          mockReminderRepo,
        ),
        anchorResolverProvider.overrideWithValue(const AnchorResolver()),
        alarmSchedulerProvider.overrideWithValue(mockAlarmScheduler),
      ],
    );
  }

  group('AnchorNotifier.confirmMeal', () {
    test('updates anchor confirmedAt in repository', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(anchorNotifierProvider.notifier);
      await notifier.confirmMeal(
        mealType: 'lunch',
        confirmedAt: lunchTime,
      );

      final captured =
          verify(
                () => mockAnchorRepo.updateAnchor(captureAny()),
              ).captured.single
              as MealAnchor;

      expect(captured.confirmedAt, lunchTime);
      expect(captured.mealType, 'lunch');
    });

    test(
      'resolves dependent reminders and updates scheduledAt',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(anchorNotifierProvider.notifier);
        await notifier.confirmMeal(
          mealType: 'lunch',
          confirmedAt: lunchTime,
        );

        final captured =
            verify(
                  () => mockReminderRepo.updateReminder(captureAny()),
                ).captured.single
                as Reminder;

        expect(captured.id, 10);
        expect(
          captured.scheduledAt,
          lunchTime.add(const Duration(minutes: 30)),
        );
      },
    );

    test('schedules alarm for each resolved reminder', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(anchorNotifierProvider.notifier);
      await notifier.confirmMeal(
        mealType: 'lunch',
        confirmedAt: lunchTime,
      );

      verify(
        () => mockAlarmScheduler.schedule(
          reminderId: 10,
          fireAt: lunchTime.add(const Duration(minutes: 30)),
          callbackHandle: any(named: 'callbackHandle'),
        ),
      ).called(1);
    });

    test('does not update fixedTime reminders', () async {
      when(
        () => mockReminderRepo.watchActive(),
      ).thenAnswer((_) => Stream.value([fixedTimeReminder]));

      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(anchorNotifierProvider.notifier);
      await notifier.confirmMeal(
        mealType: 'lunch',
        confirmedAt: lunchTime,
      );

      verifyNever(
        () => mockReminderRepo.updateReminder(any()),
      );
      verifyNever(
        () => mockAlarmScheduler.schedule(
          reminderId: any(named: 'reminderId'),
          fireAt: any(named: 'fireAt'),
          callbackHandle: any(named: 'callbackHandle'),
        ),
      );
    });

    test(
      'handles empty active reminders list (no-op after '
      'anchor update)',
      () async {
        when(
          () => mockReminderRepo.watchActive(),
        ).thenAnswer((_) => Stream.value([]));

        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(anchorNotifierProvider.notifier);
        await notifier.confirmMeal(
          mealType: 'lunch',
          confirmedAt: lunchTime,
        );

        verify(() => mockAnchorRepo.updateAnchor(any())).called(1);
        verifyNever(
          () => mockReminderRepo.updateReminder(any()),
        );
      },
    );

    test('sets AsyncError for unknown meal type', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(anchorNotifierProvider.notifier);
      await notifier.confirmMeal(
        mealType: 'brunch',
        confirmedAt: lunchTime,
      );

      final notifierState = container.read(anchorNotifierProvider);
      expect(notifierState.hasError, isTrue);
    });
  });

  group('AnchorNotifier.updateDefaultTime', () {
    test('updates anchor default time in repository', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(anchorNotifierProvider.notifier);
      await notifier.updateDefaultTime(
        mealType: 'lunch',
        minutesFromMidnight: 780,
      );

      final captured =
          verify(
                () => mockAnchorRepo.updateAnchor(captureAny()),
              ).captured.single
              as MealAnchor;

      expect(captured.defaultTimeMinutes, 780);
    });

    test(
      'cascades recalculation to dependent reminders',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final notifier = container.read(anchorNotifierProvider.notifier);
        await notifier.updateDefaultTime(
          mealType: 'lunch',
          minutesFromMidnight: 780,
        );

        verify(() => mockReminderRepo.updateReminder(any())).called(1);
        verify(
          () => mockAlarmScheduler.schedule(
            reminderId: any(named: 'reminderId'),
            fireAt: any(named: 'fireAt'),
            callbackHandle: any(named: 'callbackHandle'),
          ),
        ).called(1);
      },
    );
  });
}
