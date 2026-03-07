import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:memo_care/features/confirmation/domain/models/confirmation_state.dart';

part 'confirmation.freezed.dart';
part 'confirmation.g.dart';

/// A recorded user response to a reminder.
@freezed
abstract class Confirmation with _$Confirmation {
  const factory Confirmation({
    required int id,
    required int reminderId,
    required ConfirmationState state,
    required DateTime confirmedAt,
    DateTime? snoozeUntil,
  }) = _Confirmation;

  factory Confirmation.fromJson(Map<String, dynamic> json) =>
      _$ConfirmationFromJson(json);
}
