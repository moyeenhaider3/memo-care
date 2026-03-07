import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/providers/alarm_providers.dart';
import 'package:memo_care/features/anchors/application/providers.dart';
import 'package:memo_care/features/anchors/domain/models/meal_anchor.dart';
import 'package:memo_care/features/reminders/application/providers.dart'
    as reminder_providers;
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Manages meal anchor state — confirming meals and updating
/// default times.
///
/// Orchestrates the anchor resolution pipeline:
/// confirm meal → resolve dependent times → update Drift →
/// reschedule alarms.
///
/// Satisfies ANCR-01 (configurable times) and ANCR-02
/// (confirm → recalculate).
class AnchorNotifier extends AsyncNotifier<List<MealAnchor>> {
  @override
  Future<List<MealAnchor>> build() async {
    final anchors = await ref
        .watch(anchorRepositoryProvider)
        .watchAll()
        .first;
    return anchors;
  }

  /// Confirm that the user had a meal at [confirmedAt].
  ///
  /// Flow:
  /// 1. Update `anchor.confirmedAt` in Drift
  /// 2. Query all active reminders with meal-dependent types
  /// 3. `AnchorResolver.resolve()` → new fire times
  /// 4. Batch update `reminder.scheduledAt` in Drift
  /// 5. `AlarmScheduler.schedule()` for each affected reminder
  ///
  /// [mealType] is `'breakfast'`, `'lunch'`, or `'dinner'`.
  /// [confirmedAt] is the UTC timestamp when the meal was
  /// confirmed.
  Future<void> confirmMeal({
    required String mealType,
    required DateTime confirmedAt,
  }) async {
    state = const AsyncLoading<List<MealAnchor>>();
    state = await AsyncValue.guard(() async {
      final anchorRepo = ref.read(anchorRepositoryProvider);
      final reminderRepo = ref.read(
        reminder_providers.reminderRepositoryProvider,
      );
      final resolver = ref.read(anchorResolverProvider);
      final scheduler = ref.read(alarmSchedulerProvider);

      // 1. Get current anchor and update confirmedAt.
      final anchors = await anchorRepo.watchAll().first;
      final anchor = anchors.firstWhere(
        (a) => a.mealType == mealType,
        orElse: () =>
            throw ArgumentError('Unknown meal type: $mealType'),
      );
      final updatedAnchor = anchor.copyWith(
        confirmedAt: confirmedAt,
      );
      await anchorRepo.updateAnchor(updatedAnchor);

      // 2. Query active reminders, filter to meal-dependent.
      final allReminders =
          await reminderRepo.watchActive().first;
      final dependents =
          allReminders.where(_isMealDependent).toList();

      if (dependents.isNotEmpty) {
        // 3. Resolve new fire times.
        final updates = resolver.resolve(
          anchor: updatedAnchor,
          confirmedAt: confirmedAt,
          dependents: dependents,
        );

        // 4 & 5. Update Drift + reschedule alarms.
        for (final update in updates) {
          final reminder = dependents
              .firstWhere((r) => r.id == update.reminderId);
          final updated = reminder.copyWith(
            scheduledAt: update.scheduledAt,
          );
          await reminderRepo.updateReminder(updated);
          await scheduler.schedule(
            reminderId: update.reminderId,
            fireAt: update.scheduledAt,
            callbackHandle: alarmFiredCallback,
          );
        }
      }

      // Return updated anchors for state.
      return anchorRepo.watchAll().first;
    });
  }

  /// Update the default time for a meal anchor (ANCR-01).
  ///
  /// [minutesFromMidnight] is the new default time in minutes
  /// (e.g., 480 = 08:00 AM). After updating, cascades
  /// recalculation to all meal-dependent reminders using the
  /// new default time as the anchor reference.
  Future<void> updateDefaultTime({
    required String mealType,
    required int minutesFromMidnight,
  }) async {
    state = const AsyncLoading<List<MealAnchor>>();
    state = await AsyncValue.guard(() async {
      final anchorRepo = ref.read(anchorRepositoryProvider);
      final reminderRepo = ref.read(
        reminder_providers.reminderRepositoryProvider,
      );
      final resolver = ref.read(anchorResolverProvider);
      final scheduler = ref.read(alarmSchedulerProvider);

      // 1. Get current anchor and update default time.
      final anchors = await anchorRepo.watchAll().first;
      final anchor = anchors.firstWhere(
        (a) => a.mealType == mealType,
        orElse: () =>
            throw ArgumentError('Unknown meal type: $mealType'),
      );
      final updatedAnchor = anchor.copyWith(
        defaultTimeMinutes: minutesFromMidnight,
      );
      await anchorRepo.updateAnchor(updatedAnchor);

      // 2. Build reference time from the new default.
      final now = DateTime.now().toUtc();
      final referenceTime = DateTime.utc(
        now.year,
        now.month,
        now.day,
        minutesFromMidnight ~/ 60,
        minutesFromMidnight % 60,
      );

      // 3. Cascade recalculation to dependents.
      final allReminders =
          await reminderRepo.watchActive().first;
      final dependents =
          allReminders.where(_isMealDependent).toList();

      if (dependents.isNotEmpty) {
        final updates = resolver.resolve(
          anchor: updatedAnchor,
          confirmedAt: referenceTime,
          dependents: dependents,
        );

        for (final update in updates) {
          final reminder = dependents
              .firstWhere((r) => r.id == update.reminderId);
          final updated = reminder.copyWith(
            scheduledAt: update.scheduledAt,
          );
          await reminderRepo.updateReminder(updated);
          await scheduler.schedule(
            reminderId: update.reminderId,
            fireAt: update.scheduledAt,
            callbackHandle: alarmFiredCallback,
          );
        }
      }

      return anchorRepo.watchAll().first;
    });
  }

  /// Whether a reminder depends on meal anchors for its
  /// scheduled time.
  static bool _isMealDependent(Reminder r) =>
      switch (r.medicineType) {
        MedicineType.beforeMeal => true,
        MedicineType.afterMeal => true,
        MedicineType.emptyStomach => true,
        MedicineType.doseGap => true,
        MedicineType.fixedTime => false,
      };
}
