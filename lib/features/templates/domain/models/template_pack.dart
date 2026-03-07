import 'package:flutter/foundation.dart';
import 'package:memo_care/features/reminders/domain/models/medicine_type.dart';

/// A meal type that a template medicine may be anchored to.
///
/// Re-exported here so template definitions don't need to
/// import from the anchors feature. Uses the same values as
/// the `meal_type` column in `MealAnchors`.
enum TemplateMealType {
  /// Morning meal anchor.
  breakfast,

  /// Midday meal anchor.
  lunch,

  /// Evening meal anchor.
  dinner,
}

/// A single medicine entry within a [TemplatePack].
///
/// [chainPosition] determines visual ordering in the template
/// preview. [anchorMeal] links this medicine to a meal anchor
/// (nullable for fixedTime meds). [gapHours] is only relevant
/// when [medicineType] is [MedicineType.doseGap].
/// [defaultTimeMinutes] is minutes-from-midnight for fixedTime
/// medicines (nullable).
@immutable
class TemplateMedicine {
  /// Creates a [TemplateMedicine].
  const TemplateMedicine({
    required this.name,
    required this.medicineType,
    required this.chainPosition,
    this.defaultDosage,
    this.anchorMeal,
    this.gapHours,
    this.defaultTimeMinutes,
  });

  /// Display name (user can customize after applying).
  final String name;

  /// How this medicine relates to meals/timing.
  final MedicineType medicineType;

  /// Default dosage text, e.g. `'500mg'` (nullable).
  final String? defaultDosage;

  /// Position in the chain for ordering (0-based).
  final int chainPosition;

  /// Which meal this medicine is anchored to (null for
  /// non-meal-linked meds).
  final TemplateMealType? anchorMeal;

  /// Gap hours for dose-gap type medicines.
  final int? gapHours;

  /// Default time in minutes from midnight for fixedTime
  /// medicines. E.g., 480 = 08:00, 1200 = 20:00.
  final int? defaultTimeMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateMedicine &&
          name == other.name &&
          medicineType == other.medicineType &&
          defaultDosage == other.defaultDosage &&
          chainPosition == other.chainPosition &&
          anchorMeal == other.anchorMeal &&
          gapHours == other.gapHours &&
          defaultTimeMinutes == other.defaultTimeMinutes;

  @override
  int get hashCode => Object.hash(
    name,
    medicineType,
    defaultDosage,
    chainPosition,
    anchorMeal,
    gapHours,
    defaultTimeMinutes,
  );

  @override
  String toString() =>
      'TemplateMedicine('
      'name: $name, '
      'type: $medicineType, '
      'position: $chainPosition)';
}

/// An edge connecting two [TemplateMedicine] entries by their
/// list index.
///
/// Indices reference positions in [TemplatePack.medicines].
/// Resolved to real `ChainEdge` records (with database IDs)
/// during template instantiation.
@immutable
class TemplateEdge {
  /// Creates a [TemplateEdge].
  const TemplateEdge({
    required this.sourceIndex,
    required this.targetIndex,
  });

  /// Index into [TemplatePack.medicines] for the source node.
  final int sourceIndex;

  /// Index into [TemplatePack.medicines] for the target node.
  final int targetIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateEdge &&
          sourceIndex == other.sourceIndex &&
          targetIndex == other.targetIndex;

  @override
  int get hashCode => Object.hash(sourceIndex, targetIndex);

  @override
  String toString() => 'TemplateEdge($sourceIndex → $targetIndex)';
}

/// A pre-defined medication chain template.
///
/// Contains all data needed to instantiate a complete
/// `ReminderChain` with `Reminder` nodes and `ChainEdge`
/// connections.
///
/// [condition] is a machine-readable key (e.g., `'diabetes'`,
/// `'blood_pressure'`) used to map conditions to suggested
/// templates during onboarding.
@immutable
class TemplatePack {
  /// Creates a [TemplatePack].
  const TemplatePack({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.medicines,
    required this.edges,
  });

  /// Unique identifier (e.g., `'diabetic_pack'`).
  final String id;

  /// Human-readable name (e.g., `'Diabetic Pack'`).
  final String name;

  /// Short description shown in the template picker.
  final String description;

  /// Condition key this template addresses.
  final String condition;

  /// The medicine nodes in this template chain.
  final List<TemplateMedicine> medicines;

  /// Edges defining the DAG structure. Indices reference
  /// [medicines].
  final List<TemplateEdge> edges;

  @override
  String toString() =>
      'TemplatePack('
      'id: $id, '
      'name: $name, '
      'medicines: ${medicines.length}, '
      'edges: ${edges.length})';
}
