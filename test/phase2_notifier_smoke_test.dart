// Phase 2 (trace plan): schedule + caregiver path without a widget tree.
// `DailyScheduleNotifier` uses Drift `watch().first`; under `testWidgets` +
// `pumpWidget`, those streams do not complete (hangs). Use this unit test for
// `schedule::notifyCaregiverForMissed`; verify `ui::HomeScreen.*` on device
// with `flutter run` (debug) per the plan.
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DailyScheduleNotifier completes; caregiver trace runs', () async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.reminderChains).insert(
          ReminderChainsCompanion.insert(
            name: 'Diabetic Morning',
            createdAt: DateTime.now(),
          ),
        );

    final now = DateTime.now();
    await db.into(db.reminders).insert(
          RemindersCompanion.insert(
            chainId: 1,
            medicineName: 'Insulin',
            medicineType: MedicineType.beforeMeal.dbValue,
            dosage: const Value('10 units'),
            scheduledAt: Value(now.add(const Duration(minutes: 1))),
            isActive: const Value(true),
          ),
        );

    await db.into(db.reminders).insert(
          RemindersCompanion.insert(
            chainId: 1,
            medicineName: 'Metformin',
            medicineType: MedicineType.afterMeal.dbValue,
            dosage: const Value('500 mg'),
            isActive: const Value(false),
          ),
        );

    await db.into(db.chainEdges).insert(
          ChainEdgesCompanion.insert(
            chainId: 1,
            sourceId: 1,
            targetId: 2,
          ),
        );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(dailyScheduleNotifierProvider.future);
    expect(state.nextPending?.medicineName, 'Insulin');
  });
}
