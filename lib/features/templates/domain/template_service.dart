import 'package:fpdart/fpdart.dart';
import 'package:memo_care/core/platform/alarm_callback.dart';
import 'package:memo_care/core/platform/alarm_scheduler.dart';
import 'package:memo_care/features/chain_engine/data/chain_repository.dart';
import 'package:memo_care/features/chain_engine/domain/chain_validator.dart';
import 'package:memo_care/features/onboarding/domain/models/onboarding_state.dart';
import 'package:memo_care/features/reminders/data/reminder_repository.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';
import 'package:memo_care/features/templates/domain/models/template_pack.dart';

/// Errors that can occur during template instantiation.
sealed class TemplateError {
  const TemplateError();

  /// Human-readable error description.
  String get message;

  @override
  String toString() => message;
}

/// DAG cycle detected in the template's edge structure.
class TemplateCycleDetected extends TemplateError {
  const TemplateCycleDetected();

  @override
  String get message => 'Chain contains a cycle';
}

/// A [TemplateEdge] references an index outside the medicines
/// list.
class TemplateInvalidEdgeIndex extends TemplateError {
  const TemplateInvalidEdgeIndex(
    this.sourceIndex,
    this.targetIndex,
    this.medicineCount,
  );

  /// Source index that was out of bounds.
  final int sourceIndex;

  /// Target index that was out of bounds.
  final int targetIndex;

  /// Total number of medicines in the template.
  final int medicineCount;

  @override
  String get message =>
      'Edge $sourceIndex→$targetIndex out of bounds '
      '(medicines: $medicineCount)';
}

/// Database or scheduler failure during instantiation.
class TemplatePersistenceFailure extends TemplateError {
  const TemplatePersistenceFailure(this.details);

  /// Exception details.
  final String details;

  @override
  String get message => 'Persistence failure: $details';
}

/// Result of a successful template instantiation.
class TemplateInstantiationResult {
  const TemplateInstantiationResult({
    required this.chainId,
    required this.reminderIds,
    required this.edgeIds,
  });

  /// The created chain's database ID.
  final int chainId;

  /// Database IDs of the created reminders (ordered by
  /// chainPosition).
  final List<int> reminderIds;

  /// Database IDs of the created chain edges.
  final List<int> edgeIds;
}

/// Instantiates [TemplatePack] blueprints into real database
/// records.
///
/// Pipeline:
/// 1. Validate edge indices
/// 2. Create `ReminderChain`
/// 3. Create `Reminder`s (applying user overrides)
/// 4. Create `ChainEdge`s (resolving index → real ID)
/// 5. Run [ChainValidator] (cycle detection)
/// 6. Schedule initial alarms
///
/// If validation fails at step 5, all created records are
/// rolled back via `deleteChain` (which cascades).
class TemplateService {
  /// Creates a [TemplateService] with all required
  /// dependencies.
  TemplateService({
    required ChainRepository chainRepository,
    required ReminderRepository reminderRepository,
    required ChainValidator chainValidator,
    required AlarmScheduler alarmScheduler,
  }) : _chainRepo = chainRepository,
       _reminderRepo = reminderRepository,
       _chainValidator = chainValidator,
       _alarmScheduler = alarmScheduler;

  final ChainRepository _chainRepo;
  final ReminderRepository _reminderRepo;
  final ChainValidator _chainValidator;
  final AlarmScheduler _alarmScheduler;

  /// Instantiate a template pack into real database records.
  ///
  /// [pack] — the template blueprint.
  /// [userOverrides] — optional medicine customizations keyed
  ///   by chainPosition. If an override exists for a position,
  ///   its name/dosage/time replace the template defaults.
  /// [mealAnchorTimes] — mealType → minutes from midnight.
  ///   Used to compute initial `scheduledAt` for meal-linked
  ///   medicines.
  ///
  /// Returns `Right(TemplateInstantiationResult)` on success,
  /// or `Left(TemplateError)` on failure.
  Future<Either<TemplateError, TemplateInstantiationResult>> apply({
    required TemplatePack pack,
    Map<int, CustomMedicineEntry> userOverrides = const {},
    Map<String, int> mealAnchorTimes = const {},
  }) async {
    // Step 1: Validate edge indices.
    for (final edge in pack.edges) {
      if (edge.sourceIndex < 0 ||
          edge.sourceIndex >= pack.medicines.length ||
          edge.targetIndex < 0 ||
          edge.targetIndex >= pack.medicines.length) {
        return left(
          TemplateInvalidEdgeIndex(
            edge.sourceIndex,
            edge.targetIndex,
            pack.medicines.length,
          ),
        );
      }
    }

    try {
      // Step 2: Create the chain.
      final chainId = await _chainRepo.createChain(name: pack.name);

      // Step 3: Create reminders, building index → ID map.
      final indexToId = <int, int>{};
      final reminderIds = <int>[];

      for (var i = 0; i < pack.medicines.length; i++) {
        final med = pack.medicines[i];
        final override = userOverrides[med.chainPosition];

        final name = override?.name ?? med.name;
        final dosage = override?.dosage ?? med.defaultDosage;
        final type = override?.medicineType ?? med.medicineType;
        final scheduledAt = _computeScheduledAt(
          templateMed: med,
          override: override,
          mealAnchorTimes: mealAnchorTimes,
        );

        final id = await _reminderRepo.createReminder(
          chainId: chainId,
          medicineName: name,
          medicineType: type,
          dosage: dosage,
          scheduledAt: scheduledAt,
          isActive: true,
          gapHours: med.gapHours,
        );

        indexToId[i] = id;
        reminderIds.add(id);
      }

      // Step 4: Create edges, resolving indices → real IDs.
      final edgeIds = <int>[];
      final edgeRecords = <({int sourceId, int targetId})>[];

      for (final edge in pack.edges) {
        final sourceId = indexToId[edge.sourceIndex]!;
        final targetId = indexToId[edge.targetIndex]!;
        final edgeId = await _chainRepo.createEdge(
          chainId: chainId,
          sourceId: sourceId,
          targetId: targetId,
        );
        edgeIds.add(edgeId);
        edgeRecords.add(
          (sourceId: sourceId, targetId: targetId),
        );
      }

      // Step 5: Validate DAG (cycle detection).
      final validation = _chainValidator.validate(
        nodeIds: reminderIds,
        edges: edgeRecords,
      );

      if (validation.isLeft()) {
        await _chainRepo.deleteChain(chainId);
        return left(const TemplateCycleDetected());
      }

      // Step 6: Schedule alarms for reminders with times.
      final schedulable = <({int reminderId, DateTime fireAt})>[];
      for (final entry in indexToId.entries) {
        final med = pack.medicines[entry.key];
        final override = userOverrides[med.chainPosition];
        final scheduledAt = _computeScheduledAt(
          templateMed: med,
          override: override,
          mealAnchorTimes: mealAnchorTimes,
        );
        if (scheduledAt != null) {
          schedulable.add(
            (reminderId: entry.value, fireAt: scheduledAt),
          );
        }
      }
      if (schedulable.isNotEmpty) {
        await _alarmScheduler.scheduleAll(
          reminders: schedulable,
          callbackHandle: alarmFiredCallback,
        );
      }

      return right(
        TemplateInstantiationResult(
          chainId: chainId,
          reminderIds: reminderIds,
          edgeIds: edgeIds,
        ),
      );
    } on Exception catch (e) {
      return left(TemplatePersistenceFailure(e.toString()));
    }
  }

  /// Compute the initial scheduled time for a template
  /// medicine.
  DateTime? _computeScheduledAt({
    required TemplateMedicine templateMed,
    required Map<String, int> mealAnchorTimes,
    CustomMedicineEntry? override,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check for override time first.
    if (override?.timeMinutes != null) {
      return today.add(Duration(minutes: override!.timeMinutes!));
    }

    // Fixed-time medicines use their default time.
    if (templateMed.defaultTimeMinutes != null) {
      return today.add(Duration(minutes: templateMed.defaultTimeMinutes!));
    }

    // Meal-linked: compute from anchor time + offset.
    if (templateMed.anchorMeal != null) {
      final mealKey = templateMed.anchorMeal!.name;
      final anchorMinutes = mealAnchorTimes[mealKey];
      if (anchorMinutes != null) {
        final anchorTime = today.add(Duration(minutes: anchorMinutes));
        return switch (templateMed.medicineType) {
          MedicineType.beforeMeal => anchorTime.subtract(
            const Duration(minutes: 30),
          ),
          MedicineType.afterMeal => anchorTime.add(const Duration(minutes: 30)),
          _ => anchorTime,
        };
      }
    }

    return null;
  }
}
