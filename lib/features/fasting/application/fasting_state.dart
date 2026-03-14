import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memo_care/features/fasting/domain/fasting_models.dart';

part 'fasting_state.freezed.dart';

/// State for Ramadan/Fasting Mode.
@freezed
abstract class FastingState with _$FastingState {
  const factory FastingState({
    @Default(false) bool isActive,
    @Default(1) int fastingDay,
    @Default(30) int totalDays,
    DateTime? sehriTime,
    DateTime? iftarTime,
    @Default(false) bool isFasting,
    @Default([]) List<FastingMedicine> sehriMedicines,
    @Default([]) List<FastingMedicine> iftarMedicines,
    @Default(0.0) double progressPercent,
    @Default('') String locationName,
  }) = _FastingState;
}
