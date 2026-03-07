import 'package:json_annotation/json_annotation.dart';

/// The 3 possible states of a reminder confirmation.
enum ConfirmationState {
  /// Medication taken. Triggers downstream chain nodes.
  @JsonValue('done')
  done('done'),

  /// Medication deferred. Re-fires at snooze_until time.
  @JsonValue('snoozed')
  snoozed('snoozed'),

  /// Medication declined. Suspends all downstream chain nodes.
  @JsonValue('skipped')
  skipped('skipped')
  ;

  const ConfirmationState(this.dbValue);

  /// The string stored in the `state` TEXT column in the database.
  final String dbValue;

  /// Parse from database TEXT column value.
  static ConfirmationState fromDbString(String value) => values.firstWhere(
    (e) => e.dbValue == value,
    orElse: () => throw ArgumentError('Unknown ConfirmationState: $value'),
  );
}
