import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memo_care/features/kids_mode/domain/kids_models.dart';

part 'kids_mode_state.freezed.dart';

/// State for Kids Mode dashboard and points system.
@freezed
abstract class KidsModeState with _$KidsModeState {
  const factory KidsModeState({
    @Default(false) bool isActive,
    @Default([]) List<Quest> dailyQuests,
    @Default(KidsPoints()) KidsPoints points,
    @Default('') String childName,
    @Default(0) int starRating,
    @Default(false) bool allQuestsComplete,
  }) = _KidsModeState;
}
