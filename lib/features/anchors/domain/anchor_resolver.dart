import 'package:memo_care/features/anchors/domain/models/anchor_config.dart';
import 'package:memo_care/features/anchors/domain/models/meal_anchor.dart';
import 'package:memo_care/features/anchors/domain/models/reminder_schedule_update.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/reminders/domain/models/reminder.dart';

/// Recalculates scheduled fire times for reminders that depend
/// on a meal anchor.
///
/// Pure Dart — no Flutter imports, no I/O, no side effects.
/// Given an anchor confirmation event and a list of dependent
/// reminders, produces [ReminderScheduleUpdate] entries for
/// each reminder that should be rescheduled.
///
/// **Medicine type resolution rules:**
/// - `beforeMeal`: `confirmedAt + beforeMealOffset` (negative)
/// - `afterMeal`: `confirmedAt + afterMealOffset`
/// - `doseGap`: `confirmedAt + reminder.gapHours` (or fallback)
/// - `emptyStomach`: `confirmedAt` if pre-condition passes
/// - `fixedTime`: excluded — no anchor dependency
///
/// See ARCHITECTURE.md §4.2 for design context.
class AnchorResolver {
  /// Creates a const [AnchorResolver] with the given [config].
  const AnchorResolver({this.config = AnchorConfig.defaults});

  /// Configurable timing offsets. Defaults match
  /// ARCHITECTURE.md hardcoded values.
  final AnchorConfig config;

  /// Resolve fire times for all [dependents] based on
  /// [anchor] confirmation.
  ///
  /// [confirmedAt] is the timestamp when the meal/anchor was
  /// confirmed. This may differ from `anchor.confirmedAt` —
  /// the parameter is the "trigger time" for this resolution
  /// pass, while `anchor.confirmedAt` records the last stored
  /// confirmation (used for empty-stomach pre-check).
  ///
  /// Returns a list of [ReminderScheduleUpdate] — one per
  /// rescheduled reminder. Reminders that fail pre-conditions
  /// (empty-stomach with recent meal) or don't depend on
  /// anchors (fixedTime) are excluded from results.
  List<ReminderScheduleUpdate> resolve({
    required MealAnchor anchor,
    required DateTime confirmedAt,
    required List<Reminder> dependents,
  }) {
    final updates = <ReminderScheduleUpdate>[];

    for (final reminder in dependents) {
      final update = _resolveOne(
        reminder: reminder,
        anchor: anchor,
        confirmedAt: confirmedAt,
      );
      if (update != null) {
        updates.add(update);
      }
    }

    return updates;
  }

  /// Resolve a single reminder. Returns `null` if the
  /// reminder should be excluded (fixedTime or failed
  /// pre-condition).
  ReminderScheduleUpdate? _resolveOne({
    required Reminder reminder,
    required MealAnchor anchor,
    required DateTime confirmedAt,
  }) {
    return switch (reminder.medicineType) {
      MedicineType.beforeMeal => ReminderScheduleUpdate(
          reminderId: reminder.id,
          scheduledAt: confirmedAt.add(config.beforeMealOffset),
        ),
      MedicineType.afterMeal => ReminderScheduleUpdate(
          reminderId: reminder.id,
          scheduledAt: confirmedAt.add(config.afterMealOffset),
        ),
      MedicineType.doseGap => ReminderScheduleUpdate(
          reminderId: reminder.id,
          scheduledAt: confirmedAt.add(
            Duration(
              hours: reminder.gapHours ?? config.defaultGapHours,
            ),
          ),
        ),
      MedicineType.emptyStomach => _resolveEmptyStomach(
          reminder: reminder,
          anchor: anchor,
          confirmedAt: confirmedAt,
        ),
      MedicineType.fixedTime => null,
    };
  }

  /// Empty-stomach resolution with pre-condition check
  /// (ANCR-05).
  ///
  /// Pre-condition: no meal confirmed within
  /// `config.emptyStomachFastHours`. If `anchor.confirmedAt`
  /// is `null` (no meal today), pre-condition passes. If the
  /// gap between `anchor.confirmedAt` and [confirmedAt]
  /// exceeds the fast window, pre-condition passes.
  ReminderScheduleUpdate? _resolveEmptyStomach({
    required Reminder reminder,
    required MealAnchor anchor,
    required DateTime confirmedAt,
  }) {
    final lastMealTime = anchor.confirmedAt;

    if (lastMealTime != null) {
      final hoursSinceMeal =
          confirmedAt.difference(lastMealTime).inHours.abs();
      if (hoursSinceMeal < config.emptyStomachFastHours) {
        return null;
      }
    }

    return ReminderScheduleUpdate(
      reminderId: reminder.id,
      scheduledAt: confirmedAt,
    );
  }
}
