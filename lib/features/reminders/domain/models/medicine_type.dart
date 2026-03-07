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
  doseGap('dose_gap');

  const MedicineType(this.dbValue);

  /// The string stored in the `medicine_type` TEXT column in the database.
  final String dbValue;

  /// Parse from database TEXT column value.
  static MedicineType fromDbString(String value) => values.firstWhere(
        (e) => e.dbValue == value,
        orElse: () => throw ArgumentError('Unknown MedicineType: $value'),
      );
}
