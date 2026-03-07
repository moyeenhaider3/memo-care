import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_anchor.freezed.dart';
part 'meal_anchor.g.dart';

/// A user-defined meal time anchor (breakfast, lunch, dinner).
///
/// [defaultTimeMinutes] is minutes from midnight (e.g., 480 = 08:00).
/// [confirmedAt] is set when the user confirms they had this meal today.
@freezed
abstract class MealAnchor with _$MealAnchor {
  const factory MealAnchor({
    required int id,
    required String mealType,
    required int defaultTimeMinutes,
    DateTime? confirmedAt,
  }) = _MealAnchor;

  factory MealAnchor.fromJson(Map<String, dynamic> json) =>
      _$MealAnchorFromJson(json);
}
