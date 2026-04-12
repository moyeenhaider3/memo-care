import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/database/app_database.dart';
import 'package:memo_care/core/providers/database_provider.dart';
import 'package:memo_care/features/chain_engine/application/providers.dart';
import 'package:memo_care/features/daily_schedule/application/daily_schedule_notifier.dart';
import 'package:memo_care/features/history/application/history_notifier.dart';
import 'package:memo_care/features/kids_mode/application/kids_mode_notifier.dart';
import 'package:memo_care/features/kids_mode/application/reward_notifier.dart';
import 'package:memo_care/features/onboarding/application/onboarding_notifier.dart';
import 'package:memo_care/features/reminders/application/providers.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:memo_care/dev/harness_seed_context.dart';

/// Seeds Drift + SharedPreferences + notifiers for `flutter run` harness.
///
/// Uses DAO insert methods and repository APIs — no raw SQL inserts except
/// table clears (FK-safe order).
class TestDataSeeder {
  TestDataSeeder._();

  /// Clears reminder-related tables and inserts demo data.
  static Future<void> seedAll(ProviderContainer container) async {
    HarnessSeedContext.clear();

    final db = container.read(appDatabaseProvider);
    final reminderRepo = container.read(reminderRepositoryProvider);
    final chainRepo = container.read(chainRepositoryProvider);
    final confirmationDao = db.confirmationDao;
    final prefs = container.read(sharedPreferencesProvider);

    await db.transaction(() async {
      await db.delete(db.confirmations).go();
      await db.delete(db.chainEdges).go();
      await db.delete(db.reminders).go();
      await db.delete(db.reminderChains).go();
    });

    // --- SharedPreferences: onboarding + caregiver ---
    await prefs.setBool('onboarding_complete', true);
    await container
        .read(settingsRepositoryProvider)
        .setCaregiverPhone('+923001234567');

    // --- Today boundaries (local midnight → UTC storage) ---
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    DateTime localToday(int hour, int minute) =>
        DateTime(todayStart.year, todayStart.month, todayStart.day, hour, minute);

    // 3 upcoming (future today)
    final upcomingTimes = [
      localToday(now.hour, now.minute).add(const Duration(hours: 1)),
      localToday(now.hour, now.minute).add(const Duration(hours: 2)),
      localToday(now.hour, now.minute).add(const Duration(hours: 3)),
    ];
    // If any still in past, push to tomorrow for first slot
    final adjustedUpcoming = upcomingTimes.map((t) {
      if (!t.toUtc().isAfter(DateTime.now().toUtc())) {
        return t.add(const Duration(days: 1));
      }
      return t;
    }).toList();

    final names = ['Metformin', 'Aspirin', 'Vitamin D'];
    for (var i = 0; i < 3; i++) {
      final chainId = await chainRepo.createChain(name: 'Daily ${names[i]}');
      final id = await reminderRepo.createReminder(
        chainId: chainId,
        medicineName: names[i],
        medicineType: MedicineType.fixedTime,
        dosage: i == 0 ? '500 mg' : '${100 * (i + 1)} mg',
        scheduledAt: adjustedUpcoming[i].toUtc(),
        isActive: true,
      );
      HarnessSeedContext.upcomingReminderIds.add(id);
    }

    // 1 missed (past today, no terminal confirmation)
    final missedChain = await chainRepo.createChain(name: 'Missed dose chain');
    final missedAt = localToday(6, 0);
    final missedId = await reminderRepo.createReminder(
      chainId: missedChain,
      medicineName: 'Missed Med',
      medicineType: MedicineType.fixedTime,
      dosage: '10 mg',
      scheduledAt: missedAt.toUtc(),
      isActive: true,
    );
    HarnessSeedContext.missedReminderId = missedId;

    // Chain 3 reminders: alarm + chain context "step 2 of 3"
    final tripleChainId = await chainRepo.createChain(name: 'Triple chain');
    HarnessSeedContext.chainTripleId = tripleChainId;
    final t1 = localToday(7, 0);
    final t2 = localToday(8, 0);
    final t3 = localToday(9, 0);
    final r1 = await reminderRepo.createReminder(
      chainId: tripleChainId,
      medicineName: 'Chain A',
      medicineType: MedicineType.fixedTime,
      dosage: '1',
      scheduledAt: t1.toUtc(),
      isActive: true,
    );
    final r2 = await reminderRepo.createReminder(
      chainId: tripleChainId,
      medicineName: 'Chain B (middle)',
      medicineType: MedicineType.fixedTime,
      dosage: '2',
      scheduledAt: t2.toUtc(),
      isActive: true,
    );
    final r3 = await reminderRepo.createReminder(
      chainId: tripleChainId,
      medicineName: 'Chain C',
      medicineType: MedicineType.fixedTime,
      dosage: '3',
      scheduledAt: t3.toUtc(),
      isActive: true,
    );
    await chainRepo.createEdge(
      chainId: tripleChainId,
      sourceId: r1,
      targetId: r2,
    );
    await chainRepo.createEdge(
      chainId: tripleChainId,
      sourceId: r2,
      targetId: r3,
    );
    HarnessSeedContext.chainMiddleReminderId = r2;

    // Alarm: with caregiver (reuse first upcoming — phone set globally)
    HarnessSeedContext.alarmWithCaregiverReminderId =
        HarnessSeedContext.upcomingReminderIds.first;

    // Alarm: dedicated row without caregiver — clear phone after creating row
    final soloChain = await chainRepo.createChain(name: 'Solo alarm');
    final soloId = await reminderRepo.createReminder(
      chainId: soloChain,
      medicineName: 'Solo Alarm Pill',
      medicineType: MedicineType.fixedTime,
      dosage: '25 mg',
      scheduledAt: adjustedUpcoming[0].toUtc(),
      isActive: true,
    );
    HarnessSeedContext.alarmNoCaregiverReminderId = soloId;
    await container.read(settingsRepositoryProvider).setCaregiverPhone('');
    // Restore caregiver for most tests
    await container
        .read(settingsRepositoryProvider)
        .setCaregiverPhone('+923001234567');

    // --- History: 10 past rows, mixed statuses (spread over last 7 days) ---
    final states = <String?>[
      'done',
      'skipped',
      'snoozed',
      'done',
      'skipped',
      null,
      'done',
      'snoozed',
      'done',
      '',
    ];
    for (var d = 0; d < 10; d++) {
      final at = DateTime.now()
          .toUtc()
          .subtract(Duration(hours: 3 + d * 5, minutes: d));
      final hChain = await chainRepo.createChain(name: 'History $d');
      final medName = d == 9 ? '' : 'HistoryMed $d';
      final rid = await reminderRepo.createReminder(
        chainId: hChain,
        medicineName: medName,
        medicineType: MedicineType.fixedTime,
        dosage: '$d mg',
        scheduledAt: at,
        isActive: true,
      );
      HarnessSeedContext.historyReminderIds.add(rid);
      final st = states[d];
      if (st == null || st.isEmpty) {
        continue;
      }
      if (st == 'snoozed') {
        await confirmationDao.insertConfirmation(
          ConfirmationsCompanion.insert(
            reminderId: rid,
            state: st,
            confirmedAt: at.add(const Duration(minutes: 5)),
            snoozeUntil: Value(at.add(const Duration(hours: 1))),
          ),
        );
      } else {
        await confirmationDao.insertConfirmation(
          ConfirmationsCompanion.insert(
            reminderId: rid,
            state: st,
            confirmedAt: at.add(const Duration(minutes: 5)),
          ),
        );
      }
    }

    // Onboarding notifier in-memory (for API checks)
    container.read(onboardingNotifierProvider.notifier).setProfileType('elderly');
    container.read(onboardingNotifierProvider.notifier).selectCondition('diabetes');

    // Kids: name + complete 3 quests (3 pending pattern)
    final kids = container.read(kidsModeNotifierProvider.notifier);
    kids.setChildName('Ali');
    kids.completeQuest('q1');
    kids.completeQuest('q2');
    kids.completeQuest('q3');

    // Reward: sound variant for /kids/reward-sound path
    container.read(rewardNotifierProvider.notifier).setUseSoundVariant(true);

    container.invalidate(dailyScheduleNotifierProvider);
    container.invalidate(historyNotifierProvider);

    debugPrint('[TestDataSeeder] seedAll() complete');
  }
}
