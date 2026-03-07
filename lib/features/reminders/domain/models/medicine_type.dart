import 'package:json_annotation/json_annotation.dart';

/// The 5 medication timing types that determine when a reminder fires
/// relative to meal anchors or other events.
enum MedicineType {
  /// Fire 30 minutes BEFORE the anchor meal time.
  @JsonValue('before_meal')
  beforeMeal('before_meal'),

  /// Fire 30 minutes AFTER the anchor meal time.
  @JsonValue('after_meal')
  afterMeal('after_meal'),

  /// Fire at anchor time; pre-condition: no meal in last N hours.
  @JsonValue('empty_stomach')
  emptyStomach('empty_stomach'),

  /// Fire at an absolute clock time (no anchor dependency).
  @JsonValue('fixed_time')
  fixedTime('fixed_time'),

  /// Fire N hours after previous dose was confirmed.
  @JsonValue('dose_gap')
  doseGap('dose_gap')
  ;

  const MedicineType(this.dbValue);

  /// The string stored in the `medicine_type` TEXT column in the database.
  final String dbValue;

  /// Parse from database TEXT column value.
  static MedicineType fromDbString(String value) => values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => throw ArgumentError('Unknown MedicineType: $value'),
  );
}

/// Maps each [MedicineType] to a natural-language context
/// phrase for TTS (A11Y-06).
///
/// Used by `buildReminderTtsText` in the alarm callback to
/// construct "Time to take {name}, {dose}, {context}".
extension MedicineTypeTts on MedicineType {
  /// The spoken context phrase for this medicine type.
  String get ttsContext => switch (this) {
    MedicineType.beforeMeal => 'before your meal',
    MedicineType.afterMeal => 'after your meal',
    MedicineType.emptyStomach => 'on an empty stomach',
    MedicineType.fixedTime => 'at your scheduled time',
    MedicineType.doseGap => 'for your next dose',
  };
}
