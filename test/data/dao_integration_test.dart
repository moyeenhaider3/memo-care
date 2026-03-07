import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/features/anchors/data/anchor_dao.dart';
import 'package:memo_care/features/anchors/data/anchor_repository.dart';
import 'package:memo_care/features/chain_engine/data/chain_dao.dart';
import 'package:memo_care/features/chain_engine/data/chain_repository.dart';
import 'package:memo_care/features/confirmation/data/confirmation_dao.dart';
import 'package:memo_care/features/confirmation/data/confirmation_repository.dart';
import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';
import 'package:memo_care/features/reminders/data/reminder_dao.dart';
import 'package:memo_care/features/reminders/data/reminder_repository.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';

void main() {
  late AppDatabase db;
  late ChainDao chainDao;
  late ReminderDao reminderDao;
  late ConfirmationDao confirmationDao;
  late AnchorDao anchorDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    chainDao = db.chainDao;
    reminderDao = db.reminderDao;
    confirmationDao = db.confirmationDao;
    anchorDao = db.anchorDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('UTC Epoch Millis Storage (P-10)', () {
    test('DateTime stored as UTC epoch millis INTEGER in SQLite', () async {
      // Insert a chain with a known UTC DateTime
      final knownTime = DateTime.utc(2026, 3, 7, 14, 30, 45, 123);
      final expectedMillis = knownTime.millisecondsSinceEpoch;

      final id = await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'UTC Test',
          createdAt: knownTime,
        ),
      );

      // Read the RAW INTEGER value from SQLite
      final result = await db.customSelect(
        'SELECT created_at FROM reminder_chains WHERE id = ?',
        variables: [Variable(id)],
      ).getSingle();

      final storedValue = result.data['created_at'] as int;

      // Verify it's stored as UTC epoch milliseconds
      expect(storedValue, equals(expectedMillis));
    });

    test('DateTime roundtrips through Drift preserve UTC', () async {
      final original = DateTime.utc(2026, 6, 15, 8);

      final id = await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'Roundtrip Test',
          createdAt: original,
        ),
      );

      final rows = await (db.select(db.reminderChains)
            ..where((c) => c.id.equals(id)))
          .get();

      expect(rows.single.createdAt, equals(original));
      expect(rows.single.createdAt.isUtc, isTrue);
    });

    test('nullable DateTime stored as NULL when not provided', () async {
      final chainId = await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'Chain',
          createdAt: DateTime.now().toUtc(),
        ),
      );

      await reminderDao.insertReminder(
        RemindersCompanion.insert(
          chainId: chainId,
          medicineName: 'Test Med',
          medicineType: MedicineType.fixedTime.dbValue,
        ),
      );

      final result = await db.customSelect(
        'SELECT scheduled_at FROM reminders WHERE chain_id = ?',
        variables: [Variable(chainId)],
      ).getSingle();

      expect(result.data['scheduled_at'], isNull);
    });
  });

  group('ChainDao CRUD', () {
    test('insertChain returns auto-generated ID', () async {
      final id = await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'Morning Routine',
          createdAt: DateTime.now().toUtc(),
        ),
      );
      expect(id, greaterThan(0));
    });

    test('watchAllChains emits on insert', () async {
      final stream = chainDao.watchAllChains();

      // First emission: empty list
      final first = await stream.first;
      expect(first, isEmpty);

      // Insert a chain
      await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'Test',
          createdAt: DateTime.now().toUtc(),
        ),
      );

      // Next emission should have 1 chain
      final second = await stream.first;
      expect(second, hasLength(1));
      expect(second.first.name, 'Test');
    });

    test('deleteChain removes the chain', () async {
      final id = await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'To Delete',
          createdAt: DateTime.now().toUtc(),
        ),
      );
      final deleted = await chainDao.deleteChain(id);
      expect(deleted, 1);

      final remaining = await db.select(db.reminderChains).get();
      expect(remaining, isEmpty);
    });
  });

  group('ReminderDao CRUD', () {
    late int chainId;

    setUp(() async {
      chainId = await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'Test Chain',
          createdAt: DateTime.now().toUtc(),
        ),
      );
    });

    test('insertReminder and watchActiveReminders', () async {
      await reminderDao.insertReminder(
        RemindersCompanion.insert(
          chainId: chainId,
          medicineName: 'Metformin',
          medicineType: MedicineType.afterMeal.dbValue,
          dosage: const Value('500mg'),
          isActive: const Value(true),
          scheduledAt: Value(DateTime.utc(2026, 3, 7, 9)),
        ),
      );

      final active = await reminderDao.watchActiveReminders().first;
      expect(active, hasLength(1));
      expect(active.first.medicineName, 'Metformin');
      expect(active.first.medicineType, 'after_meal');
      expect(active.first.isActive, isTrue);
    });

    test('inactive reminders not in watchActiveReminders', () async {
      await reminderDao.insertReminder(
        RemindersCompanion.insert(
          chainId: chainId,
          medicineName: 'Inactive Med',
          medicineType: MedicineType.fixedTime.dbValue,
        ),
      );

      final active = await reminderDao.watchActiveReminders().first;
      expect(active, isEmpty);
    });
  });

  group('ConfirmationDao', () {
    late int chainId;
    late int reminderId;

    setUp(() async {
      chainId = await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'Test',
          createdAt: DateTime.now().toUtc(),
        ),
      );
      reminderId = await reminderDao.insertReminder(
        RemindersCompanion.insert(
          chainId: chainId,
          medicineName: 'Test Med',
          medicineType: MedicineType.fixedTime.dbValue,
        ),
      );
    });

    test('insertConfirmation and watchLatestConfirmation', () async {
      await confirmationDao.insertConfirmation(
        ConfirmationsCompanion.insert(
          reminderId: reminderId,
          state: ConfirmationState.done.dbValue,
          confirmedAt: DateTime.utc(2026, 3, 7, 14),
        ),
      );

      final latest =
          await confirmationDao.watchLatestConfirmation(reminderId).first;
      expect(latest, isNotNull);
      expect(latest!.state, 'done');
    });

    test('latest confirmation is most recent by confirmedAt', () async {
      await confirmationDao.insertConfirmation(
        ConfirmationsCompanion.insert(
          reminderId: reminderId,
          state: ConfirmationState.snoozed.dbValue,
          confirmedAt: DateTime.utc(2026, 3, 7, 14),
        ),
      );
      await confirmationDao.insertConfirmation(
        ConfirmationsCompanion.insert(
          reminderId: reminderId,
          state: ConfirmationState.done.dbValue,
          confirmedAt: DateTime.utc(2026, 3, 7, 14, 10),
        ),
      );

      final latest =
          await confirmationDao.watchLatestConfirmation(reminderId).first;
      expect(latest!.state, 'done');
    });
  });

  group('AnchorDao', () {
    test('insertAnchor and watchAllAnchors', () async {
      await anchorDao.insertAnchor(
        MealAnchorsCompanion.insert(
          mealType: 'breakfast',
          defaultTime: 480, // 08:00
        ),
      );
      await anchorDao.insertAnchor(
        MealAnchorsCompanion.insert(
          mealType: 'lunch',
          defaultTime: 780, // 13:00
        ),
      );
      await anchorDao.insertAnchor(
        MealAnchorsCompanion.insert(
          mealType: 'dinner',
          defaultTime: 1140, // 19:00
        ),
      );

      final anchors = await anchorDao.watchAllAnchors().first;
      expect(anchors, hasLength(3));
    });

    test('watchAnchorByMealType filters correctly', () async {
      await anchorDao.insertAnchor(
        MealAnchorsCompanion.insert(
          mealType: 'breakfast',
          defaultTime: 480,
        ),
      );
      await anchorDao.insertAnchor(
        MealAnchorsCompanion.insert(
          mealType: 'lunch',
          defaultTime: 780,
        ),
      );

      final breakfast =
          await anchorDao.watchAnchorByMealType('breakfast').first;
      expect(breakfast, isNotNull);
      expect(breakfast!.mealType, 'breakfast');
      expect(breakfast.defaultTime, 480);
    });
  });

  group('Repository Mapping', () {
    test('ChainRepository maps rows to domain models', () async {
      final repo = ChainRepository(chainDao);
      final now = DateTime.utc(2026, 3, 7, 12);

      await chainDao.insertChain(
        ReminderChainsCompanion.insert(name: 'Test', createdAt: now),
      );

      final chains = await repo.watchAllChains().first;
      expect(chains, hasLength(1));
      expect(chains.first.name, 'Test');
      expect(chains.first.createdAt, now);
      expect(chains.first.isActive, isTrue);
    });

    test('ReminderRepository converts MedicineType enum correctly', () async {
      final repo = ReminderRepository(reminderDao);
      final chainId = await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'Chain',
          createdAt: DateTime.now().toUtc(),
        ),
      );

      await repo.createReminder(
        chainId: chainId,
        medicineName: 'Insulin',
        medicineType: MedicineType.beforeMeal,
        dosage: '10 units',
      );

      final reminders = await repo.watchForChain(chainId).first;
      expect(reminders, hasLength(1));
      expect(reminders.first.medicineName, 'Insulin');
      expect(reminders.first.medicineType, MedicineType.beforeMeal);
      expect(reminders.first.dosage, '10 units');
    });

    test('ConfirmationRepository converts ConfirmationState enum', () async {
      final repo = ConfirmationRepository(confirmationDao);
      final chainId = await chainDao.insertChain(
        ReminderChainsCompanion.insert(
          name: 'Chain',
          createdAt: DateTime.now().toUtc(),
        ),
      );
      final reminderId = await reminderDao.insertReminder(
        RemindersCompanion.insert(
          chainId: chainId,
          medicineName: 'Test',
          medicineType: MedicineType.fixedTime.dbValue,
        ),
      );

      await repo.createConfirmation(
        reminderId: reminderId,
        state: ConfirmationState.snoozed,
        confirmedAt: DateTime.utc(2026, 3, 7, 9),
        snoozeUntil: DateTime.utc(2026, 3, 7, 9, 10),
      );

      final latest = await repo.watchLatest(reminderId).first;
      expect(latest, isNotNull);
      expect(latest!.state, ConfirmationState.snoozed);
      expect(latest.snoozeUntil, isNotNull);
    });

    test('AnchorRepository maps defaultTime to defaultTimeMinutes', () async {
      final repo = AnchorRepository(anchorDao);

      await repo.createAnchor(
        mealType: 'breakfast',
        defaultTimeMinutes: 480,
      );

      final anchors = await repo.watchAll().first;
      expect(anchors, hasLength(1));
      expect(anchors.first.mealType, 'breakfast');
      expect(anchors.first.defaultTimeMinutes, 480);
      expect(anchors.first.confirmedAt, isNull);
    });
  });
}
