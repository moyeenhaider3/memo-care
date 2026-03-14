import 'package:freezed_annotation/freezed_annotation.dart';

part 'kids_models.freezed.dart';

/// A daily quest/task item shown in the kids checklist.
@freezed
abstract class Quest with _$Quest {
  const factory Quest({
    required String id,
    required String title,
    required String time,
    @Default(false) bool isCompleted,
    @Default('task') String category,
  }) = _Quest;
}

/// Points accumulation for kids mode rewards.
@freezed
abstract class KidsPoints with _$KidsPoints {
  const factory KidsPoints({
    @Default(0) int totalPoints,
    @Default(0) int dailyPoints,
    @Default(0) int dailyStreak,
  }) = _KidsPoints;
}
