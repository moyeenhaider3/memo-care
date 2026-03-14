import 'package:freezed_annotation/freezed_annotation.dart';

part 'fasting_models.freezed.dart';

/// Represents a single day of fasting with prayer times.
@freezed
abstract class FastingDay with _$FastingDay {
  const factory FastingDay({
    required int dayNumber,
    required DateTime sehriTime,
    required DateTime iftarTime,
    @Default(true) bool isFasting,
  }) = _FastingDay;
}

/// A medicine grouped into a fasting section (sehri or iftar).
@freezed
abstract class FastingMedicine with _$FastingMedicine {
  const factory FastingMedicine({
    required String id,
    required String name,
    required String dosage,
    required String notes,
    required FastingSection section,
    @Default(false) bool isTaken,
    String? scheduledTime,
  }) = _FastingMedicine;
}

/// Which fasting meal this medicine belongs to.
enum FastingSection {
  sehri,
  iftar,
}
